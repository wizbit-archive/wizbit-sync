
using Syncml;
using Syncml.DataSync;

static int main(string[] args) {
	Syncml.Error e;

	var so = new SyncObject(SessionType.CLIENT, TransportType.HTTP_CLIENT, out e);
	so.init(out e);
	so.run(out e);

	return 0;
}
