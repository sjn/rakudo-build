SRCDIR  := ${HOME}/src
SNAPDIR := ${SRCDIR}/rakudo-update

#RAKUDO=git@github.com:rakudo/rakudo.git
RAKUDO  := https://github.com/rakudo/rakudo.git
#ZEF=git@github.com:ugexe/zef.git
ZEF     := https://github.com/ugexe/zef.git

PATH    := ${PATH}:${SRCDIR}/rakudo/install/bin/perl6

all: clone rakudo zef

clone:
	mkdir -p ${SRCDIR}; \
	cd ${SRCDIR}; \
	GIT_DIR=${SRCDIR}/zef/.git git rev-parse --git-dir || git clone ${ZEF}; \
	GIT_DIR=${SRCDIR}/rakudo/.git git rev-parse --git-dir || git clone ${RAKUDO};

rakudo-pull:
	cd ${SRCDIR}/rakudo; \
	git checkout master; \
	git pull; \
	sleep 3;

rakudo: rakudo-pull
	cd ${SRCDIR}/rakudo; \
	git checkout --detach $(shell GIT_DIR=${SRCDIR}/rakudo/.git git describe --abbrev=0 --tags); \
	perl Configure.pl --gen-moar --gen-nqp --backends=moar; \
	make clean; \
	make ; \
	make test; \
	make install

snap:
	zef install App::ModuleSnap
	p6-module-snapshot --directory=${SNAPDIR}/.snap

unsnap:
	cd ${SNAPDIR}; \
	zef install .

zef-pull:
	cd ${SRCDIR}/zef; \
	git checkout master; \
	git pull; \
	sleep 3;

zef: zef-pull
	cd ${SRCDIR}/zef; \
	git checkout --detach $(shell GIT_DIR=${SRCDIR}/zef/.git git describe --abbrev=0 --tags); \
	${SRCDIR}/rakudo/install/bin/perl6 -I. bin/zef install .
