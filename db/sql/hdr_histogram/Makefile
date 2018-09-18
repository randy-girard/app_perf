MODULES = hdr_c_functions

PG_CONFIG = pg_config
PGXS = $(shell $(PG_CONFIG) --pgxs)
INCLUDEDIR = $(shell $(PG_CONFIG) --includedir-server)
include $(PGXS)

hdr_c_functions.so: hdr_c_functions.o
	cc -bundle -flat_namespace -undefined suppress -o hdr_c_functions.so hdr_c_functions.o

hdr_c_functions.o: hdr_c_functions.c
	cc -o hdr_c_functions.o -c hdr_c_functions.c $(CFLAGS) -I$(INCLUDEDIR)
