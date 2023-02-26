SRCDIR  := ${HOME}/src
SNAPDIR := ${SRCDIR}/rakudo-update
#TARGET  := ${HOME}/rakudo
TARGET  := /opt/rakudo

#RAKUDO=git@github.com:rakudo/rakudo.git
RAKUDO  := https://github.com/rakudo/rakudo.git
#ZEF=git@github.com:ugexe/zef.git
ZEF     := https://github.com/ugexe/zef.git
#FEZ=git@github.com:tony-o/raku-fez.git
FEZ     := https://github.com/tony-o/raku-fez.git


PATH    := ${PATH}:${TARGET}/bin:${SRCDIR}/rakudo/install/bin/rakudo

all: clone rakudo zef fez

clone:
	mkdir -p ${SRCDIR}; \
	cd ${SRCDIR}; \
	GIT_DIR=${SRCDIR}/zef/.git git rev-parse --git-dir || git clone ${ZEF}; \
	GIT_DIR=${SRCDIR}/rakudo/.git git rev-parse --git-dir || git clone ${RAKUDO};

rakudo-fetch:
	cd ${SRCDIR}/rakudo; \
	git fetch --prune --tags --recurse-submodules origin main; \
	sleep 3;

rakudo-prepare-target-dir:
	@echo "Creating target directory ${TARGET}. Using sudo(1) to set ownership."; \
	sudo mkdir -p ${TARGET}; \
	sudo chown -R ${USER}: ${TARGET};

rakudo: rakudo-fetch rakudo-prepare-target-dir
	cd ${SRCDIR}/rakudo; \
	git switch --force main; \
	git merge --ff-only --progress --stat origin/main main; \
	sleep 3; \
	git switch --detach $(shell GIT_DIR=${SRCDIR}/rakudo/.git git describe --abbrev=0 --tags); \
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
	git fetch --prune --tags --recurse-submodules origin main; \
	sleep 3;

zef: zef-fetch
	cd ${SRCDIR}/zef; \
	git switch --force main; \
	git merge --ff-only --progress --stat origin/main; \
	sleep 3; \
	git switch --detach $(shell GIT_DIR=${SRCDIR}/zef/.git git describe --abbrev=0 --tags); \
	${TARGET}/bin/raku -I. bin/zef install --force-install .

fez:
	zef install fez
