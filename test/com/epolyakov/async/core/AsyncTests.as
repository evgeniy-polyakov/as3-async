package com.epolyakov.async.core
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class AsyncTests
	{
		[Test]
		public function async_ShouldReturnSequenceWithTheGivenTask():void
		{
			var task:Task = new Task();
			var sequence:Sequence = async(task) as Sequence;

			assertNotNull(sequence);
			assertEquals(1, sequence.tasks.length);
			assertEquals(task, sequence.tasks[0]);

			assertFalse(sequence.active);
			assertFalse(task.active);
		}
	}
}
