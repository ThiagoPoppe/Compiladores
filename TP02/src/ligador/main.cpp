#include <iostream>

#include "ligador.h"

int main(int argc, char *argv[]) {
    std::vector<std::string> filenames;
    for (int i = 1; i < argc; i++)
        filenames.push_back(argv[i]);

    Ligador linker = Ligador(filenames);
    linker.solve_labels();
    linker.link();

    return 0;
}