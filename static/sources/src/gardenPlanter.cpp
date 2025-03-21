#include<iostream>

using namespace std;

double calculateArea(double length, double width, int rows) {
    return length * width * rows;
}

int main() {
    double totalGardenArea, remainingArea;
    int plantTypes = 0;
    double totalAreaUsed = 0;

    cout << "Enter the square footage of your garden plot: ";
    cin >> totalGardenArea;

    remainingArea = totalGardenArea;

    while (true) {
        cout << "\nPlant Type " << (plantTypes + 1) << endl;
        double length, width;
        int rows;
        cout << "Enter the length of the rows for this plant: ";
        cin >> length;
        cout << "Enter the width of the rows for this plant: ";
        cin >> width;
        cout << "Enter the number of rows for this plant: ";
        cin >> rows;

        double plantArea = calculateArea(length, width, rows);

        if (plantArea <= remainingArea) {
            cout << "\nThe square footage used for this plant: " << plantArea << endl;
            totalAreaUsed += plantArea;
            remainingArea -= plantArea;
            plantTypes++;
        } else {
            cout << "\nError: Not enough space for this plant. Square footage available: " << remainingArea << endl;
        }
        char anotherPlant;
        cout << "\nDo you want to plant something else? (y/n): ";
        cin >> anotherPlant;

        if (anotherPlant != 'y' && anotherPlant != 'Y') {
            break;
        }
    }
    cout << "\nSummary:" << endl;
    cout << "Total square footage used: " << totalAreaUsed << endl;
    cout << "Number of plant types: " << plantTypes << endl;
    cout << "Remaining square footage in the garden: " << remainingArea << endl;

    return 0;
}