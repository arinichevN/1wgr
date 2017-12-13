#!/bin/bash

APP=1wgr
APP_DBG=`printf "%s_dbg" "$APP"`
INST_DIR=/usr/sbin


DEBUG_PARAM="-Wall -pedantic"
MODE_DEBUG=-DMODE_DEBUG
MODE_FULL=-DMODE_FULL

#CPU=-DCPU_ANY
#CPU=-DCPU_ALLWINNER_A20
CPU=-DCPU_ALLWINNER_H3
#CPU=-DCPU_CORTEX_A5

#PINOUT=-DPINOUT1
PINOUT=-DPINOUT2

NONE=-DNONEANDNOTHING

function move_bin {
	([ -d $INST_DIR ] || mkdir $INST_DIR) && \
	cp $APP $INST_DIR/$APP && \
	chmod a+x $INST_DIR/$APP && \
	chmod og-w $INST_DIR/$APP && \
	echo "Your $APP executable file: $INST_DIR/$APP";
}
function build_lib {
	gcc $1 $CPU -c timef.c $DEBUG_PARAM && \
	gcc $1 $CPU -c crc.c $DEBUG_PARAM && \
	gcc $1 $CPU $PINOUT -c gpio.c $DEBUG_PARAM && \
	gcc $1 $CPU -c 1w.c $DEBUG_PARAM && \
	gcc $1 $CPU -c ds18b20.c $DEBUG_PARAM && \

	echo "library: making archive..." && \
	rm -f libpac.a
	ar -crv libpac.a 1w.o crc.o gpio.o timef.o ds18b20.o && \
	echo "library: done"
	rm -f *.o acp/*.o
}

function build {
	cd lib && \
	build_lib $1 && \
	cd ../ && \
	gcc -D_REENTRANT $1 $3 $CPU main.c -o $2 $DEBUG_PARAM -lpthread -L./lib -lpac && \
	echo "Application successfully compiled. Launch command: sudo ./"$2
}

function full {
	build $MODE_DEBUG $APP && \
	move_bin
}

function full {
	build $NONE $APP $MODE_FULL && \
	move_bin
}

function uninstall {
	rm -v $INST_DIR/$APP
}

f=$1
${f}