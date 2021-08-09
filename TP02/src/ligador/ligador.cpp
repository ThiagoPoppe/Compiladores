#include <bits/stdc++.h>

#include "ligador.h"

Ligador::Ligador(std::vector<std::string> &filenames) {
    this->program_body = "";
    this->program_start = 0;
    this->program_length = 0;

    std::string label, program;
    int length, number_labels, memory_position;
    
    for (std::string file : filenames) {
        std::ifstream infile(file.c_str());
        
        infile >> length >> number_labels;
        for (int i = 0; i < number_labels; i++) {
            infile >> label >> memory_position;
            this->labels[label] = this->program_length + memory_position;

            if (label == "main")
                this->program_start = this->labels["main"];
        }

        infile.ignore();
        std::getline(infile, program);

        if (this->program_body != "")
            this->program_body += " ";
        
        this->program_body += program;
        this->program_length += length;

        infile.close();
    }
}

Ligador::~Ligador() { }

void Ligador::solve_labels() {
    // for (auto l : this->labels)
    //     std::cout << l.first << " " << l.second << std::endl;

    // std::cout << std::endl;
    // std::cout << this->program_body << std::endl;

    std::string token;
    std::stringstream ss(this->program_body);

    int counter = 0;
    while (ss >> token) {
        counter++;
        if (this->labels.find(token) != this->labels.end()) {
            int memory_position = this->labels[token] - counter;
            this->program.push_back(memory_position);
        }
        else {
            this->program.push_back(std::stoi(token));
        }
    }
}

void Ligador::link() {
    int load_address = 0;
    int program_size = this->program.size();

    std::cout << "MV-EXE" << std::endl;
    std::cout << program_size << " ";
    std::cout << load_address << " ";
    std::cout << program_size + 1000 << " ";
    std::cout << this->program_start << std::endl;
    
    std::cout << this->program[0];
    for (size_t i = 1; i < this->program.size(); i++)
        std::cout << " " << this->program[i];
    
    std::cout << std::endl;
}