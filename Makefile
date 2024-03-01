SRCDIR  := ${HOME}/src
RAKUDIR := ${SRCDIR}/rakudo-build
SNAPDIR := ${SRCDIR}/rakudo-snap
TARGET  := ${HOME}/.rakudo

RAKUDO  := https://github.com/rakudo/rakudo.git
ZEF     := https://github.com/ugexe/zef.git
#FEZ=git@github.com:tony-o/raku-fez.git
FEZ     := https://github.com/tony-o/raku-fez.git

PATH    := ${PATH}:${TARGET}/bin:${SRCDIR}/rakudo/install/bin/rakudo

GIT     := $(shell which git || echo "MISSING git\(1\)" && false)
BANNER  := $(shell which figlet || echo "MISSING figlet\(1\)" && false)

all: clone rakudo zef fez

clone:
	mkdir -p ${SRCDIR}; \
	cd ${SRCDIR}; \
	GIT_DIR=${SRCDIR}/zef/.git ${GIT} rev-parse --git-dir || ${GIT} clone ${ZEF}; \
	GIT_DIR=${SRCDIR}/rakudo/.git ${GIT} rev-parse --git-dir || ${GIT} clone ${RAKUDO};

rakudo-fetch:
	cd ${SRCDIR}/rakudo; \
	${GIT} fetch --prune --tags --recurse-submodules origin main; \
	sleep 3;

rakudo-prepare-target-dir:
	@echo "Creating target directory ${TARGET}. Using sudo(1) to set ownership."; \
	sudo mkdir -p ${TARGET}; \
	sudo chown -R ${USER}: ${TARGET};

rakudo: rakudo-fetch rakudo-prepare-target-dir
	cd ${SRCDIR}/rakudo; \
	${GIT} switch --force main; \
	${GIT} merge --ff-only --progress --stat; \
	${GIT} switch --detach $(shell GIT_DIR=${SRCDIR}/rakudo/.git ${GIT} describe --abbrev=0 --tags); \
	${BANNER} $(shell GIT_DIR=${SRCDIR}/rakudo/.git ${GIT} describe --abbrev=0 --tags); \
	sleep 3; \
	make distclean; \
	rm -rf ./nqp ./install; \
#	rm -rf ${TARGET}/nqp ${TARGET}/install ${TARGET}/share ${TARGET}/include ${TARGET}/lib ${TARGET}/bin; \
	perl Configure.pl --gen-moar --gen-nqp --backends=moar --prefix=${TARGET} && \
	make && \
	make test && \
	make install

snap:
	zef install App::ModuleSnap

snap-create: snap
	raku-module-snapshot --directory=${SNAPDIR}/.snap

snap-reinstall: snap-create
	rm -f ${SNAPDIR}/.snap/latest; \
	ln -s $(shell ls -1t ${SNAPDIR}/.snap | head -1) ${SNAPDIR}/.snap/latest; \
	cd ${SNAPDIR}/.snap/latest; \
	zef install .

zef-fetch:
	cd ${SRCDIR}/zef; \
	${GIT} fetch --prune --tags --recurse-submodules origin main; \
	sleep 3;

zef: zef-fetch
	cd ${SRCDIR}/zef; \
	${GIT} switch --force main; \
	${GIT} merge --ff-only --progress --stat origin/main; \
	sleep 3; \
	rm -rf .precomp; \
	${GIT} switch --detach $(shell GIT_DIR=${SRCDIR}/zef/.git ${GIT} describe --abbrev=0 --tags); \
	${TARGET}/bin/raku -I. bin/zef install --force-install .

fez:
	zef install fez
