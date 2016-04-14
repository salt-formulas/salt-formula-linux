DESTDIR=/
SALTENVDIR=/usr/share/salt-formulas/env
RECLASSDIR=/usr/share/salt-formulas/reclass
FORMULANAME=$(shell grep name: metadata.yml|head -1|cut -d : -f 2|grep -Eo '[a-z0-9\-]*')

all:
	@echo "make install - Install into DESTDIR"
	@echo "make test    - Run tests"
	@echo "make clean   - Cleanup after tests run"

install:
	# Formula
	[ -d $(DESTDIR)/$(SALTENVDIR) ] || mkdir -p $(DESTDIR)/$(SALTENVDIR)
	cp -a $(FORMULANAME) $(DESTDIR)/$(SALTENVDIR)/
	[ ! -d _modules ] || cp -a _modules $(DESTDIR)/$(SALTENVDIR)/
	[ ! -d _states ] || cp -a _states $(DESTDIR)/$(SALTENVDIR)/ || true
	# Metadata
	[ -d $(DESTDIR)/$(RECLASSDIR)/service/$(FORMULANAME) ] || mkdir -p $(DESTDIR)/$(RECLASSDIR)/service/$(FORMULANAME)
	cp -a metadata/service/* $(DESTDIR)/$(RECLASSDIR)/service/$(FORMULANAME)

test:
	[ ! -d tests ] || (cd tests; ./run_tests.sh)

clean:
	[ ! -d tests/build ] || rm -rf tests/build
	[ ! -d build ] || rm -rf build
