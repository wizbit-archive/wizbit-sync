
using Syncml;
using Syncml.DataSync;

void recv_event(SyncObject obj) {

}

AlertType recv_alert_type(SyncObject obj, string source, AlertType type) {
	return 0;
}

bool recv_change(SyncObject obj) {
	return false;
}

static int main(string[] args) {
	Syncml.Error e;

	var so = new SyncObject(SessionType.CLIENT, TransportType.HTTP_SERVER, out e);

	so.register_event_callback(recv_event);
	so.register_get_alert_type_callback(recv_alert_type);
	so.register_change_callback(recv_change);

	so.init(out e);
	so.run(out e);

	return 0;
}
