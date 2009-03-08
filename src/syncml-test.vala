
using Syncml;
using Syncml.DataSync;

void recv_event(SyncObject obj, EventType type) {
	switch (type) {
		case EventType.ERROR:
			break;

		case EventType.CONNECT:
			break;

		case EventType.DISCONNECT:
			break;

		case EventType.FINISHED:
			break;

		case EventType.GOT_ALL_ALERTS:
			break;

		case EventType.GOT_ALL_CHANGES:
			break;

		case EventType.GOT_ALL_MAPPINGS:
			break;

		default:
			critical("Unknown event (%d)", type);
			break;
	}
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
