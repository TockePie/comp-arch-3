MEMORY
{
    FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 1024K
    RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 128K
}

/* Визначаємо початкову адресу стеку (кінець RAM) */
_stack_start = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
    .text :
    {
        KEEP(*(.vtable)) /* Таблиця векторів має бути першою */
        *(.text)
        *(.text*)
    } > FLASH

    .data :
    {
        *(.data)
    } > RAM AT > FLASH

    .bss :
    {
        *(.bss)
    } > RAM
}
