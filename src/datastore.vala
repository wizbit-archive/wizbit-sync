using Wiz;

public class DataStore {
	private Wiz.Store store;
	private string uuid;

	public DataStore(Wiz.Store store, string uuid) {
		this.store = store;
		this.uuid = uuid;
	}

	public bool get(string uuid, out char *buf, out long length) {
		var bit = store.open_bit(uuid);
		if (bit == null)
			return false;
		var b = bit.primary_tip.streams.get("data").get_contents();
		return true;
	}

	public bool add(char *buf, long length) {
		var bit = store.create_bit();
		if (bit == null)
			return false;
		var cb = bit.get_commit_builder();
		var f = new Wiz.File();
		f.set_contents((string)buf, length);
		cb.streams.set("data", f);
		cb.commit();
		return true;
	}

	public bool update(string uuid, char *buf, long length) {
		var bit = store.open_bit(uuid);
		var cb = bit.primary_tip.get_commit_builder();
		var f = new Wiz.File();
		f.set_contents((string)buf, length);
		cb.streams.set("data", f);
		cb.commit();
		return true;
	}

	public bool delete(string uuid) {
		return false;
	}
}
