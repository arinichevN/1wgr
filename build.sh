#!/bin/bash

APP=1wgr
APP_DBG=`printf "%s_dbg" "$APP"`
INST_DIR=/usr/sbin


MODE_DEBUG=-DMODE_DEBUG

#PLATFORM=-DPLATFORM_ANY
#PLATFORM=-DPLATFORM_A20
PLATFORM=-DPLATFORM_H3

NONE=-DNONEANDNOTHING

function move_bin {
	([ -d $INST_DIR ] || mkdir $INST_DIR) && \
	cp $APP $INST_DIR/$APP && \
	chmod a+x $INST_DIR/$APP && \
	chmod og-w $INST_DIR/$APP && \
	echo "Your $APP executable file: $INST_DIR/$APP";
}
function build_lib {
	gcc $1 $PLATFORM -c timef.c && \
	gcc $1 $PLATFORM -c crc.c && \
	gcc $1 $PLATFORM -c gpio.c && \
	gcc $1 $PLATFORM -c 1w.c && \
	gcc $1 $PLATFORM -c ds18b20.c && \

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
	gcc -D_REENTRANT $1 $PLATFORM main.c -o $2 -lpthread -L./lib -lpac && \
	echo "Application successfully compiled. Launch command: sudo ./"$APP
}

function full {
	build $MODE_DEBUG $APP && \
	move_bin
}

f=$1
${f}