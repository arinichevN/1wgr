
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#include "lib/gpio.h"
#include "lib/1w.h"
#include "lib/ds18b20.h"

#define RETRY_COUNT 5

void setPriorityMax(int policy) {
    int max = sched_get_priority_max(policy);
    if (max == -1) {
        perror("sched_get_priority_max() failed");
        return;
    }
    struct sched_param sp;
    memset(&sp, 0, sizeof sp);
    sp.__sched_priority = max;
    int ret = sched_setscheduler(0, policy, &sp);
    if (ret == -1) {
        perror("sched_setscheduler() failed");
    }
}

void secure(int pin) {
#ifndef PLATFORM_ANY
    pinModeOut(pin);
    pinHigh(pin);
#endif
}

int main(int argc, char** argv) {
    if (mlockall(MCL_CURRENT | MCL_FUTURE) == -1) {
        perror("main: memory locking failed");
    }
    //setPriorityMax(SCHED_FIFO);
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


#ifndef PLATFORM_ANY

    if (!checkPin(pin)) {
        fputs("Bad pin number\n", stderr);
        return (EXIT_FAILURE);
    }
    int i;
    uint8_t rom[DS18B20_SCRATCHPAD_BYTE_NUM];
    if (!gpioSetup()) {
        fputs("gpioSetup failed\n", stderr);
        return (EXIT_FAILURE);
    }
    pinModeOut(pin);
    int done = 0;
    for (i = 0; i < RETRY_COUNT; i++) {
        uint8_t rom_t1[DS18B20_SCRATCHPAD_BYTE_NUM];
        uint8_t rom_t2[DS18B20_SCRATCHPAD_BYTE_NUM];
        if (!onewire_read_rom(pin, rom)) {
            fputs("Read failed\n", stderr);
            secure(pin);
            return (EXIT_FAILURE);
        }
        delayUsIdle(100);
        if (!onewire_read_rom(pin, rom_t1)) {
            fputs("Read failed\n", stderr);
            secure(pin);
            return (EXIT_FAILURE);
        }
        delayUsIdle(100);
        if (!onewire_read_rom(pin, rom_t2)) {
            fputs("Read failed\n", stderr);
            secure(pin);
            return (EXIT_FAILURE);
        }

        int j;
        for (j = 0; j < DS18B20_SCRATCHPAD_BYTE_NUM; j++) {
            if (rom[j] != rom_t1[j] || rom[j] != rom_t2[j]) {
                continue;
            }
        }
        done = 1;
        break;
    }
    secure(pin);
    if (!done) {
        fputs("different values, no more retry\n", stderr);
        return (EXIT_FAILURE);
    }
    for (i = 0; i < DS18B20_SCRATCHPAD_BYTE_NUM; i++) {
        printf("%.2hhx", rom[i]);
    }
    putchar('\n');
#else
    puts("1w not supported");
#endif

    return (EXIT_SUCCESS);
}

