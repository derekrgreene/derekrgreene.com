#include "pantry.h"

int main() {
    Pantry pantry;
    Recipe recipe;
    char choice;

    do {
        Menu::printMenu();
        choice = Menu::getUserChoice();

        switch (choice) {
            case '1': {
                string ingredient;
                cout << "Enter the ingredient to add: ";
                getline(cin, ingredient);
                pantry.addIngredient(ingredient);
                getch();
                break;
            }
            case '2': {
                string ingredient;
                cout << "Enter the ingredient to remove: ";
                getline(cin, ingredient);
                pantry.removeIngredient(ingredient);
                getch();
                break;
            }
            case '3': {
                string ingredient;
                cout << "Enter the ingredient to search for: ";
                getline(cin, ingredient);
                if (pantry.searchForIngredient(ingredient)) {
                    cout << "Ingredient found in pantry." << endl << "\nPress any Key to Continue....\n";
                } else {
                    cout << "Ingredient not found in pantry." << endl << "\nPress any Key to Continue....\n";
                }
                getch();
                break;
            }
            case '4': {
                string oldIngredient, newIngredient;
                cout << "Enter the ingredient to edit: ";
                getline(cin, oldIngredient);
                cout << "Enter the new spelling of the ingredient: ";
                getline(cin, newIngredient);
                pantry.editIngredient(oldIngredient, newIngredient);
                break;
            }
            case '5': {
                pantry.saveIngredientsToFile();
                cout << "\nPress any Key to Continue....\n";
                getch();
                break;
            }
            case '6': {
                pantry.displayIngredients();
                getch();
                break;
            }
            case '7': {
                string recipeFilename;
                cout << "Enter the filename of the recipe text file: ";
                getline(cin, recipeFilename);
                recipe.readFromFile(recipeFilename);
                recipe.checkForMissingIngredients(pantry);
                getch();
                break;
            }
            case '8': {
                pantry.saveIngredientsToFile();
                cout << "Exiting program." << endl;
                break;
            }
            default:
                cout << "Invalid choice. Please try again." << endl;
                getch();
        }
    } while (choice != '8');

    return 0;
}