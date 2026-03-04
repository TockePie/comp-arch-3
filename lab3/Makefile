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
