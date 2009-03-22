
using Syncml;
using Syncml.DataSync;
using Wiz;

Mutex mutex;
int mutex_lock;

public class SyncmlProvider {
	private SyncObject syncobj;
	private SessionType sessionType;
	private AlertType alertType;
	private Syncml.Device.Info devinf;

	private Wiz.Store store;
	private DataStore datastore;

	private bool send_changes(SyncObject obj) {
		debug("Sending changes to remote...");

		while (false) {
			//foreach(var d in DataStore) {
			//	char *buf; long length;
			//	datastore.get(uid, out buf, out length);
			//	obj.add_change("SOURCE", changetype, uid, buf, length, null, out err);
			//}
		}

		Syncml.Error err;
		return obj.send_changes(out err);
	}

	private void handle_recv_event(SyncObject obj, EventType type, Syncml.Error? err) {

		switch (type) {
			case EventType.ERROR:
				debug("An error occured :-/");
				mutex.unlock();
				break;

			case EventType.CONNECT:
				debug("Remote connected");
				break;

			case EventType.DISCONNECT:
				debug("Remote disconnected");
				this.datastore.commit();
				break;

			case EventType.FINISHED:
				debug("Session finished...");
				mutex.unlock();
				break;

			case EventType.GOT_ALL_ALERTS:
				debug("Got all alerts from remote");
				if (sessionType == SessionType.CLIENT) {
					send_changes(obj);
				}
				break;

			case EventType.GOT_ALL_CHANGES:
				debug("Got all changes from remote");
				if (sessionType == SessionType.SERVER) {
					send_changes(obj);
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
		// FIXME: pick datastore based on 'source'...
		var store = this.datastore;

		string? local_id = null;

		switch (type) {
			case ChangeType.ADD:
				local_id = store.add(uid, data, size);
				break;

			case ChangeType.REPLACE:
				local_id = store.add(uid, data, size);
				break;

			case ChangeType.DELETE:
				store.delete(uid);
				break;
		}

		if (sessionType == SessionType.CLIENT && local_id != null) {
			if (!obj.add_mapping(source, uid, local_id, out err)) {
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

	private bool handle_recv_devinf(SyncObject obj, Device.Info inf, out Syncml.Error err) {
		// FIXME: This is a hack because libsynxml crashes :( :(
		if (this.devinf != null)
			return true;
		this.devinf = inf;

		debug("Manufacturer: %s", inf.manufacturer);
		debug("Model: %s", inf.model);
		debug("OEM: %s", inf.oem);
		debug("Firmware Version: %s", inf.firmware_version);
		debug("Software Version: %s", inf.software_version);
		debug("Hardware Version: %s", inf.hardware_version);
		debug("Device ID: %s", inf.device_id);
		//debug("Supports UTC: %b", inf.supports_utc);
		//debug("Supports Largs Objs: %b", inf.supports_large_objs);
		//debug("Supports Num Changes: %b", inf.supports_num_changes);

		for (uint i=0; i < inf.num_datastores(); i++)
			debug("Location: %s", inf.get_nth_datastore(i).source_ref);

		return true;
	}

	public void setup_bluetooth(string address, string channel) {
		Syncml.Error e;
		this.sessionType = SessionType.SERVER;
		this.syncobj = new SyncObject(SessionType.SERVER, TransportType.OBEX_CLIENT, out e);

		this.syncobj.set_option(Config.CONNECTION_TYPE, Config.CONNECTION_BLUETOOTH, out e);
		this.syncobj.set_option(Transport.Config.BLUETOOTH_ADDRESS, address, out e);
		this.syncobj.set_option(Transport.Config.BLUETOOTH_CHANNEL, channel, out e);
	}

	public void setup_http_client(string url) {
		Syncml.Error e;
		this.sessionType = SessionType.CLIENT;
		this.syncobj = new SyncObject(SessionType.CLIENT, TransportType.HTTP_CLIENT, out e);

		this.syncobj.set_option(Transport.Config.URL, url, out e);
	}

	public void setup_http_server(string port) {
		Syncml.Error e;
		this.sessionType = SessionType.SERVER;
		this.syncobj = new SyncObject(SessionType.SERVER, TransportType.HTTP_SERVER, out e);

		this.syncobj.set_option(Transport.Config.PORT, port, out e);
	}

	public void setup_obex_client(string url, string port) {
		Syncml.Error e;
		this.sessionType = SessionType.SERVER;
		this.syncobj = new SyncObject(SessionType.SERVER, TransportType.OBEX_CLIENT, out e);

		this.syncobj.set_option(Config.CONNECTION_TYPE, Config.CONNECTION_NET, out e);
		this.syncobj.set_option(Transport.Config.URL, url, out e);
		this.syncobj.set_option(Transport.Config.PORT, port, out e);
	}

	public void setup_obex_server(string port) {
		Syncml.Error e;
		this.sessionType = SessionType.CLIENT;
		this.syncobj = new SyncObject(SessionType.CLIENT, TransportType.OBEX_SERVER, out e);

		this.syncobj.set_option(Config.CONNECTION_TYPE, Config.CONNECTION_NET, out e);
		this.syncobj.set_option(Transport.Config.PORT, port, out e);
	}

	public int run() {
		Syncml.Error e;

		store = new Wiz.Store("", Path.build_filename(Environment.get_home_dir(), "sync"));

		this.datastore = new DataStore(store, "TEST_VCARD");
		this.syncobj.add_datastore("text/x-vcard", null, "Contacts", out e);

		// Nokia devices insist on 'PC Suite'. Most seem not to care.
		this.syncobj.set_option(Config.IDENTIFIER, "PC Suite", out e);

		// Default to WBXML
		this.syncobj.set_option(Config.USE_WBXML, "1", out e);

		this.syncobj.register_event_callback(handle_recv_event);
		// this.syncobj.register_get_alert_type_callback(handle_recv_alert_type);
		this.syncobj.register_change_callback(handle_recv_change);
		// this.syncobj.register_change_status_callback(handle_recv_change_status);
		this.syncobj.register_handle_remote_devinf_callback(handle_recv_devinf);

		debug("starting sync process...");
		if (!this.syncobj.init(out e))
			return 1;

		debug("running sync process...");
		if (!this.syncobj.run(out e))
			return 1;

		return 0;
	}	
}

static int main(string[] args) {
	//if (!Thread.supported()) {
	//	Syncml.g_thread_init(null);
	//}

	if (args[1] == "http-test") {
		var provider1 = new SyncmlProvider();
		provider1.setup_http_server("1985");
		provider1.run();

		var provider2 = new SyncmlProvider();
		provider2.setup_http_client("http://127.0.0.1:1985");
		provider2.run();
	} else if (args[1] == "obex-test") {
		var provider1 = new SyncmlProvider();
		provider1.setup_obex_server("1985");
		provider1.run();

		var provider2 = new SyncmlProvider();
		provider2.setup_obex_client("127.0.0.1", "1985");
		provider2.run();
	} else {
		var provider = new SyncmlProvider();
		provider.setup_bluetooth(args[1], args[2]);
		return provider.run();
	}

	debug("blocking...");
	mutex = new Mutex();
	mutex.lock();
	mutex.lock();
	mutex.unlock();
	mutex = null;

	return 0;
}
