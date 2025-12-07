#!/bin/bash
set -e

source /mnt/vol_NFS_rh003/Est_Digitales_2S_2025/materiales/riscv_tools_setup.sh
export PATH=$PATH:/mnt/vol_NFS_rh003/Est_Digitales_2S_2025/materiales/tools_riscv/bin

echo ">>Copilando Snake >>"
riscv32-unknown-elf-as -o snake.o snake.S
riscv32-unknown-elf-ld -o snake.elf snake.o
riscv32-unknown-elf-objcopy -O binary snake.elf snake.bin
riscv32-unknown-elf-objdump -d snake.elf > snake.asm 

echo "Compilacion completa: snake.elf y snake.bin generados"

