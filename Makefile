SRCDIR=${HOME}/src
SNAPDIR=${SRCDIR}/rakudo-update

RAKUDO=git@github.com:rakudo/rakudo.git
ZEF=git@github.com:ugexe/zef.git

PATH:=${PATH}:${SRCDIR}/rakudo/install/bin/perl6

all: clone rakudo zef

clone:
	mkdir -p ${SRCDIR}; \
	cd ${SRCDIR}; \
	GIT_DIR=${SRCDIR}/zef/.git git rev-parse --git-dir || git clone ${ZEF}; \
	GIT_DIR=${SRCDIR}/rakudo/.git git rev-parse --git-dir || git clone ${RAKUDO};

rakudo:
	cd ${SRCDIR}/rakudo; \
	git checkout master; \
	git pull; \
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

zef:
	cd ${SRCDIR}/zef; \
	git pull; \
	${SRCDIR}/rakudo/install/bin/perl6 -I. bin/zef install .
