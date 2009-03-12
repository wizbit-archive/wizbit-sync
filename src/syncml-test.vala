
using Syncml;
using Syncml.DataSync;
using Wiz;

class SyncmlProvider {
	private SessionType sessionType;
	private TransportType transportType;
	private AlertType alertType;
	private Mutex mutex;
	private Wiz.Store store;

	private bool send_changes(SyncObject obj, out Syncml.Error err) {
		debug("Sending changes to remote...");

		while (false) {
			// obj.add_change(obj, source, changetype, filename, buf, length, null, out err);
		}

		return obj.send_changes(out err);
	}

	private void handle_recv_event(SyncObject obj, EventType type, out Syncml.Error err) {
		debug("handle_recv_event");

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
				mutex.unlock();
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

	private AlertType handle_recv_alert_type(SyncObject obj, string source, AlertType type) {
		// The alert type seems to be entirely about whether or not we are doing a slow sync - at least thats
		// all the other implementations care about
		debug("handle_recv_alert_type");
		alertType = type;
		return type;;
	}

	private bool handle_recv_change(SyncObject obj, string source, ChangeType type, string uid, char *data, uint size, out Syncml.Error err) {
		debug("handle_recv_change");

		// Find a datastore called 'source' here....

		// is this slow sync? then check contents are same
		// if not, check for conflicts

		// FIXME: Should really have some kind of mapping between uid and wizbit uuid...

		var bit = store.open_bit(uid);
		var cb = bit.primary_tip.get_commit_builder();
		var f = new Wiz.File();
		f.set_contents((string)data, size);
		cb.streams.set("data", f);
		var nc = cb.commit();

		if (sessionType == SessionType.CLIENT) {
			if (!obj.add_mapping(source, uid, "our fricking uid", out err)) {
				critical("Adding a mapping failed :-/");
				return false;
			}
		}

		return true;
	}

	private bool handle_recv_change_status(SyncObject obj, uint code, string newuid, out Syncml.Error err) {
		debug("handle_recv_change_status");

		if (code < 200 || 299 < code) {
			error("An error occurred committing our change :-/");
			return false;
		}

		// FIXME: link newuid against our version of the data...

		return true;
	}

	private bool handle_recv_devinf(SyncObject obj, Device.DeviceInfo inf, out Syncml.Error err) {
		debug("handle_recv_devinf");
		debug("Manufacturer: %s", inf.manufacturer);
		debug("Model: %s", inf.model);
		debug("OEM: %s", inf.oem);
		debug("Firmware Version: %s", inf.firmware_version);
		debug("Software Version: %s", inf.software_version);
		debug("Hardware Version: %s", inf.hardware_version);
		debug("Device ID: %s", inf.device_id);
		debug("Supports UTC: %b", inf.supports_utc);
		debug("Supports Largs Objs: %b", inf.supports_large_objs);
		debug("Supports Num Changes: %b", inf.supports_num_changes);
		return true;
	}

	public int run() {
		Syncml.Error e;

		store = new Wiz.Store("", Path.build_filename(Environment.get_home_dir(), "sync"));

		sessionType = SessionType.CLIENT;
		transportType = TransportType.HTTP_SERVER;

		var so = new SyncObject(sessionType, transportType, out e);

		so.set_option(Config.TRANSPORT_PORT, "8080", out e);

		so.register_event_callback(handle_recv_event);
		so.register_get_alert_type_callback(handle_recv_alert_type);
		so.register_change_callback(handle_recv_change);
		so.register_change_status_callback(handle_recv_change_status);
		so.register_handle_remote_devinf_callback(handle_recv_devinf);

		debug("starting sync process...");
		if (!so.init(out e))
			return 1;

		debug("running sync process...");
		if (!so.run(out e))
			return 1;

		debug("blocking...");
		mutex = new Mutex();
		mutex.lock();
		mutex.lock();
		mutex.unlock();
		mutex = null;

		return 0;
	}	
}

static int main(string[] args) {
	var provider = new SyncmlProvider();
	return provider.run();
}
