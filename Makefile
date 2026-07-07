RISCV_PREFIX ?= /home/nguyen-van-thuc/ic_workspace/soc_workspace_pro/framework/xpack-riscv-none-elf-gcc-15.2.0-1/bin/riscv-none-elf

CC      := $(RISCV_PREFIX)-gcc
OBJCOPY := $(RISCV_PREFIX)-objcopy

CFLAGS  := -march=rv32i -mabi=ilp32
CFLAGS  += -Os -ffreestanding -nostdlib -fno-builtin
CFLAGS  += -fno-pic -fno-pie
CFLAGS  += -Wall -Wextra

LDFLAGS := -T firmware/linker/linker.ld
LDFLAGS += -nostdlib
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=sim/output/firmware.map

FW_ELF := sim/output/firmware.elf
FW_BIN := sim/output/firmware.bin
FW_HEX := sim/memory/firmware.hex

RTL_SRCS := \
	third_party/vexriscv/VexRiscv.v \
	rtl/soc/wb_ram_dp.v \
	rtl/soc/wb_decoder.v \
	rtl/ai/cnn_mini/wb_cnn_mini.v \
	rtl/soc/soc_top.v \
	tb/tb_soc.v

SIM_OUT := sim/output/tb_soc.vvp

all: sim

firmware: $(FW_HEX)

$(FW_ELF): firmware/startup/start.S firmware/src/main.c firmware/linker/linker.ld
	mkdir -p sim/output sim/memory
	$(CC) $(CFLAGS) firmware/startup/start.S firmware/src/main.c firmware/src/runtime.c $(LDFLAGS) -o $(FW_ELF)

$(FW_BIN): $(FW_ELF)
	$(OBJCOPY) -O binary $(FW_ELF) $(FW_BIN)

$(FW_HEX): $(FW_BIN)
	python3 scripts/bin2hex32.py $(FW_BIN) $(FW_HEX)

build: $(FW_HEX)
	mkdir -p sim/output
	iverilog -g2012 -o $(SIM_OUT) $(RTL_SRCS)

sim: build
	vvp $(SIM_OUT)

wave:
	gtkwave sim/output/soc.vcd

clean:
	rm -rf sim/output/*
	rm -f sim/memory/firmware.hex

.PHONY: all firmware build sim wave clean
