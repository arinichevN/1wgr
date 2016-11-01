#!/bin/bash

APP=1wgr
INST_DIR=/usr/sbin

function move_bin {
	([ -d $INST_DIR ] || mkdir $INST_DIR) && \
	cp bin $INST_DIR/$APP && \
	chmod a+x $INST_DIR/$APP && \
	chmod og-w $INST_DIR/$APP && \
	echo "Your $APP executable file: $INST_DIR/$APP";
}

#builds application for Allwinner A20 CPU
function for_a20_debug {
	cd lib && \
	./build.sh for_a20_debug && \
	cd ../ && \
	gcc -D_REENTRANT -DMODE_DEBUG -DP_A20 main.c -o bin -L./lib -lpac -lpthread && \
	echo "Application $APP successfully installed. Launch command: sudo ./bin"
}

#builds application for Allwinner A20 CPU
function for_a20 {
	cd lib && \
	./build.sh for_a20 && \
	cd ../ && \
	gcc -D_REENTRANT -DP_A20 main.c -o bin -L./lib -lpac  -lpthread && \
	move_bin && \
	echo "Application $APP successfully installed. Launch command: sudo $APP"
}


f=$1
${f}