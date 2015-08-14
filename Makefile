# -*- makefile-gmake -*-
UMAKEFILES += Makefile
ifneq "$(INCLUDE)" "no"
ifeq ($(shell test -f build/Makefile-configuration && echo yes),yes)
UMAKEFILES += build/Makefile-configuration
include build/Makefile-configuration
endif
endif
############################################
# The packages, listed in reverse order by dependency:
PACKAGES += Tactics
PACKAGES += Ktheory
PACKAGES += RezkCompletion
PACKAGES += Foundations
############################################
.PHONY: all everything install lc lcp wc describe publish-dan clean clean2 distclean distclean_coq cleanconfig clean-enhanced git-clean build-coq doc
BUILD_COQ ?= yes
ifeq ($(BUILD_COQ),yes)
COQBIN=sub/coq/bin/
all: build-coq
endif
ifneq "$(INCLUDE)" "no"
include build/CoqMakefile.make
endif
everything: TAGS all html install
OTHERFLAGS += $(MOREFLAGS)
OTHERFLAGS += -indices-matter -type-in-type
ifeq ($(VERBOSE),yes)
OTHERFLAGS += -verbose
endif
ENHANCEDDOCTARGET = enhanced-html
ENHANCEDDOCSOURCE = util/enhanced-doc
COQDOC := $(COQDOC) -utf8
COQDEFS := --language=none -r '/^[[:space:]]*\(Axiom\|Theorem\|Class\|Instance\|Let\|Ltac\|Definition\|Lemma\|Record\|Remark\|Structure\|Fixpoint\|Fact\|Corollary\|Let\|Inductive\|Coinductive\|Notation\|Proposition\|Module[[:space:]]+Import\|Module\)[[:space:]]+\([[:alnum:]'\''_]+\)/\2/'
TAGS : $(VFILES); etags $(COQDEFS) $^
install:all
lc:; wc -l $(VFILES)
lcp:; for i in $(PACKAGES) ; do echo ; echo ==== $$i ==== ; for f in $(VFILES) ; do echo "$$f" ; done | grep "UniMath/$$i" | xargs wc -l ; done
wc:; wc -w $(VFILES)
describe:; git describe --dirty --long --always --abbrev=40 --all
publish-dan:html; rsync -ai html/. u00:public_html/UniMath/.
.coq_makefile_input: $(patsubst %, UniMath/%/.package/files, $(PACKAGES)) $(UMAKEFILES)
	@ echo making $@ ; ( \
	echo '# -*- makefile-gmake -*-' ;\
	echo ;\
	echo '# DO NOT EDIT THIS FILE!' ;\
	echo '# It is made by automatically (by code in Makefile)' ;\
	echo ;\
	echo '-R UniMath UniMath' ;\
	echo ;\
	for i in $(PACKAGES) ;\
	do sed "s=^=UniMath/$$i/=" < UniMath/$$i/.package/files ;\
	done ;\
	echo ;\
	echo '# Local ''Variables:' ;\
	echo '# compile-command: "sub/coq/bin/coq_makefile -f .coq_makefile_input -o CoqMakefile.make.tmp && mv CoqMakefile.make.tmp build/CoqMakefile.make"' ;\
	echo '# End:' ;\
	) >$@
# the '' above prevents emacs from mistaking the lines above as providing local variables when visiting this file
build/CoqMakefile.make: .coq_makefile_input $(COQBIN)coq_makefile
	$(COQBIN)coq_makefile -f .coq_makefile_input -o .coq_makefile_output
	mv .coq_makefile_output $@

# "clean::" occurs also in build/CoqMakefile.make
clean:: clean2 clean-enhanced
distclean:clean cleanconfig distclean_coq
clean2:
	rm -f .coq_makefile_output build/CoqMakefile.make
	find UniMath \( -name .\*.aux \) -delete
distclean_coq:
	- $(MAKE) -C sub/coq distclean
cleanconfig:
	rm -f build/Makefile-configuration
clean-enhanced:
	rm -rf $(ENHANCEDDOCTARGET)

# building coq:
ifeq ($(BUILD_COQ),yes)
export PATH:=$(shell pwd)/sub/coq/bin:$(PATH)
sub/coq/configure sub/coq/configure.ml:
	git submodule update --init sub/coq
sub/coq/config/coq_config.ml: sub/coq/configure sub/coq/configure.ml
	cd sub/coq && ./configure -coqide no -opt -no-native-compiler -with-doc no -annotate -debug -local
# instead of "coqlight" below, we could use simply "theories/Init/Prelude.vo"
sub/coq/bin/coq_makefile sub/coq/bin/coqc: sub/coq/config/coq_config.ml
	$(MAKE) -C sub/coq KEEP_ML4_PREPROCESSED=true VERBOSE=true READABLE_ML4=yes coqlight
build-coq: sub/coq/bin/coqc
endif

git-describe:
	git describe --dirty --long --always --abbrev=40
	git submodule foreach git describe --dirty --long --always --abbrev=40 --tags
git-clean:
	git clean -Xdfq
	git submodule foreach git clean -Xdfq

doc: $(GLOBFILES) $(VFILES) 
	mkdir -p $(ENHANCEDDOCTARGET)
	cp $(ENHANCEDDOCSOURCE)/proofs-toggle.js $(ENHANCEDDOCTARGET)/proofs-toggle.js
	$(COQDOC) -toc $(COQDOCFLAGS) -html $(COQDOCLIBS) -d $(ENHANCEDDOCTARGET) \
	--with-header $(ENHANCEDDOCSOURCE)/header.html $(VFILES)
	sed -i'.bk' -f $(ENHANCEDDOCSOURCE)/proofs-toggle.sed $(ENHANCEDDOCTARGET)/*html

sub/coq-tools/find-bug.py:
	git submodule update --init sub/coq-tools
help-find-bug:
	sub/coq-tools/find-bug.py --help
isolate-bug: sub/coq-tools/find-bug.py
	cd UniMath && \
	rm -f isolated-bug.v && \
	yes | ../sub/coq-tools/find-bug.py \
		--coqbin ../sub/coq/bin \
		-R . UniMath \
		--arg " -indices-matter" \
		--arg " -type-in-type" \
		Foundations/Generalities/uu0a.v \
		isolated-bug.v
