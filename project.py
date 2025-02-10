from tkinter import *
from math import sin, cos, pi
from random import randrange

class Canon(object):
    """Small graphical cannon"""
    def __init__(self, boss, id, x, y, sens, coul):
        self.boss = boss
        # reference to the canvas
        self.appli = boss.master
        # reference to the application window
        self.id = id
        # cannon identifier (string)
        self.coul = coul
        # color associated with the cannon
        self.x1, self.y1 = x, y
        # axis of rotation of the cannon
        self.sens = sens
        # firing direction (-1: left, +1: right)
        self.lbu = 30
        # length of the nozzle
        self.angle = 0
        # default elevation (firing angle)
        # find the width and height of the canvas:
        self.xMax = int(boss.cget('width'))
        self.yMax = int(boss.cget('height'))
        # draw the cannon's nozzle (horizontal):
        self.x2, self.y2 = x + self.lbu * sens, y
        self.buse = boss.create_line(self.x1, self.y1,
                                     self.x2, self.y2, width=10)
        # draw the cannon body (colored circle):
        self.rc = 15
        # radius of the circle
        self.corps = boss.create_oval(x - self.rc, y - self.rc, x + self.rc,
                                      y + self.rc, fill=coul)
        # pre-draw a hidden shell (point outside the canvas):
        self.obus = boss.create_oval(-10, -10, -10, -10, fill='red')
        self.anim = False
        # animation indicators
        self.explo = False
        # explosion indicator

    def orienter(self, angle):
        "adjust the cannon's elevation"
        # note: the <angle> parameter is received as a string.
        # It must be converted to a float, then to radians:
        self.angle = float(angle) * pi / 180
        # note: use the coords method preferably with integers:
        self.x2 = int(self.x1 + self.lbu * cos(self.angle) * self.sens)
        self.y2 = int(self.y1 - self.lbu * sin(self.angle))
        self.boss.coords(self.buse, self.x1, self.y1, self.x2, self.y2)

    def deplacer(self, x, y):
        "move the cannon to a new position x, y"
        dx, dy = x - self.x1, y - self.y1
        self.boss.move(self.buse, dx, dy)
        self.boss.move(self.corps, dx, dy)
        self.x1 += dx
        self.y1 += dy
        self.x2 += dx
        self.y2 += dy
        # value of the movement

    def feu(self):
        "fire a shell - only if the previous one has finished its flight"
        if not (self.anim or self.explo):
            self.anim = True
            # get the description of all the cannons present:
            self.guns = self.appli.dictionnaireCanons()
            # starting position of the shell (it's the cannon's mouth):
            self.boss.coords(self.obus, self.x2 - 3, self.y2 - 3,
                             self.x2 + 3, self.y2 + 3)
            v = 17
            # initial speed
            # vertical and horizontal components of this speed:
            self.vy = -v * sin(self.angle)
            self.vx = v * cos(self.angle) * self.sens
            self.animer_obus()
            return True
            # => signal that the shot has been fired
        else:
            return False
            # => the shot could not be fired

    def animer_obus(self):
        "animate the shell (ballistic trajectory)"
        if self.anim:
            self.boss.move(self.obus, int(self.vx), int(self.vy))
            c = tuple(self.boss.coords(self.obus))
            # resulting coordinates
            xo, yo = c[0] + 3, c[1] + 3
            # coordinates of the center of the shell
            self.test_obstacle(xo, yo)
            # have we hit an obstacle?
            self.vy += .4
            # vertical acceleration
            self.boss.after(20, self.animer_obus)
        else:
            # animation finished - hide the shell and move the cannons:
            self.fin_animation()

    def test_obstacle(self, xo, yo):
        "evaluate if the shell has hit a target or the game limits"
        if yo > self.yMax or xo < 0 or xo > self.xMax:
            self.anim = False
            return
        # analyze the dictionary of cannons to see if the coords
        # of one of them are close to those of the shell:
        for id in self.guns:
            # id = key in the dictionary
            gun = self.guns[id]
            # corresponding value
            if xo < gun.x1 + self.rc and xo > gun.x1 - self.rc \
                    and yo < gun.y1 + self.rc and yo > gun.y1 - self.rc:
                self.anim = False
                # draw the shell explosion (yellow circle):
                self.explo = self.boss.create_oval(xo - 12, yo - 12,
                                                   xo + 12, yo + 12, fill='yellow', width=0)
                self.hit = id
                # reference to the hit target
                self.boss.after(150, self.fin_explosion)
                break

    def fin_explosion(self):
        "erase the explosion; reset the shell; handle the score"
        self.boss.delete(self.explo)
        # erase the explosion
        self.explo = False
        # allow a new shot
        # notify the master window of the success:
        self.appli.goal(self.id, self.hit)

    def fin_animation(self):
        "actions to perform when the shell has completed its trajectory"
        self.appli.disperser()
        # move the cannons
        # hide the shell (by sending it off the canvas):
        self.boss.coords(self.obus, -10, -10, -10, -10)

class Pupitre(Frame):
    """Control panel associated with a cannon"""
    def __init__(self, boss, canon):
        Frame.__init__(self, bd=3, relief=GROOVE)
        self.score = 0
        self.appli = boss
        # reference to the application
        self.canon = canon
        # reference to the associated cannon
        # System to adjust the firing angle:
        self.regl = Scale(self, from_=85, to=-15, troughcolor=canon.coul,
                          command=self.orienter)
        self.regl.set(45)
        # initial firing angle
        self.regl.pack(side=LEFT)
        # Identification label of the cannon:
        Label(self, text=canon.id).pack(side=TOP, anchor=W, pady=5)
        # Firing button:
        self.bTir = Button(self, text='Fire!', command=self.tirer)
        self.bTir.pack(side=BOTTOM, padx=5, pady=5)
        Label(self, text="points").pack()
        self.points = Label(self, text=' 0 ', bg='white')
        self.points.pack()
        # position to the left or right depending on the cannon's direction:
        if canon.sens == -1:
            self.pack(padx=5, pady=5, side=RIGHT)
        else:
            self.pack(padx=5, pady=5, side=LEFT)

    def tirer(self):
        "trigger the firing of the associated cannon"
        self.canon.feu()

    def orienter(self, angle):
        "adjust the elevation of the associated cannon"
        self.canon.orienter(angle)

    def attribuerPoint(self, p):
        "increment or decrement the score by <p> points"
        self.score += p
        self.points.config(text=' %s ' % self.score)

class Application(Frame):
    """Main application window"""
    def __init__(self):
        Frame.__init__(self)
        self.master.title('>>>>> Boom! Boom! <<<<<')
        self.pack()
        self.jeu = Canvas(self, width=400, height=250, bg='ivory',
                          bd=3, relief=SUNKEN)
        self.jeu.pack(padx=8, pady=8, side=TOP)
        self.guns = {}
        # dictionary of present cannons
        self.pupi = {}
        # dictionary of present control panels
        # Instantiation of 2 cannon objects (+1, -1 = opposite directions):
        self.guns["Billy"] = Canon(self.jeu, "Billy", 30, 200, 1, "red")
        self.guns["Linus"] = Canon(self.jeu, "Linus", 370, 200, -1, "blue")
        # Instantiation of 2 control panels associated with these cannons:
        self.pupi["Billy"] = Pupitre(self, self.guns["Billy"])
        self.pupi["Linus"] = Pupitre(self, self.guns["Linus"])

    def disperser(self):
            "Randomly move the cannons"
            for id in self.guns:
                gun = self.guns[id]
                # Position to the left or right, depending on the cannon's direction:
                if gun.sens == -1:
                    x = randrange(320, 380)
                else:
                    x = randrange(20, 80)
                # Actual movement:
                gun.deplacer(x, randrange(150, 240))

    def goal(self, i, j):
        "cannon <i> reports that it has hit opponent <j>"
        if i != j:
            self.pupi[i].attribuerPoint(1)
        else:
            self.pupi[i].attribuerPoint(-1)

    def dictionnaireCanons(self):
        "return the dictionary describing the present cannons"
        return self.guns

if __name__ == '__main__':
    Application().mainloop()