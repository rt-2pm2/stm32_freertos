# Makefile for the project
# =====================================

# Define the shell
SHELL = /bin/bash

target := freertos
compiler := clang
arch := ARM_CM4F 

# Toolchain
# ARM gcc toolchain
#CROSS_COMPILE = llvm-
SIZE = arm-none-eabi-size
OBJCOPY = arm-none-eabi-objcopy
GDB = arm-none-eabi-gdb

AS = arm-none-eabi-as 
CC = arm-none-eabi-gcc 
LD = arm-none-eabi-gcc

# Defines
cdefs = -DUSE_STDPERIPH_DRIVER
cdefs += -DSTM32F4XX
cdefs += -DSTM32F40_41xxx
cdefs += -DHSE_VALUE=8000000
cdefs += -D__FPU_PRESENT=1
cdefs += -DARM_MATH_CM4


# Optimization level, can be [0, 1, 2, 3, s].
optlvl:=0
dbg:=-g

mcuflags = -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -fsingle-precision-constant \
		   -mfpu=fpv4-sp-d16 -finline-functions -Wdouble-promotion -std=gnu99

commonflags = -o$(optlvl) $(dbg) -Wall -ffunction-sections -fdata-sections

LDLIBS = -lm -lc -lgcc
LDFLAGS = $(mcuflags) -u _scanf_float -u _printf_float -fno-exceptions \
		  -Wl,--gc-sections,-T$(linker_script),-Map,$(bin_dir)/$(target).map



# =====================================================================
# Project Folders
freertos_krnl := FreeRTOS/kernel
freertos_port :=  FreeRTOS/portable/$(compiler)/$(arch)
freertos_port_mem :=  FreeRTOS/portable/MemMang/
startup := armlib/Device/Startup

stm32_driver := armlib/CMSIS/Driver
stm32_device := armlib/Device

include_dirs := $(sort $(dir $(shell find ./ -type f -name "*.h")))
src_dirs := $(sort $(dir $(shell find ./ -type f -name "*.c")))

build_dir = build
bin_dir = binary

vpath %.c $(src_dirs)
vpath %.s $(dir $(startup))


# =============================================================================
include := $(addprefix -I, $(include_dirs))


# ============================================================================== 
# Source files

# Project Source Files#
main_src = main.c

# Stm32 System Source Files
stm32system_src = $(shell find $(stm32_device) -type f -name "*.c")

# freertos source files
freertos_src = $(shell find $(freertos_krnl) -type f -name "*.c")
freertos_src += $(shell find $(freertos_port) -type f -name "*.c")
freertos_src += $(freertos_port_mem)

# Standard Peripheral Source Files
stm32peripheral_src = misc.c
stm32peripheral_src += stm32f4xx_dcmi.c
stm32peripheral_src += stm32f4xx_rtc.c
stm32peripheral_src += stm32f4xx_adc.c
stm32peripheral_src += stm32f4xx_dma.c
stm32peripheral_src += stm32f4xx_sai.c
stm32peripheral_src += stm32f4xx_can.c
stm32peripheral_src += stm32f4xx_dma2d.c
stm32peripheral_src += stm32f4xx_sdio.c
stm32peripheral_src += stm32f4xx_cec.c
stm32peripheral_src += stm32f4xx_dsi.c
stm32peripheral_src += stm32f4xx_i2c.c
stm32peripheral_src += stm32f4xx_spdifrx.c
stm32peripheral_src += stm32f4xx_crc.c
stm32peripheral_src += stm32f4xx_exti.c
stm32peripheral_src += stm32f4xx_iwdg.c
stm32peripheral_src += stm32f4xx_spi.c
stm32peripheral_src += stm32f4xx_flash.c
stm32peripheral_src += stm32f4xx_lptim.c
stm32peripheral_src += stm32f4xx_syscfg.c
stm32peripheral_src += stm32f4xx_flash_ramfunc.c
stm32peripheral_src += stm32f4xx_ltdc.c
stm32peripheral_src += stm32f4xx_tim.c
stm32peripheral_src += stm32f4xx_pwr.c
stm32peripheral_src += stm32f4xx_usart.c
stm32peripheral_src += stm32f4xx_fmpi2c.c
stm32peripheral_src += stm32f4xx_qspi.c
stm32peripheral_src += stm32f4xx_wwdg.c
stm32peripheral_src += stm32f4xx_dac.c
stm32peripheral_src += stm32f4xx_fsmc.c
stm32peripheral_src += stm32f4xx_rcc.c
stm32peripheral_src += stm32f4xx_dbgmcu.c
stm32peripheral_src += stm32f4xx_gpio.c
stm32peripheral_src += stm32f4xx_rng.c

src_all := $(notdir $(stm32peripheral_src) $(freertos_src) $(stm32system_src) $(main_src))

linker_script := armlib/Device/linker.ld
startup_file = startup_stm32f40xx.s

CFLAGS = $(commonflags) $(mcuflags) $(include) $(cdefs)

# List the object files
obj = $(src_all:%.c=$(build_dir)/%.o)

required_dirs = build binary
_MKDIRS := $(shell for d in $(required_dirs); \
		do \
		  [[ -d $$d ]] || mkdir -p $$d; \
		done)

# ==============================================================================
# RULES
$(build_dir)/%.o: %.c
	@echo [CC] $(notdir $<)
	@$(CC) $(CFLAGS) $< -c -o $@

all: $(bin_dir)/$(target).bin

$(bin_dir)/$(target).bin: $(obj)
	@echo [AS] $(startup_file)
	@$(AS) -o $(startup_file:%.s=$(build_dir)/%.o) $(startup)/$(startup_file)
	@echo [LD] $(target).elf
	@$(CC) -o $(bin_dir)/$(target).elf $(LDFLAGS) $(obj) $(startup_file:%.s=$(build_dir)/%.o) $(LDLIBS)
	@echo [HEX] $(target).hex
	@$(OBJCOPY) -O ihex $(bin_dir)/$(target).elf $(bin_dir)/$(target).hex
	@echo [BIN] $(target).bin
	@$(OBJCOPY) -O binary $(bin_dir)/$(target).elf $(bin_dir)/$(target).bin


# ==============================================================================
# HELPERS
.PHONY: clean
clean:
	@echo [RM] OBJ
	@rm -f $(obj)
	@rm -f $(startup_file:%.s=$(build_dir)/%.o)
	@echo [RM] BIN
	@rm -f $(bin_dir)/$(target).elf
	@rm -f $(bin_dir)/$(target).hex
	@rm -f $(bin_dir)/$(target).bin

.PHONY: flash
flash:
	@st-flash write $(bin_dir)/$(target).bin 0x8000000

.PHONY: listing
listing:
	@echo "SOURCE FILES = \n" $(src_all)
	@echo "\n"
	@echo "OBJ FILES = \n" $(obj)
	@echo "\n"
	@echo "SOURCE FOLDERS = \n" $(src_dirs)



