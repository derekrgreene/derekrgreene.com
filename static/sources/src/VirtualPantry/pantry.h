#ifndef PANTRY_H
#define PANTRY_H

#include <vector>
#include <string>
#include <fstream>
#include <iostream>
#include <algorithm>
#include <conio.h>
#include <stdlib.h>
using namespace std;

class Pantry {
private:
    vector<string> ingredients;
    const string pantryFileName = "pantry.txt";

public:
    Pantry()
        {loadIngredientsFromFile();}

    void loadIngredientsFromFile() {
        ifstream file(pantryFileName);
        if (!file.is_open()) {
            cout << "Pantry file not found. Creating new pantry." << endl << "\nPress any Key to Continue....\n";
        return;
        }
        string ingredient;
        while (getline(file, ingredient)) {
            ingredients.push_back(ingredient);
        }
        file.close();
    }

    void saveIngredientsToFile() const {
        int x;
        ofstream file(pantryFileName);
        if (!file.is_open()) {
            cout << "Error saving pantry file." << endl;
        return;
        }
        for (const auto& ingredient : ingredients) {
            file << ingredient << endl;
        }
        file.close();
        cout << "Pantry file saved." << endl;
        
    }

    void addIngredient(const string& ingredient) {
        ingredients.push_back(ingredient);
        cout << "Ingredient: " << ingredient << " added to pantry." << endl << "\nPress any Key to Continue....\n";
    }
    
    void removeIngredient(const string& ingredient) {
        auto it = find(ingredients.begin(), ingredients.end(), ingredient);
        if (it != ingredients.end()) {
            ingredients.erase(it);
            cout << "Ingredient: " << ingredient << " removed from pantry." << endl << "\nPress any Key to Continue....\n";
        } 
        else {
            cout << "Ingredient: " << ingredient << " not found in pantry." << endl << "\nPress any Key to Continue....\n";
        }
    }

    bool searchForIngredient(const string& ingredient) const {
        return find(ingredients.begin(), ingredients.end(), ingredient) != ingredients.end();
    }

    void editIngredient(const string& oldIngredient, const string& newIngredient) {
        auto it = find(ingredients.begin(), ingredients.end(), oldIngredient);
        if (it != ingredients.end()) {
            *it = newIngredient;
            cout << "Ingredient spelling changed." << endl << "\nPress any Key to Continue....\n";
        } 
        else {
            cout << "Ingredient: " << newIngredient << " not found in pantry." << endl << "\nPress any Key to Continue....\n";
        }
    }

    void displayIngredients() const {
        cout << "Pantry contents:" << endl;
        for (const auto& ingredient : ingredients) {
            cout << ingredient << endl;
        }
        cout << "\nPress any Key to Continue....\n";
    }
    
    vector<string> getIngredients() const
        {return ingredients;}
};

class Recipe {
private:
    vector<string> ingredients;

public:
    void readFromFile(const string& filename) {
        ifstream file(filename);
        if (!file.is_open()) {
            cout << "Error opening recipe file." << endl << "\nPress any Key to Continue....\n";
            return;
        }

    string line;
    while (getline(file, line)) {
        size_t start = line.find('<');
        size_t end = line.find('>');
        if (start != string::npos && end != string::npos && end > start + 1) {
            ingredients.push_back(line.substr(start + 1, end - start - 1));
            }
        }
    file.close();
    }

    vector<string> getIngredients() const
        {return ingredients;}

    void checkForMissingIngredients(const Pantry& pantry) const {
        cout << "Ingredients in the recipe file not found in the pantry:" << endl << "\nPress any Key to Continue....\n";
        for (const auto& ingredient : ingredients) {
            if (!pantry.searchForIngredient(ingredient)) {
                cout << ingredient << endl;
            }
        }
    }
};

class Menu {
public:
    static void printMenu() {
        cout << "\nMenu Options:" << endl;
        cout << "1. Add Ingredient" << endl;
        cout << "2. Remove Ingredient" << endl;
        cout << "3. Search for Ingredient" << endl;
        cout << "4. Edit Ingredient" << endl;
        cout << "5. Save Ingredients to File" << endl;
        cout << "6. Display Ingredients" << endl;
        cout << "7. Check Recipe for Ingredients" << endl;
        cout << "8. Exit" << endl;
        cout << "Enter your choice: ";
    }
    static char getUserChoice() {
        char choice;
        cin >> choice;
        cin.ignore(); // Clear input buffer
        return choice;
    }
};
#endif 