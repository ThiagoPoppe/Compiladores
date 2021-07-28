#include <iostream>
#include <string>

#include "vm.h"

int main(int argc, char *argv[]) {
    bool verbose = false;
    std::ifstream f;

    switch (argc) {
    case 1:
        std::cerr << "Erro: nenhum arquivo fonte fornecido!!\n";
        return 1;
    case 2:
        f.open(argv[1]);
        break;
    case 3:
        if (argv[1] == std::string("-v")) {
            verbose = true;
            f.open(argv[2]);
        } else if (argv[2] == std::string("-v")) {
            verbose = true;
            f.open(argv[1]);
        } else {
            std::cerr << "Erro: comando inválido!\n"
                      << "Uso: emulador <path/to/file>\n"
                      << "ou   emulador <path/to/file> -v\n"
                      << "ou   emulador -v <path/to/file>\n";
            return 1;
        }
    }

    if (!f.is_open()) {
        std::cerr << "Erro: arquivo fonte inválido!\n";
        return 1;
    }

    if (verbose) std::cout << "=============== Modo Verbose ===============";

    std::string header;
    std::getline(f, header);
    if (header != "MV-EXE") {
        std::cerr << "Erro: formato não executável!";
        return 1;
    }

    vm::Machine m(f, verbose);
    bool halt = false;
    while (!halt) halt = vm::next(m);

    if (verbose)
        std::cout << "============================================\n"
                  << std::endl;

    for (int out : m.buffer) std::cout << out << std::endl;

    f.close();
    return 0;
}
