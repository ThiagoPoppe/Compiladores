#ifndef LIGADOR_H
#define LIGADOR_H

#include <bits/stdc++.h>

class Ligador {
    private:
        std::string program_body;
        unsigned int program_start;
        unsigned int program_length;

        std::vector<int> program;
        std::map<std::string, int> labels; // labels memory position table

    public:
        Ligador(std::vector<std::string> &filenames);
        ~Ligador();

        void solve_labels();
        void link();
};

#endif
