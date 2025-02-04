def camel_to_snake(camel_case):
    result = []
    for i, char in enumerate(camel_case):
        if char.isupper() and i > 0:
            result.append('_')
        result.append(char)
    snake_case = ''.join(result).lower()
    return snake_case

camel_case_input = input("Veuillez entrer le nom de la variable en camel case : ")
snake_case_output = camel_to_snake(camel_case_input)
print("Nom de la variable en snake case :", snake_case_output)