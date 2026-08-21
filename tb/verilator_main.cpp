#include <iostream>
#include "Vtb_top.h"
#include "verilated.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vtb_top* top = new Vtb_top;

    top->clk = 0;
    top->rst_n = 0;

    // Run 10 clock cycles in reset
    for (int i = 0; i < 20; ++i) {
        top->clk = !top->clk;
        top->eval();
    }
    top->rst_n = 1;

    // Run active simulation
    while (!Verilated::gotFinish()) {
        top->clk = !top->clk;
        top->eval();
    }

    delete top;
    return 0;
}
