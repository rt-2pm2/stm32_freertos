# Documentation

## Introduction
This project is focused on getting confident with low level OS management on embedded devices.
Precisely, the focus is on ARM powered microcontrollers hosting FreeRTOS.

## Components
The implementation of the system is subdivided into two parts.
1)  Basic "runtime system" and drivers to get access to system peripherals and CPU;
2)  OS support

### Runtime System
The runtime system is provided by ARM with the CMSIS-Core. This is the minimum to have a baremetal application running on the embedded board.
CMSIS provides the low level abstraction layer for accessing the microprocessor. It also provides libraries for Math, DSP and NN.
The CMSIS-Core library is generic and ARM provides guideliness for vendors to support their MCUs.
The vendor of the MCU provides the customized files to have a baremetal runtime system on their hardware implementations.

The runtime system is build from 3 set of files:
1) Startup file
2) System configuration files
3) Device header file

...(continue)

### OS
The core RTOS code is contained in three files, which are called called tasks.c, queue.c and list.c.
Their are necessary to have a functional application.

There are also extra files to implement other functionalities.
If you need software timer functionality, then add kernel/timers.c to your project.
If you need event group functionality, then add kernel/event_groups.c to your project.
If you need stream buffer or message buffer functionality, then add kernel/stream_buffer.c to your project.
If you need co-routine functionality, then add kernel/croutine.c to your project (note co-routines are deprecated and not recommended for new designs).


## Configuration File
FreeRTOS is customised using a configuration file called FreeRTOSConfig.h.
Every FreeRTOS application must have a FreeRTOSConfig.h header file in its pre-processor include path.
FreeRTOSConfig.h tailors the RTOS kernel to the application being built.
It is therefore specific to the application, not the RTOS, and should be located in an application directory, not in one of the RTOS kernel source code directories.

...(continue)
