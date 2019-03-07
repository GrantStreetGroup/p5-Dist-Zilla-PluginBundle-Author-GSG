DIST_NAME   := $(shell sed -ne 's/^name\s*=\s*//p' dist.ini )
MAIN_MODULE := $(subst -,/,$(DIST_NAME)).pm

SHARE_DIR   := $(shell \
  carton exec perl -Ilib -MFile::ShareDir=dist_dir -e \
    'print eval { dist_dir("Dist-Zilla-PluginBundle-Author-GSG") } || "share"' )

CPANFILE_SNAPSHOT := $(shell \
  carton exec perl -MFile::Spec -e \
	'($$_) = grep { -e } map{ "$$_/../../cpanfile.snapshot" } \
		grep { m(/lib/perl5$$) } @INC; \
		print File::Spec->abs2rel($$_) . "\n" if $$_' 2>/dev/null )

CONTRIB := CONTRIBUTING.md MANIFEST.SKIP

# If someone includes this Makefile, don't write the Makefile
# target because otherwise we will overwrite their custom Makefile
ifeq ($(firstword $(MAKEFILE_LIST)),$(lastword $(MAKEFILE_LIST)))
	MAKEFILE_TARGET := $(firstword $(MAKEFILE_LIST))
else
	MAKEFILE_TARGET := ""
endif

ifndef CPANFILE_SNAPSHOT
	CPANFILE_SNAPSHOT := .MAKE
endif

.PHONY : test REQUIRE_CARTON

test : REQUIRE_CARTON $(CPANFILE_SNAPSHOT)
	@nice carton exec prove -lfr t

# This target requires that you add 'requires "Devel::Cover";'
# to the cpanfile and then run "carton" to install it.
testcoverage : $(CPANFILE_SNAPSHOT)
	carton exec -- cover -test -ignore . -select ^lib

$(MAKEFILE_TARGET): $(SHARE_DIR)/Makefile
	cp $< $@
	@echo Makefile updated>&2

update: $(CONTRIB) README.md
	@echo Everything is up to date

README.md: lib/$(MAIN_MODULE) dist.ini REQUIRE_CARTON $(CPANFILE_SNAPSHOT)
	carton exec dzil run sh -c "pod2markdown $< > ${CURDIR}/$@"

.SECONDEXPANSION:
$(CONTRIB): $(SHARE_DIR)/$$(@)
	cp $< $@

$(CPANFILE_SNAPSHOT): cpanfile
	carton install

REQUIRE_CARTON:
	@if ! carton --version >/dev/null 2>&1 ; then \
		echo You must install carton: https://metacpan.org/pod/Carton >&2; \
		false; \
	else \
		true; \
	fi
