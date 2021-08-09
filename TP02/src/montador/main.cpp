#include <iostream>

#include "montador.h"

int main(int argc, char *argv[]) {
    if (argc != 2) {
        std::cout << "usage: " << argv[0] << " <assembly file>" << "\n";
        std::exit(1);
    }

    Montador m = Montador(argv[1]);
    m.discoverLabels();
    m.translate();
    m.mount();
}