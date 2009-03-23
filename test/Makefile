NULL = 

SOURCES = \
	test_datastore.vala \
	../src/datastore.vala \
	$(NULL)

VALA_FLAGS = --pkg wizbit --pkg gee-1.0 --pkg gio-2.0

test_datastore: $(SOURCES)
	valac --save-temps $(VALA_FLAGS) $(SOURCES)

test: test_datastore
	./test_datastore
