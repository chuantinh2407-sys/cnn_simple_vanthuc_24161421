OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

SECTIONS
{
    .text :
    {
        KEEP(*(.init))
        *(.text*)
        *(.rodata*)
    } > RAM

    .data :
    {
        *(.data*)
    } > RAM

    .bss :
    {
        _sbss = .;
        *(.bss*)
        *(COMMON)
        _ebss = .;
    } > RAM

    . = ALIGN(4);
    _end = .;

    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
