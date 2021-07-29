#include <bits/stdc++.h>

#include "../include/montador.h"

Montador::Montador(std::string filename) {
    this->filename = filename;
    this->initializeTable();
}

Montador::~Montador() { }

void Montador::initializeTable() {
    this->table["HALT"] = std::make_pair(0, "");
    this->table["LOAD"] = std::make_pair(1, "rm");
    this->table["STORE"] = std::make_pair(2, "rm");
    this->table["READ"] = std::make_pair(3, "r");
    this->table["WRITE"] = std::make_pair(4, "r");
    this->table["COPY"] = std::make_pair(5, "rr");
    this->table["PUSH"] = std::make_pair(6, "r");
    this->table["POP"] = std::make_pair(7, "r");
    this->table["ADD"] = std::make_pair(8, "rr");
    this->table["SUB"] = std::make_pair(9, "rr");
    this->table["MUL"] = std::make_pair(10, "rr");
    this->table["DIV"] = std::make_pair(11, "rr");
    this->table["MOD"] = std::make_pair(12, "rr");
    this->table["AND"] = std::make_pair(13, "rr");
    this->table["OR"] = std::make_pair(14, "rr");
    this->table["NOT"] = std::make_pair(15, "r");
    this->table["JUMP"] = std::make_pair(16, "m");
    this->table["JZ"] = std::make_pair(17, "m");
    this->table["JN"] = std::make_pair(18, "m");
    this->table["CALL"] = std::make_pair(19, "m");
    this->table["RET"] = std::make_pair(20, "");
}

bool Montador::isInstruction(std::string token) {
    return this->table.find(token) != this->table.end();
}

bool Montador::isLabel(std::string token) {
    return token[token.size() - 1] == ':';
}

void Montador::printProgram() {
    std::cout << this->program[0];
    for (size_t i = 1; i < this->program.size(); i++)
        std::cout << " " << this->program[i];
    
    std::cout << std::endl;
}

int Montador::getMemoryLocation(std::string token) {
    return this->labels[token] - this->counter;
}

int Montador::getRegisterCode(std::string token) {
    return token[1] - '0';
}

void Montador::translateInstruction(std::string instruction) {
    std::string token, instruction_format;
    std::stringstream ss(instruction);
    // std::cout << "instruction: " << instruction << std::endl; //printing instruction for debug purposes

    // Retrieving instruction code
    ss >> token;
    instruction_format = this->getInstructionOperands(token);
    this->program.push_back(this->getInstructionCode(token));

    if (instruction_format == "m") {
        ss >> token;
        this->program.push_back(this->getMemoryLocation(token));
    }

    else if (instruction_format[0] == 'r') {
        ss >> token;
        this->program.push_back(this->getRegisterCode(token));

        if (instruction_format[1] == 'r') {
            ss >> token;
            this->program.push_back(this->getRegisterCode(token));
        }

        else if (instruction_format[1] == 'm') {
            ss >> token;
            this->program.push_back(this->getMemoryLocation(token));
        }
    }

    // std::cout << std::endl; // debug
}

int Montador::getProgramSize() {
    return this->program.size();
}

int Montador::getInstructionCode(std::string instruction) {
    return this->table[instruction].first;
}

std::string Montador::getInstructionOperands(std::string instruction) {
    return this->table[instruction].second;
}

void Montador::discoverLabels() {
    const char *cfilename = this->filename.c_str();
    std::ifstream infile(cfilename);

    std::string line;
    this->counter = 0;

    while (true) {
        // Reading next line and filtering commentary
        std::getline(infile, line);
        line = line.substr(0, line.find(';'));

        // Retrieving line's first token
        std::string token;
        std::stringstream ss(line);
        ss >> token;

        if (token == "END")
            break;

        else if (this->isInstruction(token))
            this->counter += 1 + this->getInstructionOperands(token).size();

        else if (this->isLabel(token)) {
            std::string label = token.substr(0, token.size() - 1);
            this->labels[label] = this->counter++;

            ss >> token;
            if (this->isInstruction(token))
                this->counter += this->getInstructionOperands(token).size();
        }
    }

    infile.close();
}

void Montador::translate() {
    const char *cfilename = this->filename.c_str();
    std::ifstream infile(cfilename);

    std::string line;
    this->counter = 0;

    while (true) {
        // Reading next line and filtering commentary
        std::getline(infile, line);
        line = line.substr(0, line.find(';'));

        // Retriving first token from line
        std::string token;
        std::stringstream ss(line);
        ss >> token;

        if (token == "END")
            break;

        else if (this->isInstruction(token)) {
            this->counter += 1 + this->getInstructionOperands(token).size();
            this->translateInstruction(line);
        }
        
        else if (this->isLabel(token)) {
            // std::cout << line << std::endl; // debug
            ss >> token;
            this->counter++;

            if (token == "WORD") {
                ss >> token;
                this->program.push_back(std::stoi(token));
                // std::cout << token << std::endl; // debug
            }
            
            else if (this->isInstruction(token)) {
                this->counter += this->getInstructionOperands(token).size();
                size_t start = line.find(':') + 1;
                this->translateInstruction(line.substr(start, line.size()));
            }
        }
    }

    infile.close();
}