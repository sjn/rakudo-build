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

rakudo-checkout:
	cd ${SRCDIR}/rakudo; \
	git checkout master; \
	git pull; \
	git checkout --detach $(shell GIT_DIR=${SRCDIR}/rakudo/.git git describe --abbrev=0 --tags); \
	sleep 3;

rakudo: rakudo-checkout
	cd ${SRCDIR}/rakudo; \
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

zef-checkout:
	cd ${SRCDIR}/zef; \
	git checkout master; \
	git pull; \
	git checkout --detach $(shell GIT_DIR=${SRCDIR}/zef/.git git describe --abbrev=0 --tags); \
	sleep 3;

zef: zef-checkout
	cd ${SRCDIR}/zef; \
	${SRCDIR}/rakudo/install/bin/perl6 -I. bin/zef install .
