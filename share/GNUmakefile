.POSIX:
.SUFFIXES: .po .mo
.PHONY: all check-msg-args dist extract-pot tidy-po show-fuzzy touch-po update-po

POFILES := $(shell find . -maxdepth 1 -type f -name '*.po' -exec basename {} \;)
MOFILES := $(POFILES:%.po=%.mo)
POTFILE = Zonemaster-Engine.pot
PMFILES := $(shell find ../lib -type f -name '*.pm' | sort)
TESTMODULEFILES := $(shell find ../lib/Zonemaster/Engine/Test -type f -name '*.pm' | sort)

all: $(MOFILES) modules.txt
	@echo
	@echo Remember to make sure all of the above names are in the
	@echo MANIFEST file, or they will not be installed.
	@echo

# Tidy the formatting of all PO files
tidy-po:
	@tmpdir="`mktemp -d tidy-po.XXXXXXXX`" ;\
	trap 'rm -rf "$$tmpdir"' EXIT ;\
	for f in $(POFILES) ; do msgcat $$f -o $$tmpdir/$$f && mv -f $$tmpdir/$$f $$f  ; done

touch-po:
	@touch $(POTFILE) $(POFILES)

update-po: extract-pot $(POFILES)

extract-pot:
	@xgettext --output $(POTFILE) --sort-by-file --add-comments --language=Perl --from-code=UTF-8 -k__ -k\$$__ -k%__ -k__x -k__n:1,2 -k__nx:1,2 -k__xn:1,2 -kN__ -kN__n:1,2 -k__p:1c,2 -k__np:1c,2,3 -kN__p:1c,2 -kN__np:1c,2,3 $(PMFILES)

$(POTFILE): extract-pot

$(POFILES): $(POTFILE)
	@msgmerge --update --backup=none --quiet --no-location $(MSGMERGE_OPTS) $@ $(POTFILE)

.po.mo:
	@msgfmt -o $@ $<
	@mkdir -p locale/`basename $@ .mo`/LC_MESSAGES
	@ln -vf $@ locale/`basename $@ .mo`/LC_MESSAGES/Zonemaster-Engine.mo

show-fuzzy:
	@for f in $(POFILES) ; do msgattrib --only-fuzzy $$f ; done

check-msg-args:
	@for f in $(POFILES) ; do ../util/check-msg-args $$f ; done

modules.txt: $(TESTMODULEFILES)
	@echo $(TESTMODULEFILES) | xargs basename -s .pm -a | grep -vE '^Basic$$' | sort > modules.txt
