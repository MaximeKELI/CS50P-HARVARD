import unittest
from tkinter import *
from unittest.mock import *
from math import pi, cos, sin
from project import *  # Remplacez par le nom de votre fichier principal

class TestCanon(unittest.TestCase):

    def setUp(self):
        self.root = Tk()
        self.canvas = Canvas(self.root, width=400, height=250)
        self.canvas.pack()
        self.canon = Canon(self.canvas, "TestCanon", 30, 200, 1, "red")
        self.canon.appli = MagicMock()  # Mocking the application object
        self.canon.appli.dictionnaireCanons.return_value = {
            "TestCanon": self.canon
        }

    def tearDown(self):
        self.root.destroy()

    def test_orienter(self):
        self.canon.orienter("45")
        self.assertAlmostEqual(self.canon.angle, pi / 4)
        self.assertEqual(int(self.canon.x2), int(self.canon.x1 + self.canon.lbu * cos(pi / 4)))
        self.assertEqual(int(self.canon.y2), int(self.canon.y1 - self.canon.lbu * sin(pi / 4)))

    def test_deplacer(self):
        self.canon.deplacer(100, 100)
        self.assertEqual(self.canon.x1, 100)
        self.assertEqual(self.canon.y1, 100)

    def test_feu(self):
        self.canon.appli.dictionnaireCanons.return_value = {
            "TestCanon": self.canon
        }
        result = self.canon.feu()
        self.assertTrue(result)
        self.assertTrue(self.canon.anim)

    def test_animer_obus(self):
        self.canon.feu()
        self.canon.animer_obus()
        c = self.canvas.coords(self.canon.obus)
        self.assertNotEqual(c, [-10, -10, -10, -10])  # L'obus doit être visible sur le canvas

    def test_test_obstacle(self):
        # Simuler le tir du canon
        self.canon.feu()

        # Simuler l'obus en dehors de l'écran
        self.canon.test_obstacle(self.canon.xMax + 1, self.canon.yMax + 1)
        self.assertFalse(self.canon.anim)  # L'animation devrait être arrêtée après l'impact

        # Ajouter un test pour la collision avec un autre canon
        mock_canon = MagicMock()
        mock_canon.x1 = self.canon.x1
        mock_canon.y1 = self.canon.y1
        self.canon.appli.dictionnaireCanons.return_value = {
            "OtherCanon": mock_canon,
            "TestCanon": self.canon
        }
        self.canon.feu()

        # Déplacer l'obus sur la position d'un autre canon pour simuler une collision
        self.canon.test_obstacle(mock_canon.x1, mock_canon.y1)
        self.assertFalse(self.canon.anim)  # L'animation devrait être arrêtée après l'impact

        # Vérifier l'existence de l'attribut 'explo'
        self.assertIsNotNone(self.canon.explo)

        # Vérifier que 'self.hit' est correctement assigné
        self.assertEqual(self.canon.hit, "OtherCanon")
    def test_fin_explosion(self):
        self.canon.hit = "TestCanon"
        self.canon.appli = MagicMock()
        self.canon.fin_explosion()
        self.canon.appli.goal.assert_called_once_with(self.canon.id, self.canon.hit)

    def test_fin_animation(self):
        self.canon.appli = MagicMock()
        self.canon.fin_animation()
        self.canon.appli.disperser.assert_called_once()

class TestPupitre(unittest.TestCase):

    def setUp(self):
        self.root = Tk()
        self.app = Application()
        self.canon = Canon(self.app.jeu, "TestCanon", 30, 200, 1, "red")
        self.pupitre = Pupitre(self.app, self.canon)

    def tearDown(self):
        self.root.destroy()

    def test_tirer(self):
        self.canon.feu = MagicMock()
        self.pupitre.tirer()
        self.canon.feu.assert_called_once()

    def test_orienter(self):
        self.canon.orienter = MagicMock()
        self.pupitre.orienter(30)
        self.canon.orienter.assert_called_once_with(30)

    def test_attribuerPoint(self):
        self.pupitre.attribuerPoint(5)
        self.assertEqual(self.pupitre.score, 5)
        self.assertEqual(self.pupitre.points.cget('text').strip(), '5')

class TestApplication(unittest.TestCase):

    def setUp(self):
        self.app = Application()

    def tearDown(self):
        self.app.master.destroy()

    def test_disperser(self):
        initial_positions = {id: (canon.x1, canon.y1) for id, canon in self.app.guns.items()}
        self.app.disperser()
        for id, canon in self.app.guns.items():
            self.assertNotEqual(initial_positions[id], (canon.x1, canon.y1))

    def test_goal(self):
        self.app.goal("Billy", "Linus")
        self.assertEqual(self.app.pupi["Billy"].score, 1)
        self.assertEqual(self.app.pupi["Linus"].score, 0)

        self.app.goal("Billy", "Billy")
        self.assertEqual(self.app.pupi["Billy"].score, 0)

        self.app.goal("Linus", "Billy")
        self.assertEqual(self.app.pupi["Linus"].score, 1)
        self.assertEqual(self.app.pupi["Billy"].score, 0)

    def test_dictionnaireCanons(self):
        canons = self.app.dictionnaireCanons()
        self.assertIn("Billy", canons)
        self.assertIn("Linus", canons)
        self.assertEqual(canons["Billy"].coul, "red")
        self.assertEqual(canons["Linus"].coul, "blue")


if __name__ == '__main__':
    unittest.main()