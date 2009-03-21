using Wiz;

public class DataStore {
	private Wiz.Store store;
	private string uuid;

	Gee.HashMap<string,string> local_to_remote;
	Gee.HashMap<string,string> remote_to_local;

	public DataStore(Wiz.Store store, string uuid) {
		this.store = store;
		this.uuid = uuid;

		this.local_to_remote = new Gee.HashMap<string,string>(str_hash, str_equal, str_equal);
		this.remote_to_local = new Gee.HashMap<string,string>(str_hash, str_equal, str_equal);

		this.load_data();
	}

	public void load_data() {
		var bit = this.store.open_bit(this.uuid);

		if (bit == null)
			return;

		var root = this.store.open_bit(this.uuid).primary_tip;

		if (!root.streams.contains("data"))
			return;

		var f = root.streams.get("data");

		var stream = f.read();
		var reader = new GLib.DataInputStream(stream);

		long line_length;
		var line = reader.read_line(out line_length, null);
		while (line != null) {
			long i = 0;
			char *buf = (char *)line;

			while (i < line_length && line[i] != '\t')
				i++;

			var local = line.substring(0, i);
			var remote = line.substring(i, line_length-i);

			debug("'%s' -> '%s'", local, remote);

			line = reader.read_line(out line_length, null);
		}

	}

	private void update_remote_id(string local, string remote, string ?old_remote) {
		if (old_remote != null)
			this.remote_to_local.remove(old_remote);
		this.remote_to_local.set(remote, local);
		this.local_to_remote.set(local, remote);
	}

	private void update_local_id(string remote, string local, string ?old_local) {
		if (old_local != null)
			this.local_to_remote.remove(old_local);
		this.local_to_remote.set(local, remote);
		this.remote_to_local.set(remote, local);
	}

	private string get_local_id(string remote) {
		return this.remote_to_local.get(remote);
	}

	private void remove_remote(string remote) {
		this.local_to_remote.remove(this.get_local_id(remote));
		this.remote_to_local.remove(remote);
	}

	public bool get(string uuid, out char *buf, out long length) {
		var bit = store.open_bit(uuid);
		if (bit == null)
			return false;
		var b = bit.primary_tip.streams.get("data").get_contents();
		return true;
	}

	public string? add(string uid, char *buf, long length) {
		var bit = store.create_bit();
		if (bit == null)
			return null;
		var cb = bit.get_commit_builder();
		var f = new Wiz.File();
		f.set_contents((string)buf, length);
		cb.streams.set("data", f);
		var nc = cb.commit();
		this.update_remote_id(nc.bit.uuid, uid, null);
		return nc.bit.uuid;
	}

	public string? update(string uid, char *buf, long length) {
		string local = this.get_local_id(uid);
		var bit = store.open_bit(local);
		var cb = bit.primary_tip.get_commit_builder();
		var f = new Wiz.File();
		f.set_contents((string)buf, length);
		cb.streams.set("data", f);
		var nc = cb.commit();
		this.update_local_id(uuid, nc.bit.uuid, local);
		return nc.bit.uuid;
	}

	public bool delete(string uid) {
		this.remove_remote(uid);
		return true;
	}

	public void commit() {
		var mapping = new StringBuilder();
		foreach (var k in this.local_to_remote.get_keys())
			mapping.append("%s\t%s\n".printf(k, this.local_to_remote.get(k)));
		var mapping_str = mapping.str;

		var root = this.store.open_bit(this.uuid);
		var cb = root.primary_tip.get_commit_builder();
		var f = new Wiz.File();
		f.set_contents(mapping_str, mapping_str.length);
		cb.streams.set("data", f);
		cb.commit();
	}
}
