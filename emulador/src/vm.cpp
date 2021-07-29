#include <algorithm>
#include <cstddef>
#include <iostream>

#include "vm.h"

static vm::Instruction parse(vm::Machine &m) {
    vm::Instruction inst;
    inst.sym = static_cast<vm::Symbol>(m.mem[m.pc++]);

    switch (inst.sym) {
    case vm::Halt:
    case vm::Ret:
        break;
    case vm::Read:
    case vm::Write:
    case vm::Push:
    case vm::Pop:
    case vm::Not:
    case vm::Jump:
    case vm::JZ:
    case vm::JN:
    case vm::Call:
        inst.operands.resize(1);
        inst.operands[0] = m.mem[m.pc++];
        break;
    default:
        inst.operands.resize(2);
        inst.operands[0] = m.mem[m.pc++];
        inst.operands[1] = m.mem[m.pc++];
    }

    return inst;
}

vm::Machine::Machine(std::ifstream &f, bool verbose)
    : mem(), reg(), psw(), verbose(verbose) {
    int progSize, progAddr;
    f >> progSize;
    f >> progAddr;
    f >> this->sp;
    f >> this->pc;

    // Notice that, when the stack grows, this->SP decreases.
    // The VM memory shall have size at least 1000.
    int memSize = std::max({this->sp, progSize + progAddr, 1000});
    this->mem.resize(memSize);

    for (int Addr = progAddr; Addr < progAddr + progSize; Addr++)
        f >> this->mem[Addr];
}

// TODO: add m.reg checks?
bool vm::next(vm::Machine &m) {
    bool halt = false;
    Instruction inst = parse(m);

    auto UpdateFlags = [&m](int result) {
        m.psw[0] = result == 0;
        m.psw[1] = result < 0;
    };

    if (m.verbose) {
        std::cout << std::endl;
        std::cout << "Instrução = " << inst.sym;
        for (int op : inst.operands) std::cout << " " << op;
        std::cout << std::endl;
    }

    switch (inst.sym) {
    case vm::Halt:
        halt = true;
        break;
    case vm::Load:
        m.reg[inst.operands[0]] = m.mem[inst.operands[1] + m.pc];
        break;
    case vm::Store:
        m.mem[inst.operands[1] + m.pc] = m.reg[inst.operands[0]];
        break;
    case vm::Read:
        int input;
        std::cin >> input;
        m.reg[inst.operands[0]] = input;
        break;
    case vm::Write:
        m.buffer.push_back(m.reg[inst.operands[0]]);
        break;
    case vm::Copy:
        m.reg[inst.operands[0]] = m.reg[inst.operands[1]];
        UpdateFlags(m.reg[inst.operands[0]]);
        break;
    case vm::Push:
        m.mem[--m.sp] = m.reg[inst.operands[0]];
        break;
    case vm::Pop:
        m.reg[inst.operands[0]] = m.mem[m.sp++];
        break;
    case vm::Jump:
        m.pc = m.pc + inst.operands[0];
        break;
    case vm::JZ:
        m.pc += m.psw[0] ? inst.operands[0] : 0;
        break;
    case vm::JN:
        m.pc += m.psw[1] ? inst.operands[0] : 0;
        break;
    case vm::Call:
        m.mem[--m.sp] = m.pc;
        m.pc += inst.operands[0];
        break;
    case vm::Ret:
        m.pc = m.mem[m.sp++];
        break;
    case vm::And:
        m.reg[inst.operands[0]] &= m.reg[inst.operands[1]];
        UpdateFlags(m.reg[inst.operands[0]]);
        break;
    case vm::Or:
        m.reg[inst.operands[0]] |= m.reg[inst.operands[1]];
        UpdateFlags(m.reg[inst.operands[0]]);
        break;
    case vm::Not:
        m.reg[inst.operands[0]] = ~m.reg[inst.operands[0]];
        UpdateFlags(m.reg[inst.operands[0]]);
        break;
    case vm::Add:
        m.reg[inst.operands[0]] += m.reg[inst.operands[1]];
        UpdateFlags(m.reg[inst.operands[0]]);
        break;
    case vm::Sub:
        m.reg[inst.operands[0]] -= m.reg[inst.operands[1]];
        UpdateFlags(m.reg[inst.operands[0]]);
        break;
    case vm::Mul:
        m.reg[inst.operands[0]] *= m.reg[inst.operands[1]];
        UpdateFlags(m.reg[inst.operands[0]]);
        break;
    case vm::Div:
        m.reg[inst.operands[0]] /= m.reg[inst.operands[1]];
        UpdateFlags(m.reg[inst.operands[0]]);
        break;
    case vm::Mod:
        m.reg[inst.operands[0]] %= m.reg[inst.operands[1]];
        UpdateFlags(m.reg[inst.operands[0]]);
        break;
    }

    if (m.verbose) {
        std::cout << "Estado após instrução:" << std::endl;
        std::cout << "\tPC = " << m.pc << std::endl;
        std::cout << "\tAP = " << m.sp << std::endl;
        std::cout << "\tPEP[zero] = " << m.psw[0] << std::endl;
        std::cout << "\tPEP[negativo] = " << m.psw[1] << std::endl;
        for (size_t i = 0; i < m.reg.size(); i++)
            std::cout << "\tR[" << i << "] = " << m.reg[i] << std::endl;
    }

    return halt;
}
