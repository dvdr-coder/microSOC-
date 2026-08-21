CROSS_COMPILE ?= riscv64-unknown-elf-
CC             = $(CROSS_COMPILE)gcc
OBJCOPY        = $(CROSS_COMPILE)objcopy

VERILATOR = verilator
VFLAGS    = --timing --trace --cc --exe --build -j 0 \
            -Irtl -Itb tb/uvm_lite_pkg.sv tb/tb_top.sv tb/verilator_main.cpp \
            --top-module tb_top

all: firmware.hex sim

firmware.elf: sw/start.S sw/firmware.c sw/link.ld
	$(CC) -march=rv32i -mabi=ilp32 -T sw/link.ld -nostdlib -O2 sw/start.S sw/firmware.c -o $@

firmware.hex: firmware.elf
	$(OBJCOPY) -O verilog $< $@

sim: firmware.hex
	$(VERILATOR) $(VFLAGS)
	./obj_dir/Vtb_top +MEM_FILE=firmware.hex

clean:
	rm -rf obj_dir firmware.elf firmware.hex
