using Wiz;

public class TestDataStore {

	public void setup() {
	}

	public void teardown() {
	}

	public void test_create() {
	}

	public void test_add() {
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

