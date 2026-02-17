CC = arm-none-eabi-gcc
LD = arm-none-eabi-ld

CFLAGS = -mthumb -mcpu=cortex-m4 -g -x assembler-with-cpp
LDFLAGS = -T lscript.ld

all: firmware.elf

firmware.elf: start.o lab1.o
	$(LD) $(LDFLAGS) start.o lab1.o -o firmware.elf

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f *.o *.elf

qemu: firmware.elf
	qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -nographic -kernel firmware.elf -S -gdb tcp::1234
