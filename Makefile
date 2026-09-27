PREFIX ?= /usr/local

.PHONY: install test check

install:
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 gh-sandbox $(DESTDIR)$(PREFIX)/bin/gh-sandbox

test:
	bash tests/run.sh

check:
	bash -n gh-sandbox
	bash -n tests/run.sh
	bash -n tests/bin/gh
