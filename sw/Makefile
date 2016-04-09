
CROSS_COMPILE ?= lm32-elf-

# classic cross-compilation tool-set
AS		= $(CROSS_COMPILE)as
LD		= $(CROSS_COMPILE)ld
CC		= $(CROSS_COMPILE)gcc
CPP		= $(CC) -E
AR		= $(CROSS_COMPILE)ar
NM		= $(CROSS_COMPILE)nm
STRIP		= $(CROSS_COMPILE)strip
OBJCOPY		= $(CROSS_COMPILE)objcopy
OBJDUMP		= $(CROSS_COMPILE)objdump


CFLAGS += -ffreestanding -Os  \
	-ffunction-sections -fdata-sections \
	-mmultiply-enabled -mbarrel-shift-enabled \
	-I./pp_printf/                \
	-I./include/                  \
	-I./include/std               \
	-I./dev/                      \
	-I./shell/                    \
	

LDFLAGS = -nostdlib -static -T spec.lds -T bigobj.lds

ALL = $(patsubst %.c, %.bin, $(wildcard *.c))

%.bin: %
	$(OBJCOPY) -O binary $* $*.bin

#all: $(ALL)
all: pprint yapr $(ALL)

pprint:
	$(MAKE) -C ./pp_printf/

yapr:   crt0.o yapr.o ./dev/uart.o ./lib/util.o ./pp_printf/vsprintf-full.o ./pp_printf/printf.o \
	./shell/shell.o ./shell/cmd_help.o ./shell/cmd_dump.o ./shell/cmd_write.o
	$(CC) $(LDFLAGS) $^ -o $@
	
clean:
	rm -f $(ALL) *.o *~
	rm -f ./dev/*.o *~
	rm -f ./lib/*.o *~
	rm -f ./pp_printf/*.o *~
	rm -f ./shell/*.o *~