# Définir le menu avec les prix précis
menu = {
    "baja taco": 4.25,
    "burrito": 7.50,
    "bowl": 8.50,
    "nachos": 11.00,
    "quesadilla": 8.50,
    "super burrito": 8.50,
    "super quesadilla": 9.50,
    "taco": 3.00,
    "tortilla salad": 8.00
}

# Initialiser le total à 0
total = 0.0

# Boucle pour prendre les entrées utilisateur
while True:
    try:
        # Prendre l'entrée de l'utilisateur
        item = input("Article : ").strip().lower()  # Utilisation de .strip() pour enlever les espaces

        # Vérifier si l'article est dans le menu
        if item in menu:
            # Ajouter le prix de l'article au total
            total += menu[item]
            # Afficher le total avec deux décimales
            print(f"Total : ${total:.2f}")
        if item =="":
            break
    except EOFError:
        # Sortir de la boucle en cas de fin de fichier (Ctrl+D)
        print(f"Le total final est : ${total:.2f}")
        break