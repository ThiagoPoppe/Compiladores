#ifndef MONTADOR_H
#define MONTADOR_H

#include <bits/stdc++.h>

class Montador {
    private:
        std::string filename; // input assembly filename
        std::map<std::string, int> labels; // labels memory position table (for step 01)
        std::map<std::string, std::pair<int, std::string> > table; // assembler instruction table
    
    private:
        void initializeTable(); // initializes the assembler instruction table
        bool isInstruction(std::string line); // checks if line is an instruction
        bool isLabel(std::string line); // checks if line defines a label

        void printRegister(std::string r);
        void printMemory(std::string m);
        void printInstruction(std::string instruction);

    public:
        // Constructor and destructor
        Montador(std::string filename);
        ~Montador();

        int getInstructionCode(std::string instruction);
        std::string getInstructionOperands(std::string instruction);

        int getLabelMemoryLocation(std::string label);

        void discoverLabels(); // first assembly step
        void translate(); // second assembly step
};

#endif
