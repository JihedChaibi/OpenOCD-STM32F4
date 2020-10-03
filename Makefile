            #################################################
            #        MAKEFILE FOR BUILDING THE BINARY       #
            #             AND FLASHING THE CHIP!            #
            #################################################

    # setup compiler and flags for stm32f373 build
    SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

    HEXFILE = ./first_test.hex
    ELFFILE = /home/geek-tn/Desktop/YO/STM32-with-no-IDE/output/first_test.elf


    CROSS_COMPILE ?= arm-none-eabi- 
    export CC = $(CROSS_COMPILE)gcc 
    export AS = $(CROSS_COMPILE)gcc -x assembler-with-cpp 
    export AR = $(CROSS_COMPILE)ar 
    export LD = $(CROSS_COMPILE)ld 
    export OD   = $(CROSS_COMPILE)objdump 
    export BIN  = $(CROSS_COMPILE)objcopy -O ihex 
    export SIZE = $(CROSS_COMPILE)size 
    export GDB =  gdb-multiarch


    MCU = cortex-m4
#FPU = -mfloat-abi=hard -mfpu=fpv4-sp-d16 -D__FPU_USED=1 -D__FPU_PRESENT=1 -DARM_MATH_CM4 
    DEFS = -DUSE_STDPERIPH_DRIVER -DSTM32F37X -DRUN_FROM_FLASH=1 -DHSE_VALUE=8000000 
    OPT ?= -O0  
    MCFLAGS = -mthumb -mcpu=$(MCU) 


    export ASFLAGS  = $(MCFLAGS) $(OPT) -g -gdwarf-2 $(ADEFS) 
    CPFLAGS += $(MCFLAGS) $(OPT) -gdwarf-2 -Wall -Wno-attributes -fverbose-asm  
    CPFLAGS += -ffunction-sections -fdata-sections $(DEFS) 
    export CPFLAGS 
    export CFLAGS += $(CPFLAGS) 


    export LDFLAGS  = $(MCFLAGS) -nostartfiles -Wl,--cref,--gc-sections,--no-warn-mismatch $(LIBDIR) 

	HINCDIR += ./STM32F37x_DSP_StdPeriph_Lib_V1.0.0/Libraries/CMSIS/Include/
	HINCDIR += ./STM32F37x_DSP_StdPeriph_Lib_V1.0.0/Libraries/CMSIS/Device/ST/STM32F37x/Include/ 
	HINCDIR += ./STM32F37x_DSP_StdPeriph_Lib_V1.0.0/Libraries/STM32F37x_StdPeriph_Driver/inc/
	HINCDIR += ./
    export INCDIR = $(patsubst %,$(SELF_DIR)%,$(HINCDIR)) 




    # openocd variables and targets 
    OPENOCD_PATH = /usr/share/openocd
    export OPENOCD_BIN = openocd
    export OPENOCD_BOARD = $(OPENOCD_PATH)/scripts/board/st_nucleo_f4.cfg
    export OPENOCD_INTERFACE = $(OPENOCD_PATH)/scripts/interface/stlink-v2.cfg 
    export OPENOCD_TARGET = $(OPENOCD_PATH)/scripts/target/stm32f3x_stlink.cfg 


############# FLASH #############

    OPENOCD_FLASH_CMDS += -c 'reset halt' 
    OPENOCD_FLASH_CMDS += -c 'sleep 10'  
    OPENOCD_FLASH_CMDS += -c 'flash protect 0 0 7 off' 
	OPENOCD_FLASH_CMDS += -c 'halt'
	OPENOCD_FLASH_CMDS += -c 'flash write_image erase $(HEXFILE) 0 ihex' 
	OPENOCD_FLASH_CMDS += -c shutdown 
    export OPENOCD_FLASH_CMDS 


############# ERASE #############

    OPENOCD_ERASE_CMDS += -c 'reset halt'
    OPENOCD_ERASE_CMDS += -c 'sleep 10'
    OPENOCD_ERASE_CMDS += -c 'sleep 10'
    OPENOCD_ERASE_CMDS += -c 'flash erase_address 0x08000000 0x00080000'
    OPENOCD_ERASE_CMDS += -c shutdown
    export OPENOCD_ERASE_CMDS


    OPENOCD_RUN_CMDS = '' 
    OPENOCD_RUN_CMDS += -c 'reset halt' 
    OPENOCD_RUN_CMDS += -c 'sleep 10' 
    OPENOCD_RUN_CMDS += -c 'reset run' 
    OPENOCD_RUN_CMDS += -c 'sleep 10'  
    OPENOCD_RUN_CMDS += -c shutdown 
    export OPENOCD_RUN_CMDS 


    OPENOCD_DEBUG_CMDS = '' 
    OPENOCD_DEBUG_CMDS += -c 'halt' 
    OPENOCD_DEBUG_CMDS += -c 'sleep 10' 


.flash:
	$(OPENOCD_BIN) -f $(OPENOCD_BOARD) -c init $(OPENOCD_FLASH_CMDS) 


.erase: 
	$(OPENOCD_BIN) -f $(OPENOCD_BOARD) -c init $(OPENOCD_ERASE_CMDS) 


.run: 
	$(OPENOCD_BIN) -f $(OPENOCD_INTERFACE) -f $(OPENOCD_TARGET) -c init $(OPENOCD_RUN_CMDS) 


.debug: 
	$(OPENOCD_BIN) -f $(OPENOCD_INTERFACE) -f $(OPENOCD_TARGET) -c init $(OPENOCD_DEBUG_CMDS) 
