using Wiz;

public class TestDataStore {

	Wiz.Store store;
	string olddir;
	string directory;

	public void setup() {
		this.olddir = Environment.get_current_dir();
		this.directory = DirUtils.mkdtemp(Path.build_filename(Environment.get_tmp_dir(), "XXXXXX"));
		Environment.set_current_dir(this.directory);

		this.store = new Wiz.Store("", ".");
	}

	public void teardown() {
		Environment.set_current_dir(this.olddir);
		DirUtils.remove(this.directory);
	}

	public void test_create() {
		var ds = new DataStore(this.store, "DATASTORE");
		(void) ds;
	}

	public void test_add() {
		string buffer = "12345678901234567890";

		var ds = new DataStore(this.store, "DATASTORE");
		ds.add("1", buffer, 20);
		ds.commit();
	}

	public void test_update() {
		string buffer = "123456789012345678901234567890";

		this.test_add();

		var ds = new DataStore(this.store, "DATASTORE");
		ds.update("1", buffer, 30);
		ds.commit();
	}

	public TestSuite get_suite() {
		var ts = new TestSuite("datastore");

		ts.add(new TestCase("create", 0, this.setup, this.test_create, this.teardown));
		ts.add(new TestCase("add", 0, this.setup, this.test_add, this.teardown));

		return ts;
	}
}

static int main(string[] args) {
	Test.init(ref args);

	var tests = new TestDataStore();		
	TestSuite.get_root().add_suite(tests.get_suite());

	return Test.run();
}

