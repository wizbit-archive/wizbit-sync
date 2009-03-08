
namespace Syncml {

	[CCode (cname="SmlSessionType", cprefix="SML_SESSION_TYPE_", cheader_filename="libsyncml/sml_defines.h")]
	public enum SessionType {
		SERVER,
		CLIENT
	}

	[CCode (cname="SmlTransportType", cprefix="SML_TRANSPORT_TYPE_", cheader_filename="libsyncml/sml_defines.h")]
	public enum TransportType {
		OBEX_CLIENT,
		OBEX_SERVER,
		HTTP_CLIENT,
		HTTP_SERVER
	}

	[CCode (cname="SmlAlertType", cprefix="SML_ALERT_", cheader_filename="libsyncml/sml_defines.h")]
	public enum AlertType {
		UNKNOWN,
		DISPLAY,
		TWO_WAY,
		SLOW_SYNC,
		ONE_WAY_FROM_CLIENT,
		REFRESH_FROM_CLIENT,
		ONE_WAY_FROM_SERVER,
		REFRESH_FROM_SERVER,
		TWO_WAY_BY_SERVER,
		ONE_WAY_FROM_CLIENT_BY_SERVER,
		REFRESH_FROM_CLIENT_BY_SERVER,
		ONE_WAY_FROM_SERVER_BY_SERVER,
		REFRESH_FROM_SERVER_BY_SERVER,
		RESULT,
		NEXT_MESSAGE,
		NO_END_OF_DATA
	}

	[CCode (cname="SmlChangeType", cprefix="SML_CHANGE_", cheader_filename="libsyncml/sml_defines.h")]
	public enum ChangeType {
		UNKNOWN,
		ADD,
		REPLACE,
		DELETE
	}

	[CCode (cname="SmlLocation", cheader_filename="libsyncml/sml_elements.h", ref_function="smlLocationRef", unref_function="smlLocationUnref")]
	public class Location {
		[CCode (cname="smlLocationNew")]
		public Location(string locURI, string locName, ref Error err);

		[CCode (cname="smlLocationGetURI")]
		public string get_uri();
		[CCode (cname="smlLocationGetName")]
		public string get_name();
		[CCode (cname="smlLocationSetName")]
		public void set_name(string name);
	}

	[CCode (cname="SmlError")]
	class Error {
	}

	[CCode (cheader_filename="libsyncml/data_sync_api/standard.h")]
	namespace DataSync {

		[CCode (cprefix="SML_DATA_SYNC_CONFIG_")]
		namespace Config {
			public string ConnectionType;
			public string ConnectionSerial;
			public string ConnectionBluetooth;
			public string ConnectionIrda;
			public string ConnectionNet;
			public string ConnectionUsb;

			public string AuthUsername;
			public string AuthPassword;
			public string AuthType;
			public string AuthBasic;
			public string AuthNone;
			public string AuthMd5;

			public string ConfigVersion;
			public string ConfigIdentifier;

			public string UseWbxml;
			public string UseStringTable;
			public string UseTimestampAnchor;
			public string UseNumberOfChanges;
			public string UseLocalTime;
			public string OnlyReplace;
			public string MaxMsgSize;
			public string MaxObjSize;

			public string FakeDevice;
			public string FakeManufacturer;
			public string FakeModel;
			public string FakeSoftwareVersion;
		}

		[CCode (cprefix="SML_DATA_SYNC_EVENT_")]
		public enum EventTypes {
			ERROR,
			CONNECT,
			GOT_ALL_ALERTS,
			GOT_ALL_CHANGES,
			GOT_ALL_MAPPINGS,
			DISCONNECT,
			FINISHED
		}

		[CCode (cname="SmlDataSyncObject", ref_function="smlDataSyncObjectRef", unref_function="smlDataSyncObjectUnref")]
		public class SyncObject {
			[CCode (cname="SmlDataSyncObjectNew")]
			public SyncObject(SessionType dsType, TransportType tspType, ref Error err);
			[CCode (cname="smlDataSyncSetOption")]
			public bool set_option(string name, string value, ref Error err);
			[CCode (cname="smlDataSyncSendChanges")]
			public bool add_datastore(string contentType, string target, string source, ref Error err);

			[CCode (cname="smlDataSyncInit")]
			public init(ref Error err);
			[CCode (cname="smlDataSyncRun")]
			public run(ref Error err);

			[CCode (cname="smlDataSyncAddChange")]
			public bool add_change(string source, ChangeType type, string name, char *data, unsigned int size, void *userdata, ref Error error);
			[CCode (cname="smlDataSyncSendChanges")]
			public bool send_changes(ref Error err);
			[CCode (cname="smlDataSyncAddMapping")]
			public bool add_mapping(string source, string remote_id, string local_id, ref Error err);

			[CCode (cname="smlDataSyncGetTarget")]
			Location get_target(ref Error err);
		}
	}
}
