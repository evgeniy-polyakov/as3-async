package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mocks.MockTask;
	import com.epolyakov.mock.Mock;

	import org.flexunit.asserts.assertEquals;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class CacheTests
	{
		[Before]
		public function Before():void
		{
			Cache.clear();
			Mock.clear();
		}

		[Test]
		public function add_ShouldAddInstance():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var task3:MockTask = new MockTask();

			Cache.add(task1);
			Cache.add(task2);
			Cache.add(task3);

			assertEquals(3, Cache.instances.length);
			assertEquals(3, Cache.size);
			assertEquals(task1, Cache.instances[0]);
			assertEquals(task2, Cache.instances[1]);
			assertEquals(task3, Cache.instances[2]);
			Mock.verify().total(0);
		}

		[Test]
		public function remove_ShouldRemoveInstance():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var task3:MockTask = new MockTask();

			Cache.add(task1);
			Cache.add(task2);
			Cache.add(task3);
			Cache.remove(task2);

			assertEquals(2, Cache.instances.length);
			assertEquals(2, Cache.size);
			assertEquals(task1, Cache.instances[0]);
			assertEquals(task3, Cache.instances[1]);
			Mock.verify().total(0);
		}

		[Test]
		public function clear_ShouldRemoveAllInstances():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var task3:MockTask = new MockTask();

			Cache.add(task1);
			Cache.add(task2);
			Cache.add(task3);
			Cache.clear();

			assertEquals(0, Cache.instances.length);
			assertEquals(0, Cache.size);
			Mock.verify().total(0);
		}
	}
}
