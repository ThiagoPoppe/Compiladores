#include <array>
#include <fstream>
#include <vector>

#ifndef VM_H
#define VM_H

namespace vm {
struct Machine {
    /// The virtual machine has a memory of at least 1000 positions.
    std::vector<int> mem;
    /// General-purpose registers.
    std::array<int, 4> reg;
    /// Program counter.
    int pc;
    /// Stack pointer.
    int sp;
    /// 2-bits Program Status Word, where the first bit indicates whether the
    /// last operation returned zero and the second bit indicates whether the
    /// last operation resulted in a negative value.
    std::array<bool, 2> psw;
    /// Operational mode:
    /// If false (simple), the machine output is the same of the program.
    /// If true (verbose), the machine outputs, for each instruction, the
    /// operation being executed plus a dump of the 7 registers.
    bool verbose;
    /// A buffer that stores the output of the program.
    std::vector<int> buffer;

    /// Takes a source file \p f and initializes the virtual machine.
    /// Takes a boolean \p verbose indicating the operational mode.
    ///
    /// \returns an instance of the virtual machine.
    Machine(std::ifstream &f, bool verbose);
};

enum Symbol {
    Halt = 0,  // Stop the program.
    Load = 1,  // Reg[R] <- Mem[M + PC]
    Store = 2, // Mem[M + PC] <- Reg[R]
    Read = 3,  // Reg[R] <- input
    Write = 4, // output <- Reg[R]
    Copy = 5,  // Reg[R1] <- Reg[R2], update PSW
    Push = 6,  // SP <- SP - 1; Mem[SP] <- Reg[R]
    Pop = 7,   // Reg[R] <- Mem[SP]; SP <- SP + 1;
    Add = 8,   // Reg[R1] <- Reg[R1] + Reg[R2], update PSW
    Sub = 9,   // Reg[R1] <- Reg[R1] - Reg[R2], update PSW
    Mul = 10,  // Reg[R1] <- Reg[R1] * Reg[R2], update PSW
    Div = 11,  // Reg[R1] <- Reg[R1] / Reg[R2], update PSW
    Mod = 12,  // Reg[R1] <- Reg[R1] % Reg[R2], update PSW
    And = 13,  // Reg[R1] <- Reg[R1] & Reg[R2], update PSW
    Or = 14,   // Reg[R1] <- Reg[R1] | Reg[R2], update PSW
    Not = 15,  // Reg[R1] <- ~Reg[R1], update PSW
    Jump = 16, // PC <- PC + M
    JZ = 17,   // If PSW[0] == 1, PC <- PC + M
    JN = 18,   // If PSW[1] == 1, PC <- PC + M
    Call = 19, // SP <- SP - 1; Mem[SP] <- PC; PC <- PC + M
    Ret = 20,  // PC <- Mem[SP]; SP <- SP + 1
};

struct Instruction {
    // Symbol of the operation.
    Symbol sym;
    // 0, 1, or 2 operands, depending on the symbol <sym>.
    std::vector<int> operands;
};

/// Takes a virtual machine \p VM and evaluates the next instruction.
///
/// \returns true if the program should stop (instruction = Halt).
bool next(Machine &m);
}; // namespace vm

#endif
