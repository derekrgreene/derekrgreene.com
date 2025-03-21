#include "final.h"

void menu(vector<Bin> bins) {
    int binNum;
    int binNum1;
    int removePartnum;
    int newPartnum;
    char choice;

    system("cls");
    cout << "Warehouse Inventory Tracker 1.0" << endl << endl;
    for (int i = 0; i < bins.size(); i++) {
        cout << "Bin " << i+1 << " Description: " << bins[i].getDescription() << " Number of parts: " << bins[i].getNumParts() << endl;
    }
    cout << "\nEnter a bin number to edit: ";
    cin >> binNum;
    binNum1 = binNum - 1;
    system("cls");
    cout << "You have selected bin " << binNum << " which contains " << bins[binNum1].numParts << " " << bins[binNum1].getDescription() << "'s" << "\n" << endl;
    cout << "What would you like to do?\n" << endl;
    cout << "1. Add parts" << endl;
    cout << "2. Remove parts" << endl;
    cout << "3. Exit" << endl << endl << ":"; 
    cin >> choice;
    switch (choice) {
        case '1':
            system("cls");
            cout << "Enter the amount of parts to add to bin "<< binNum << ": ";
            cin >> newPartnum;

            if (newPartnum + bins[binNum1].numParts <= 29 && newPartnum > 0) {
                bins = bins[binNum1].addParts(bins, binNum1, newPartnum);
                cout << "Updated part number: " << bins[binNum1].numParts << endl;
                system("pause");
                cout << "\n";
                menu(bins);
            } else if (newPartnum + bins[binNum1].numParts > 29) {
                cout << "Bin cannot hold more than 30 parts. Please try again.\n" << endl;
                system("pause");
                cout << "\n";
                menu(bins);
            } else if (newPartnum < 0) {
                cout << "Invalid entry. Please try again.\n" << endl;
                system("pause");
                cout << "\n";
                menu(bins);
            }
            break;
        case '2':
            system("cls");  
            cout << "Enter the amount of parts to remove from bin "<< binNum << " : ";
            cin >> removePartnum;

            if (bins[binNum1].numParts - removePartnum >= 0 && removePartnum <= bins[binNum1].numParts) {
                bins = bins[binNum1].removeParts(bins, binNum1, removePartnum);
                cout << "New part quantity: " << bins[binNum1].numParts << endl << endl;   
                system("pause"); 
                cout << "\n";
                menu(bins);
            } else {
                cout << "Bin cannot have a negative amount of parts. Please try again.\n" << endl;
                system("pause");
                cout << "\n";
                menu(bins);
            }
            break;
        case '3':
            system("cls");
            cout << "Exiting....\n" << endl;
            break;
        default:
            system("cls");  
            cout << "Invalid selection. Please try again.\n" << endl;
            system("pause");
            cout << "\n";
            menu(bins);
            break;
    }
}
int main() {
    Bin totalBins;
    vector<Bin> bins = totalBins.initializeArrayData();
    menu(bins);
}