.global lab1
.syntax unified
.cpu cortex-m4
.thumb

#define A #10
#define B #6
#define C #4

lab1:
    push {lr}

    mov r0, A
    mov r1, B
    add r2, r0, r1
    lsr r2, r2, #1      

    
    mov r0, C           
    bl factorial        
    add r0, r0, r2     
    pop {pc}

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