package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mocks.MockTask;
	import com.epolyakov.mock.Mock;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class ConjunctionTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test]
		public function constructor_ShouldSetTask():void
		{
			var task:MockTask = new MockTask();
			var conjunction:Conjunction = new Conjunction(task);

			assertEquals(1, conjunction.tasks.length);
			assertEquals(task, conjunction.tasks[0]);
			assertFalse(conjunction.active);
			assertNull(conjunction.result);
			Mock.verify().total(0);
		}

		[Test]
		public function add_ShouldAddTask():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.add(task1);
			conjunction.add(task2);

			assertEquals(3, conjunction.tasks.length);
			assertEquals(task, conjunction.tasks[0]);
			assertEquals(task1, conjunction.tasks[1]);
			assertEquals(task2, conjunction.tasks[2]);
			assertFalse(conjunction.active);
			assertNull(conjunction.result);
			Mock.verify().total(0);
		}

		[Test]
		public function add_ShouldNotAddTaskAgain():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.add(task1);
			conjunction.add(task1);

			assertEquals(2, conjunction.tasks.length);
			assertEquals(task, conjunction.tasks[0]);
			assertEquals(task1, conjunction.tasks[1]);
			assertFalse(conjunction.active);
			assertNull(conjunction.result);
			Mock.verify().total(0);
		}
	}
}
