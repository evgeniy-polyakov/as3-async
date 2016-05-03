package com.epolyakov.async
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class AsyncAllTests
	{
		[Test]
		public function asyncAll_ShouldReturnConjunctionWithTheGivenTasks():void
		{
			var task:Task = new Task();
			var task1:Task = new Task();
			var task2:Task = new Task();
			var conjunction:Conjunction = asyncAll(task, task1, task2) as Conjunction;

			assertNotNull(conjunction);
			assertEquals(3, conjunction.tasks.length);
			assertEquals(task, conjunction.tasks[0]);
			assertEquals(task1, conjunction.tasks[1]);
			assertEquals(task2, conjunction.tasks[2]);

			assertFalse(conjunction.active);
			assertFalse(task.active);
		}
	}
}
