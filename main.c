
#include <stdio.h>
#include <stdlib.h>

#include "lib/app.h"
#include "lib/gpio.h"
#include "lib/1w.h"
#include "lib/ds18b20.h"

int main(int argc, char** argv) {
    if (mlockall(MCL_CURRENT | MCL_FUTURE) == -1) {
        perror("main: memory locking failed");
    }
    setPriorityMax(SCHED_FIFO);
    int pin;
    if (argc != 2) {
        fputs("Usage: prog_name pin\n", stderr);
        fputs(" where pin is physical pin number\n", stderr);
        return (EXIT_FAILURE);
    }
    if (sscanf(argv[1], "%d", &pin) != 1) {
        fputs("Bad argument\n", stderr);
        return (EXIT_FAILURE);
    }
    if (!checkPin(pin)) {
        fputs("Bad pin number\n", stderr);
        return (EXIT_FAILURE);
    }

#ifdef P_A20
    int i;
    uint8_t rom[DS18B20_SCRATCHPAD_BYTE_NUM];
     if (!gpioSetup()) {
        fputs("gpioSetup failed\n", stderr);
        return (EXIT_FAILURE);
    }
    pinModeOut(pin);
    if (!onewire_read_rom(pin, rom)) {
        fputs("Read failed\n", stderr);
        return (EXIT_FAILURE);
    }
    //printf("%d\t", pin);
    for (i = 0; i < DS18B20_SCRATCHPAD_BYTE_NUM; i++) {
        printf("%.2hhx", rom[i]);
    }
    putchar('\n');
#endif
    
    return (EXIT_SUCCESS);
}

