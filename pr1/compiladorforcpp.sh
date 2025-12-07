#!/bin/bash
set -e
source /mnt/vol_NFS_rh003/Est_Digitales_2S_2025/materiales/riscv_tools_setup.sh
export PATH=$PATH:/mnt/vol_NFS_rh003/Est_Digitales_2S_2025/materiales/tools_riscv/bin

SRC="${1:-bubbleSort.cpp}"
OUT="${2:-bubbleSort}"

echo ">> Copilando $SRC -> $OUT.elf"
riscv32-unknown-elf-g++ -march=rv32im -mabi=ilp32 -O2 -o "$OUT.elf" "$SRC"

echo ">> Generando binario y dump"
riscv32-unknown-elf-objcopy -O binary "$OUT.elf" "$OUT.bin"
riscv32-unknown-elf-objdump -d -M no-aliases,numeric "$OUT.elf" > "$OUT.asm"

echo "Listo: $OUT.elf, $OUT.bin, $OUT.asm"


