SRCDIR  := ${HOME}/src
SNAPDIR := ${SRCDIR}/rakudo-update
#TARGET  := ${HOME}/rakudo
TARGET  := /opt/rakudo

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

rakudo-fetch:
	cd ${SRCDIR}/rakudo; \
	git fetch --prune --tags --recurse-submodules; \
	sleep 3;

rakudo-target:
	sudo mkdir -p ${TARGET}; \
	sudo chown -R ${USER}: ${TARGET};

rakudo: rakudo-fetch rakudo-target
	cd ${SRCDIR}/rakudo; \
	git checkout --detach $(shell GIT_DIR=${SRCDIR}/rakudo/.git git describe --abbrev=0 --tags); \
	make distclean; \
	rm -rf ./nqp ./install; \
	rm -rf ${TARGET}/nqp ${TARGET}/install; \
	perl Configure.pl --gen-moar --gen-nqp --backends=moar --prefix=${TARGET}; \
	make ; \
	make test; \
	make install

snap:
	zef install App::ModuleSnap

snap-create: snap
	raku-module-snapshot --directory=${SNAPDIR}/.snap

snap-reinstall: snap-create
	cd ${SNAPDIR}/.snap/latest; \
	zef install .

zef-fetch:
	cd ${SRCDIR}/zef; \
	git fetch --prune --tags --recurse-submodules; \
	sleep 3;

zef: zef-fetch
	cd ${SRCDIR}/zef; \
	git checkout --detach $(shell GIT_DIR=${SRCDIR}/zef/.git git describe --abbrev=0 --tags); \
	${TARGET}/bin/raku -I. bin/zef install --force-install .
