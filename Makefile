DESTDIR=/
SALTENVDIR=/usr/share/salt-formulas/env
RECLASSDIR=/usr/share/salt-formulas/reclass
FORMULANAME=$(shell grep name: metadata.yml|head -1|cut -d : -f 2|grep -Eo '[a-z0-9\-\_]*')
VERSION=$(shell grep version: metadata.yml|head -1|cut -d : -f 2|grep -Eo '[a-z0-9\.\-\_]*')
VERSION_MAJOR := $(shell echo $(VERSION)|cut -d . -f 1-2)
VERSION_MINOR := $(shell echo $(VERSION)|cut -d . -f 3)

NEW_MAJOR_VERSION ?= $(shell date +%Y.%m|sed 's,\.0,\.,g')
NEW_MINOR_VERSION ?= $(shell /bin/bash -c 'echo $$[ $(VERSION_MINOR) + 1 ]')

MAKE_PID := $(shell echo $$PPID)
JOB_FLAG := $(filter -j%, $(subst -j ,-j,$(shell ps T | grep "^\s*$(MAKE_PID).*$(MAKE)")))

ifneq ($(subst -j,,$(JOB_FLAG)),)
JOBS := $(subst -j,,$(JOB_FLAG))
else
JOBS := 1
endif

KITCHEN_LOCAL_YAML?=.kitchen.yml
KITCHEN_OPTS?="--concurrency=$(JOBS)"
KITCHEN_OPTS_CREATE?=""
KITCHEN_OPTS_CONVERGE?=""
KITCHEN_OPTS_VERIFY?=""
KITCHEN_OPTS_TEST?=""

all:
	@echo "make install - Install into DESTDIR"
	@echo "make test    - Run tests"
	@echo "make kitchen - Run Kitchen CI tests (create, converge, verify)"
	@echo "make clean   - Cleanup after tests run"
	@echo "make release-major  - Generate new major release"
	@echo "make release-minor  - Generate new minor release"
	@echo "make changelog      - Show changes since last release"

install:
	# Formula
	[ -d $(DESTDIR)/$(SALTENVDIR) ] || mkdir -p $(DESTDIR)/$(SALTENVDIR)
	cp -a $(FORMULANAME) $(DESTDIR)/$(SALTENVDIR)/
	[ ! -d _modules ] || cp -a _modules $(DESTDIR)/$(SALTENVDIR)/
	[ ! -d _states ] || cp -a _states $(DESTDIR)/$(SALTENVDIR)/ || true
	[ ! -d _grains ] || cp -a _grains $(DESTDIR)/$(SALTENVDIR)/ || true
	# Metadata
	[ -d $(DESTDIR)/$(RECLASSDIR)/service/$(FORMULANAME) ] || mkdir -p $(DESTDIR)/$(RECLASSDIR)/service/$(FORMULANAME)
	cp -a metadata/service/* $(DESTDIR)/$(RECLASSDIR)/service/$(FORMULANAME)

test:
	[ ! -d tests ] || (cd tests; ./run_tests.sh)

release-major: check-changes
	@echo "Current version is $(VERSION), new version is $(NEW_MAJOR_VERSION)"
	@[ $(VERSION_MAJOR) != $(NEW_MAJOR_VERSION) ] || (echo "Major version $(NEW_MAJOR_VERSION) already released, nothing to do. Do you want release-minor?" && exit 1)
	echo "$(NEW_MAJOR_VERSION)" > VERSION
	sed -i 's,version: .*,version: "$(NEW_MAJOR_VERSION)",g' metadata.yml
	[ ! -f debian/changelog ] || dch -v $(NEW_MAJOR_VERSION) -m --force-distribution -D `dpkg-parsechangelog -S Distribution` "New version"
	make genchangelog-$(NEW_MAJOR_VERSION)
	(git add -u; git commit -m "Version $(NEW_MAJOR_VERSION)")
	git tag -s -m $(NEW_MAJOR_VERSION) $(NEW_MAJOR_VERSION)

release-minor: check-changes
	@echo "Current version is $(VERSION), new version is $(VERSION_MAJOR).$(NEW_MINOR_VERSION)"
	echo "$(VERSION_MAJOR).$(NEW_MINOR_VERSION)" > VERSION
	sed -i 's,version: .*,version: "$(VERSION_MAJOR).$(NEW_MINOR_VERSION)",g' metadata.yml
	[ ! -f debian/changelog ] || dch -v $(VERSION_MAJOR).$(NEW_MINOR_VERSION) -m --force-distribution -D `dpkg-parsechangelog -S Distribution` "New version"
	make genchangelog-$(VERSION_MAJOR).$(NEW_MINOR_VERSION)
	(git add -u; git commit -m "Version $(VERSION_MAJOR).$(NEW_MINOR_VERSION)")
	git tag -s -m $(NEW_MAJOR_VERSION) $(VERSION_MAJOR).$(NEW_MINOR_VERSION)

check-changes:
	@git log --pretty=oneline --decorate $(VERSION)..HEAD | grep -Eqc '.*' || (echo "No new changes since version $(VERSION)"; exit 1)

changelog:
	git log --pretty=short --invert-grep --grep="Merge pull request" --decorate $(VERSION)..HEAD

genchangelog: genchangelog-$(VERSION_MAJOR).$(NEW_MINOR_VERSION)

genchangelog-%:
	$(eval NEW_VERSION := $(patsubst genchangelog-%,%,$@))
	(echo "=========\nChangelog\n=========\n"; \
	(echo $(NEW_VERSION);git tag) | sort -r | grep -E '^[0-9\.]+' | while read i; do \
	    cur=$$i; \
	    test $$i = $(NEW_VERSION) && i=HEAD; \
	    prev=`(echo $(NEW_VERSION);git tag)|sort|grep -E '^[0-9\.]+'|grep -B1 "$$cur\$$"|head -1`; \
	    echo "Version $$cur\n=============================\n"; \
	    git log --pretty=short --invert-grep --grep="Merge pull request" --decorate $$prev..$$i; \
	    echo; \
	done) > CHANGELOG.rst

kitchen-check:
	@[ -e $(KITCHEN_LOCAL_YAML) ] || (echo "Kitchen tests not available, there's no $(KITCHEN_LOCAL_YAML)." && exit 1)

kitchen: kitchen-check kitchen-create kitchen-converge kitchen-verify kitchen-list

kitchen-create: kitchen-check
	kitchen create ${KITCHEN_OPTS} ${KITCHEN_OPTS_CREATE}
	[ "$(shell echo $(KITCHEN_LOCAL_YAML)|grep -Eo docker)" = "docker" ] || sleep 120

kitchen-converge: kitchen-check
	kitchen converge ${KITCHEN_OPTS} ${KITCHEN_OPTS_CONVERGE} &&\
	kitchen converge ${KITCHEN_OPTS} ${KITCHEN_OPTS_CONVERGE}

kitchen-verify: kitchen-check
	[ ! -d tests/integration ] || kitchen verify -t tests/integration ${KITCHEN_OPTS} ${KITCHEN_OPTS_VERIFY}
	[ -d tests/integration ]   || kitchen verify ${KITCHEN_OPTS} ${KITCHEN_OPTS_VERIFY}

kitchen-test: kitchen-check
	[ ! -d tests/integration ] || kitchen test -t tests/integration ${KITCHEN_OPTS} ${KITCHEN_OPTS_TEST}
	[ -d tests/integration ]   || kitchen test ${KITCHEN_OPTS} ${KITCHEN_OPTS_TEST}

kitchen-list: kitchen-check
	kitchen list

clean:
	[ ! -x "$(shell which kitchen)" ] || kitchen destroy
	[ ! -d .kitchen ] || rm -rf .kitchen
	[ ! -d tests/build ] || rm -rf tests/build
	[ ! -d build ] || rm -rf build
