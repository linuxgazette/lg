# Makefile to generate png, jpg and [e]ps graphics files from the
# Octave, Scilab, and Tela sources.

scilex:=export SCI='/site/X11R6/src/scilab-2.6' ; $$SCI/bin/scilex

png:=$(subst .m,.png,$(wildcard oct*.m)) \
$(subst .sce,.png,$(wildcard sci*.sce)) \
$(subst .t,.png,$(wildcard tela*.t))


.PHONY: all
all: $(png)

.PHONY: clean
clean:
	rm -f *.eps *.png

.PHONY: distclean
distclean: clean
	rm -f *~


%.eps: %.xps.0
	scilab -save_p $< Postscript

%.eps.gz: %.eps
	gzip --best --stdout $< > $@

%.png: %.m
	octave --silent --no-init-file $<

%.png: %.sce
	$(scilex) -f $<

%.png: %.t
	tela --silent --batch $<
