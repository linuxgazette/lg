INCLUDEDIRS := -I.
INCLUDEDIRS += -I$(shell pg_config --includedir-server)
INCLUDEDIRS += -I$(shell pg_config --includedir)
# If you are using shared libraries, make sure this location can be
# found at runtime (see /etc/ld.so.conf and ldconfig command).
LIBDIR = -L$(shell pg_config --libdir)
# This is where the shared object should be installed
LIBINSTALL = $(shell pg_config --pkglibdir)

example.so: example.c Makefile
			gcc -fpic -o example.o -c example.c $(INCLUDEDIRS)
			gcc -shared -o example.so example.o $(LIBDIR) -lpq -lgsl -lgslcblas -lm
			cp example.so $(LIBINSTALL)
