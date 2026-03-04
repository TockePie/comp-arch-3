.syntax unified
.cpu cortex-m4
.thumb

.global bootload
.section .rodata
image: .incbin "kernel.bin"
end_of_image:

str_boot_start: .asciz "bootloader started\n"

.section .text
bootload:
    ldr r0, =str_boot_start
    bl dbgput_line

    ldr r0, =image
    ldr r1, =end_of_image

    sub r4, r1, r0
    ldr r2, =_ram_start
    add r2, r2, r4

copy_loop:
    ldrh r3, [r1, #-2]!
    strh r3, [r2, #-2]!
    cmp r1, r0
    bhi copy_loop

    ldr r2, =_ram_start
    add r2, #4
    ldr r0, [r2]
    bx r0
