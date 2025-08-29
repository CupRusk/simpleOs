#!/bin/bash

# 1️⃣ Собираем bootloader
nasm -f bin boot.asm -o boot.bin

# 2️⃣ Собираем ядро
gcc -m32 -ffreestanding -c kernel.c -o kernel.o
ld -m elf_i386 -Ttext 0x1000 -e kmain kernel.o -o kernel.elf
objcopy -O binary kernel.elf kernel.bin

# 3️⃣ Создаём пустой флоппи-образ
dd if=/dev/zero of=os-image.bin bs=512 count=2880

# 4️⃣ Копируем bootloader
dd if=boot.bin of=os-image.bin bs=512 count=1 conv=notrunc

# 5️⃣ Копируем ядро
dd if=kernel.bin of=os-image.bin bs=512 seek=1 conv=notrunc

# 6️⃣ Чистим временные файлы
rm -f boot.bin kernel.o kernel.elf kernel.bin

# 7️⃣ Запускаем QEMU
qemu-system-i386 -drive format=raw,file=os-image.bin -monitor stdio
