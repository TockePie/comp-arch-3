.syntax unified
.cpu cortex-m4
.thumb

.section .interrupt_vector
vtable_kernel:
    .word __stack_start
    .word __kernel_reset__ + 1

.section .rodata
    msg_kernel: .asciz "kernel started!\n"
    msg_res:    .asciz "Result: "

.section .text
__kernel_reset__:
    ldr r0, =msg_kernel
    bl dbgput_line

    mov r0, #4
    bl factorial
    mov r3, r0

    ldr r0, =msg_res
    bl dbgput
    mov r0, r3
    bl dbgput_num
loop:
    b loop

factorial:
    push {r1}
    mov r1, r0
    mov r0, #1
fact_loop:
    cmp r1, #1
    ble fact_done
    mul r0, r0, r1
    sub r1, r1, #1
    b fact_loop
fact_done:
    pop {r1}
    bx lr
