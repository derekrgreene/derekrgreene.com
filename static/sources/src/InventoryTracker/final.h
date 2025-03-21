#ifndef FINAL_H
#define FINAL_H

#include <string>
#include <iostream>
#include <vector>
#include <cstdlib>

using namespace std;

class Bin {
    public:
    string description;
    int numParts;
    Bin(){};
    
    vector<Bin> initializeArrayData() {
        vector<Bin> bins;
        vector<string> partd {"Valve", "Bearing", "Bushing", "Coupling", "Flange", "Gear", "Gear Housing", "Vacuum Gripper", "Cable", "Rod" };
        vector<int> partc {10, 5, 15, 21, 7, 5, 5, 25, 18, 12};
        for (int i = 0; i < partd.size(); i++) {
            Bin bin;
            bin.description = partd[i];
            bin.numParts = partc[i];
            bins.push_back(bin);
        }
        return bins;
    }
    vector<Bin> addParts(vector<Bin> bins, int binNum, int newPartnum) {
        bins[binNum].numParts += newPartnum;
        return bins;
    }
    vector<Bin> removeParts(vector<Bin> bins, int binNum, int removePartnum) {
        bins[binNum].numParts -= removePartnum;
        return bins;
    }
    string getDescription() 
        {return description;}    

    int getNumParts()              
        {return numParts;}
};
#endif