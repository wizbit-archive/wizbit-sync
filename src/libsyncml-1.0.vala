using Syncml;
using Syncml.DataSync;

public static void smlErrorUnrefHelper(Syncml.Error err) {
	Syncml.Error.unref(&err);	
}

public static void smlDataSyncObjectUnrefHelper(SyncObject object) {
	SyncObject.unref(&object);
}
