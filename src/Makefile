NULL = 

SOURCES = \
	syncml-test.vala \
	libsyncml-1.0.vapi \
	libsyncml-1.0.vala \
	$(NULL)

VALA_CFLAGS = -X -I. -X -I/usr/include/libsyncml-1.0/ -X -I/opt/local/include/libsyncml-1.0/ -X -L/opt/local/lib/ -X -lsyncml

VALA_FLAGS = --pkg wizbit --pkg gee-1.0 --pkg gio-2.0

syncml-test: $(SOURCES)
	valac --save-temps $(VALA_CFLAGS) $(VALA_FLAGS) $(SOURCES)
