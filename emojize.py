import emoji

def main():
    # Demander à l'utilisateur de saisir une chaîne sans message supplémentaire
    user_input = input()

    # Convertir les codes en emoji
    emojized_text = emoji.emojize(user_input, language='alias')

    # Afficher la sortie sans préfixe supplémentaire
    print(emojized_text)

if __name__ == "__main__":
    main()