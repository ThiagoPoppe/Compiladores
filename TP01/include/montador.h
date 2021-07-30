#ifndef MONTADOR_H
#define MONTADOR_H

#include <bits/stdc++.h>

class Montador {
    private:
        unsigned int counter; 
        unsigned int programStart;
        std::string filename; // input assembly filename
        std::vector<int> program;
        std::map<std::string, int> labels; // labels memory position table (for step 01)
        std::map<std::string, std::pair<int, std::string> > table; // assembler instruction table
    
    private:
        void initializeTable(); // initializes the assembler instruction table
        bool isInstruction(std::string token); // checks if line is an instruction
        bool isLabel(std::string token); // checks if line defines a label

        int getRegisterCode(std::string token);
        int getMemoryLocation(std::string token);
        int getInstructionCode(std::string instruction);
        std::string getInstructionOperands(std::string instruction);

        void translateInstruction(std::string instruction);

    public:
        // Constructor and destructor
        Montador(std::string filename);
        ~Montador();

        void discoverLabels(); // first assembly step
        void translate(); // second assembly step
        void mount(); // mounts the program
};

#endif
