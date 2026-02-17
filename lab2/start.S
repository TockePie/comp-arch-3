.syntax unified
.cpu cortex-m4
.thumb

.global vtable
.type vtable, %object

vtable:
    .word _stack_start
    .word _hard_reset + 1 
.size vtable, . - vtable

.global _hard_reset
.type _hard_reset, %function

_hard_reset:
    bl lab1
_loop: 
    b _loop

.size _hard_reset, . - _hard_reset

