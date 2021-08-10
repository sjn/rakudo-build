SRCDIR  := ${HOME}/src
SNAPDIR := ${SRCDIR}/rakudo-update
TARGET  := ${HOME}/rakudo

#RAKUDO=git@github.com:rakudo/rakudo.git
RAKUDO  := https://github.com/rakudo/rakudo.git
#ZEF=git@github.com:ugexe/zef.git
ZEF     := https://github.com/ugexe/zef.git

PATH    := ${PATH}:${TARGET}/bin:${SRCDIR}/rakudo/install/bin/rakudo

all: clone rakudo zef

clone:
	mkdir -p ${SRCDIR}; \
	cd ${SRCDIR}; \
	GIT_DIR=${SRCDIR}/zef/.git git rev-parse --git-dir || git clone ${ZEF}; \
	GIT_DIR=${SRCDIR}/rakudo/.git git rev-parse --git-dir || git clone ${RAKUDO};

rakudo-pull:
	cd ${SRCDIR}/rakudo; \
	git pull --ff-only origin master; \
	sleep 3;

rakudo: rakudo-pull
	cd ${SRCDIR}/rakudo; \
	git checkout --detach $(shell GIT_DIR=${SRCDIR}/rakudo/.git git describe --abbrev=0 --tags); \
	make clean; \
	perl Configure.pl --gen-moar --gen-nqp --backends=moar --prefix=${TARGET}; \
	make ; \
	make test; \
	make install

snap:
	zef install App::ModuleSnap
	raku-module-snapshot --directory=${SNAPDIR}/.snap

unsnap:
	cd ${SNAPDIR}; \
	zef install .

zef-pull:
	cd ${SRCDIR}/zef; \
	git pull --ff-only origin master; \
	sleep 3;

zef: zef-pull
	cd ${SRCDIR}/zef; \
	git checkout --detach $(shell GIT_DIR=${SRCDIR}/zef/.git git describe --abbrev=0 --tags); \
	${TARGET}/bin/raku -I. bin/zef install --force-install .
