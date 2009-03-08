
namespace Syncml {

	[CCode (cname="SmlSessionType", cprefix="SML_SESSION_TYPE_", cheader_filename="libsyncml/sml_defines.h")]
	public enum SessionType {
		SERVER,
		CLIENT
	}

	[CCode (cname="SmlTransportType", cprefix="SML_TRANSPORT_", cheader_filename="libsyncml/sml_defines.h")]
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
		public Location(string locURI, string locName, out Error err);

		[CCode (cname="smlLocationGetURI")]
		public string get_uri();
		[CCode (cname="smlLocationGetName")]
		public string get_name();
		[CCode (cname="smlLocationSetName")]
		public void set_name(string name);
	}

	[CCode (cname="SmlDevInf")]
	public class DevInf {
	}

	[CCode (cname="SmlError")]
	public class Error {
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
		public enum EventType {
			ERROR,
			CONNECT,
			GOT_ALL_ALERTS,
			GOT_ALL_CHANGES,
			GOT_ALL_MAPPINGS,
			DISCONNECT,
			FINISHED
		}

		[CCode (cname="SmlDataSyncEventCallback")]
		public delegate void EventCallback(SyncObject object, EventType type, void *userdata, Error *error);
		[CCode (cname="SmlDataSyncGetAlertTypeCallback")]
		public delegate AlertType GetAlertTypeCallback(SyncObject object, string source, AlertType type, void *userdata, out Error err);
		[CCode (cname="SmlDataSyncChangeCallback")]
		public delegate bool ChangeCallback(SyncObject object, string source, ChangeType type, string uid, char *data, uint size, void *userdata, out Error error);
		[CCode (cname="SmlDataSyncChangeStatusCallback")]
		public delegate bool ChangeStatusCallback(SyncObject object, uint code, string newuid, void *userdata, out Error error);
		[CCode (cname="SmlDataSyncGetAnchorCallback")]
		public delegate string GetAnchorCallback(SyncObject object, string name, void *userdata, out Error error);
		[CCode (cname="SmlDataSyncSetAnchorCallback")]
		public delegate bool SetAnchorCallback(SyncObject object, string name, string value, void *userdata, out Error error);
		[CCode (cname="SmlWriteDevInfCallback")]
		public delegate bool WriteDevInfCallback(SyncObject object, DevInf devinf, void *userdate, out Error error);
		[CCode (cname="SmlReadDevInfCallback")]
		public delegate DevInf ReadDevInfCallback(SyncObject object, string devid, void *userdata, out Error error);
		[CCode (cname="HandleRemoteDevInfCallback")]
		public delegate bool HandleRemoteDevInfCallback(SyncObject object, DevInf devinf, void *userdata, out Error error);

		[CCode (cname="SmlDataSyncObject", ref_function="smlDataSyncObjectRef", unref_function="smlDataSyncObjectUnref")]
		public class SyncObject {
			[CCode (cname="SmlDataSyncObjectNew")]
			public SyncObject(SessionType dsType, TransportType tspType, out Error err);
			[CCode (cname="smlDataSyncSetOption")]
			public bool set_option(string name, string value, out Error err);
			[CCode (cname="smlDataSyncSendChanges")]
			public bool add_datastore(string contentType, string target, string source, out Error err);

			[CCode (cname="smlDataSyncInit")]
			public bool init(out Error err);
			[CCode (cname="smlDataSyncRun")]
			public bool run(out Error err);

			[CCode (cname="smlDataSyncAddChange")]
			public bool add_change(string source, ChangeType type, string name, char *data, uint size, void *userdata, out Error error);
			[CCode (cname="smlDataSyncSendChanges")]
			public bool send_changes(out Error err);
			[CCode (cname="smlDataSyncAddMapping")]
			public bool add_mapping(string source, string remote_id, string local_id, out Error err);

			[CCode (cname="smlDataSyncGetTarget")]
			Location get_target(out Error err);

			[CCode (cname="smlDataSyncRegisterEventCallback")]
			public void register_event_callback(EventCallback callback);
			[CCode (cname="smlDataSyncRegisterGetAlertTypeCallback")]
			public void register_get_alert_type_callback(GetAlertTypeCallback callback);
			[CCode (cname="smlDataSyncRegisterChangeCallback")]
			public void register_change_callback(ChangeCallback callback);
			[CCode (cname="smlDataSyncRegisterGetAnchorCallback")]
			public void register_get_anchor_callback(GetAnchorCallback callback);
			[CCode (cname="smlDataSyncRegisterSetAnchorCallback")]
			public void register_set_anchor_callback(SetAnchorCallback callback);
			[CCode (cname="smlDataSyncRegisterWriteDevInfCallback")]
			public void register_write_devinf_callback(WriteDevInfCallback callback);
			[CCode (cname="smlDataSyncRegisterReadDevInfCallback")]
			public void register_read_devinf_callback(ReadDevInfCallback callback);
			[CCode (cname="smlDataSyncRegisterHandleRemoteDevInfCallback")]
			public void register_handle_remote_devinf_callback(HandleRemoteDevInfCallback callback);

			[CCode (cname="smlDataSyncRegisterChangeStatusCallback", delegate_target_position="0")]
			public void register_change_status_callback(ChangeStatusCallback callback);
		}
	}
}
