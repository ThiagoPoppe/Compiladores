#include <bits/stdc++.h>

#include "../include/montador.h"

Montador::Montador(std::string filename) {
    this->filename = filename;
    this->initializeTable();
}

Montador::~Montador() { }

void Montador::initializeTable() {
    this->table["HALT"]  = std::make_pair(0, "");
    this->table["LOAD"]  = std::make_pair(1, "rm");
    this->table["STORE"] = std::make_pair(2, "rm");
    this->table["READ"]  = std::make_pair(3, "r");
    this->table["WRITE"] = std::make_pair(4, "r");
    this->table["COPY"]  = std::make_pair(5, "rr");
    this->table["PUSH"]  = std::make_pair(6, "r");
    this->table["POP"]   = std::make_pair(7, "r");
    this->table["ADD"]   = std::make_pair(8, "rr");
    this->table["SUB"]   = std::make_pair(9, "rr");
    this->table["MUL"]   = std::make_pair(10, "rr");
    this->table["DIV"]   = std::make_pair(11, "rr");
    this->table["MOD"]   = std::make_pair(12, "rr");
    this->table["AND"]   = std::make_pair(13, "rr");
    this->table["OR"]    = std::make_pair(14, "rr");
    this->table["NOT"]   = std::make_pair(15, "r");
    this->table["JUMP"]  = std::make_pair(16, "m");
    this->table["JZ"]    = std::make_pair(17, "m");
    this->table["JN"]    = std::make_pair(18, "m");
    this->table["CALL"]  = std::make_pair(19, "m");
    this->table["RET"]   = std::make_pair(20, "");
}

bool Montador::isInstruction(std::string line) {
    std::string token = line.substr(0, line.find(' '));
    if (this->table.find(token) != this->table.end())
        return true;
    
    return false;
}

bool Montador::isLabel(std::string line) {
    if (line.find(':') != std::string::npos)
        return true;
    
    return false;
}

void Montador::printRegister(std::string r)
{
    if (r == "R0")
        std::cout << "0 ";
    else if (r == "R1")
        std::cout << "1 ";
    else if (r == "R2")
        std::cout << "2 ";
    else if (r == "R3")
        std::cout << "3 ";
}

void Montador::printMemory(std::string m) {
    std::cout << this->labels[m] << " ";
}

void Montador::printInstruction(std::string instruction) {
    std::string token;
    std::stringstream ss(instruction);
    std::cout << "instruction: " << instruction << std::endl; //printing instruction for debug purposes

    //printing instruction code
    ss >> token;
    std::cout << this->table[token].first << " ";

    //printing rest of instruction based on its formula
    if (this->table[token].second == "r") {
        ss >> token;
        this->printRegister(token);
    }
    if (this->table[token].second == "rr") {
        ss >> token;
        this->printRegister(token);
        ss >> token;
        this->printRegister(token);
    }
    if (this->table[token].second == "rm") {
        ss >> token;
        this->printRegister(token);
        ss >> token;
        this->printMemory(token);
    }
    if (this->table[token].second == "m") {
        ss >> token;
        this->printMemory(token);
    }

    std::cout << std::endl;
}

int Montador::getInstructionCode(std::string instruction) {
    return this->table[instruction].first;
}

std::string Montador::getInstructionOperands(std::string instruction) {
    return this->table[instruction].second;
}

int Montador::getLabelMemoryLocation(std::string label) {
    return this->labels[label];
}

void Montador::discoverLabels() {
    const char* cfilename = this->filename.c_str();
    std::ifstream infile(cfilename);
    
    std::string line;
    std::getline(infile, line);
    
    size_t instruction_counter = 0;
    while (line != "END") {
        // Filtering commentary from line
        line = line.substr(0, line.find(';'));

        if (this->isInstruction(line))
            instruction_counter++;
        
        else if (this->isLabel(line)) {
            std::string label = line.substr(0, line.find(':'));
            this->labels[label] = ++instruction_counter;
        }

        // Read next line
        std::getline(infile, line);
    }

    infile.close();
}

void Montador::translate() {
    const char *cfilename = this->filename.c_str();
    std::ifstream infile(cfilename);

    std::string line;
    std::getline(infile, line);

    while (line != "END") {
        // Filtering commentary from line
        line = line.substr(0, line.find(';'));

        if (this->isInstruction(line))
            this->printInstruction(line);

        else if (this->isLabel(line))
            std::cout << "label: " << line << std::endl;

        // Read next line
        std::getline(infile, line);
    }

    infile.close();
}