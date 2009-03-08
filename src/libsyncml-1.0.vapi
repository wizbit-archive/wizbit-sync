
namespace Syncml {

	[CCode (cname="SmlSessionType")]
	class SessionType {
	}

	[CCode (cname="SmlTransportType")]
	class TransportType {
	}

	[CCode (cname="SmlLocation")]
	class Location {
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
