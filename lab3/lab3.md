# Лабораторна робота №3

## Відомості

### Тема

Завантажувач основної програми. Обробка виключень. Вивід даних на відлагоджувальний порт або консоль

### Мета

Навчитися працювати з оперативною пам'яттю, використовувати виключення процесора Cortex-M4 та створити мінімальний завантажувач системи

### Варіант 10

```bash
> console.log((3210 % 16))
10
```

- Команди: `LDRH`, `STRH`.
- Тип адресації: Декремент.
- Зсув: Числовий, 2 байти.
- Особливість: Для декрементної адресації спочатку обчислюється різниця адрес початку та кінця програми, яка додається до адреси початку RAM для копіювання «з кінця в початок».

## Хід роботи

### Підготовка середовища

#### Dockerfile

```Dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    qemu-system-arm \
    make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
```

#### docker-compose.yaml

```yaml
services:
  lab3:
    build: .
    volumes:
      - .:/app
    container_name: "kradozhon-io32-lab3"
    stdin_open: true
    tty: true
    command: /bin/bash
```

#### Будуємо образ

```bash
$ docker compose build
...
```

### Збірка проєкту

#### bootloader.S

```S
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
```

#### kernel.S

```S
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
```

#### Makefile

```Makefile
CPU_CC = cortex-m4
CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
CFLAGS = -mthumb -mcpu=cortex-m4 -g -x assembler-with-cpp
LDFLAGS = -T lscript.ld -nostdlib --specs=nosys.specs

all: firmware.bin

kernel.bin:
 $(CC) -x assembler-with-cpp $(CFLAGS) -mcpu=$(CPU_CC) -c kernel.S -o kernel.o
 $(CC) -x assembler-with-cpp $(CFLAGS) -mcpu=$(CPU_CC) -c print.S -o print.o
 $(CC) -mcpu=$(CPU_CC) -nostdlib -T./lscript_kernel.ld -o kernel.elf kernel.o print.o
 $(OBJCOPY) -O binary kernel.elf kernel.bin

firmware.elf: bootloader.S start.S print.S kernel.bin
 $(CC) $(CFLAGS) $(LDFLAGS) bootloader.S start.S print.S -o firmware.elf

firmware.bin: firmware.elf
 $(OBJCOPY) -O binary firmware.elf firmware.bin

qemu_run: firmware.elf
 qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -nographic -semihosting -kernel firmware.elf

qemu: firmware.elf
 qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -nographic -semihosting -kernel firmware.elf -S -gdb tcp::1234

clean:
 rm -f *.o *.elf *.bin
```

Усі інші файли було взято з репозиторію та попередньої лабораторної роботи
<https://github.com/Igor1101/CompArch2STM32/tree/master/lab2>

### Виконання проєкту

```bash
$ docker compose up -d
[+] up 2/2
 ✔ Network lab3_default             Created                      0.1s
 ✔ Container kradozhon-io32-lab3    Created                      0.2s
$ docker compose exec lab3 bash
root@382bc29a01a0:/app#
```

```bash
root@382bc29a01a0:/app# make clean
rm -f *.o *.elf *.bin
root@382bc29a01a0:/app# make
arm-none-eabi-gcc -x assembler-with-cpp -mthumb -mcpu=cortex-m4 -g -x assembler-with-cpp -mcpu=cortex-m4 -c kernel.S -o kernel.o
arm-none-eabi-gcc -x assembler-with-cpp -mthumb -mcpu=cortex-m4 -g -x assembler-with-cpp -mcpu=cortex-m4 -c print.S -o print.o
arm-none-eabi-gcc -mcpu=cortex-m4 -nostdlib -T./lscript_kernel.ld -o kernel.elf kernel.o print.o
arm-none-eabi-objcopy -O binary kernel.elf kernel.bin
arm-none-eabi-gcc -mthumb -mcpu=cortex-m4 -g -x assembler-with-cpp -T lscript.ld -nostdlib --specs=nosys.specs bootloader.S start.S print.S -o firmware.elf
arm-none-eabi-objcopy -O binary firmware.elf firmware.bin
root@382bc29a01a0:/app# make qemu_run
qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -nographic -semihosting -kernel firmware.elf
starting

bootloader started

kernel started!

Result: 0x00000018
```

0x18 (HEX) = 24 (DEC), що є факторіалом числа 4, розрахованим у ядрі.

## Висновки

Під час виконання лабораторної роботи я набув практичних навичок роботи з оперативною пам'яттю та реалізації завантажувача системи, що забезпечує перенесення коду в RAM для його подальшого виконання. Використання механізму Semihosting та інструкції ВКРТ дозволило налагодити ефективний вивід відлагоджувальної інформації безпосередньо в консоль хост-комп'ютера. Особливу увагу було приділено роботі з векторною таблицею переривань для коректної ініціалізації покажчика стека та переходу до обробника Reset у завантаженій програмі. Практична реалізація алгоритму копіювання за варіантом №10 з використанням інструкцій LDRH та STRH з декрементною адресацією підтвердила розуміння принципів низькорівневого доступу до пам'яті та механізмів управління станом процесора Cortex-M4.

## Github

<https://github.com/TockePie/comp-arch-3/tree/main/lab3>
