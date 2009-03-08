
using Syncml;
using Syncml.DataSync;

bool send_changes(SyncObject obj, out Syncml.Error err) {
	debug("Sending changes to remote...");

	while (false) {
		// obj.add_change(obj, source, changetype, filename, buf, length, null, out err);
	}

	return obj.send_changes(out err);
}

void recv_event(SyncObject obj, EventType type, out Syncml.Error err) {
	switch (type) {
		case EventType.ERROR:
			debug("An error occured :-/");
			break;

		case EventType.CONNECT:
			debug("Remote connected");
			break;

		case EventType.DISCONNECT:
			debug("Remote disconnected");
			break;

		case EventType.FINISHED:
			debug("Session finished...");
			break;

		case EventType.GOT_ALL_ALERTS:
			debug("Got all alerts from remote");
			if (sessionType == SessionType.CLIENT) {
				send_changes(obj, out err);
			}
			break;

		case EventType.GOT_ALL_CHANGES:
			debug("Got all changes from remote");
			if (sessionType == SessionType.SERVER) {
				send_changes(obj, out err);
			}
			break;

		case EventType.GOT_ALL_MAPPINGS:
			assert(sessionType == SessionType.SERVER);
			debug("All mappings received");
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

SessionType sessionType;
TransportType transportType;

static int main(string[] args) {
	Syncml.Error e;

	sessionType = SessionType.CLIENT;
	transportType = TransportType.HTTP_SERVER;

	var so = new SyncObject(sessionType, transportType, out e);

	so.register_event_callback(recv_event);
	so.register_get_alert_type_callback(recv_alert_type);
	so.register_change_callback(recv_change);

	if (!so.init(out e))
		return 1;

	if (!so.run(out e))
		return 1;

	return 0;
}
