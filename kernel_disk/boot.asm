; Bootloader для запуска 32-битного ядра на C
; 1. Сначала процессор запускается в 16-битном real mode
; 2. Bootloader загружается по адресу 0x7C00 - это место в ОЗУ, куда BIOS копирует MBR
; 3. Инициализируем сегменты и стек для реального режима
; 4. Включаем линию A20 (позволяет адресовать память выше 1 МБ)
; 5. Настраиваем GDT и переключаемся в 32-битный protected mode
; 6. В 32-битном режиме настраиваем сегменты, стек и вызываем ядро (kmain)


bits 16

[org 0x7C00]  

global _start
extern kmain

gdt_start:
    dq 0x0000000000000000       ; Null descriptor
    dq 0x00CF9A000000FFFF       ; Code segment
    dq 0x00CF92000000FFFF       ; Data segment
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00 

    in al, 0x92
    or al, 00000010b
    out 0x92, al

    ; Загружаем GDT
    lgdt [gdt_descriptor]

    ; Включаем Protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp CODE_SEG:init_pm ; дальний прыжок в 32-битный код

[bits 32]
; друзья! Вот мы наконец в 32-битном режиме! (честно я заебался с 16-битным)

init_pm:
    ; Инициализация сегментов
    mov eax, 0x10
    mov ds, eax
    mov es, eax
    mov fs, eax
    mov gs, eax
    mov ss, eax
    mov esp, 0x9FC00

    call kmain
