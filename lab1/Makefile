SDK_PREFIX = arm-none-eabi-
CC      = $(SDK_PREFIX)gcc
OBJCOPY = $(SDK_PREFIX)objcopy
QEMU    = qemu-system-gnuarmeclipse

BOARD  = STM32F4-Discovery
MCU    = STM32F407VG
TARGET = firmware

all: target

target:
	$(CC) -x assembler-with-cpp -c -O0 -g3 -mcpu=cortex-m4 -mthumb -Wall start.S -o start.o
	$(CC) start.o -mcpu=cortex-m4 -mthumb -Wall --specs=nosys.specs -nostdlib -lgcc -T./lscript.ld -o $(TARGET).elf
	$(OBJCOPY) -O binary $(TARGET).elf $(TARGET).bin

qemu:
	$(QEMU) --board $(BOARD) --mcu $(MCU) -d unimp,guest_errors --image $(TARGET).bin --semihosting-config enable=on,target=native -s -S -nographic

clean:
	rm -f *.o *.elf *.bin
