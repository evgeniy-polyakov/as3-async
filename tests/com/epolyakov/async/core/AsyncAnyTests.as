package com.epolyakov.async.core
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class AsyncAnyTests
	{
		[Test]
		public function asyncAny_ShouldReturnDisjunctionWithTheGivenTasks():void
		{
			var task:Task = new Task();
			var task1:Task = new Task();
			var task2:Task = new Task();
			var disjunction:Disjunction = asyncAny(task, task1, task2) as Disjunction;

			assertNotNull(disjunction);
			assertEquals(3, disjunction.tasks.length);
			assertEquals(task, disjunction.tasks[0]);
			assertEquals(task1, disjunction.tasks[1]);
			assertEquals(task2, disjunction.tasks[2]);

			assertFalse(disjunction.active);
			assertFalse(task.active);
		}
	}
}
