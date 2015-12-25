package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mock.MockResult;
	import com.epolyakov.async.core.mock.MockTask;

	import flash.events.ErrorEvent;

	import mock.It;
	import mock.setup;
	import mock.verify;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class SequenceTests
	{
		[Test]
		public function Sequence_ShouldStoreTheGivenTask():void
		{
			var task:ITask = new MockTask();
			var sequence:Sequence = new Sequence(task);

			assertEquals(1, sequence.tasks.length);
			assertEquals(task, sequence.tasks[0]);

			assertEquals(0, Sequence.instances.length);
			assertFalse(sequence.active);
		}

		[Test]
		public function Sequence_ShouldWrapFunction():void
		{
			var func:Function = function ():void {};
			var sequence:Sequence = new Sequence(func);

			assertEquals(1, sequence.tasks.length);
			assertTrue(sequence.tasks[0] is Func);
			assertEquals(func, Func(sequence.tasks[0]).func);
		}

		[Test]
		public function Sequence_ShouldWrapError():void
		{
			var error:Error = new Error();
			var sequence:Sequence = new Sequence(error);

			assertEquals(1, sequence.tasks.length);
			assertTrue(sequence.tasks[0] is Throw);
			assertEquals(error, Throw(sequence.tasks[0]).value);
		}

		[Test]
		public function Sequence_ShouldWrapErrorEvent():void
		{
			var error:ErrorEvent = new ErrorEvent("");
			var sequence:Sequence = new Sequence(error);

			assertEquals(1, sequence.tasks.length);
			assertTrue(sequence.tasks[0] is Throw);
			assertEquals(error, Throw(sequence.tasks[0]).value);
		}

		[Test]
		public function Sequence_ShouldWrapObject():void
		{
			var object:Object = {};
			var sequence:Sequence = new Sequence(object);

			assertEquals(1, sequence.tasks.length);
			assertTrue(sequence.tasks[0] is Return);
			assertEquals(object, Return(sequence.tasks[0]).value);
		}

		[Test]
		public function Sequence_ShouldWrapPrimitive():void
		{
			var sequence:Sequence = new Sequence(100);

			assertEquals(1, sequence.tasks.length);
			assertTrue(sequence.tasks[0] is Return);
			assertEquals(100, Return(sequence.tasks[0]).value);
		}

		[Test]
		public function Sequence_ShouldWrapNull():void
		{
			var sequence:Sequence = new Sequence(null);

			assertEquals(1, sequence.tasks.length);
			assertTrue(sequence.tasks[0] is Return);
			assertNull(Return(sequence.tasks[0]).value);
		}

		[Test]
		public function await_ShouldAwaitTask():void
		{
			var task:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out:Object = {};
			var sequence:Sequence = new Sequence(task);

			setup().that(task.await(args, sequence))
					.returns(function (args:Object, result:IResult):void
					{
						assertTrue(sequence.active);
						assertEquals(result, sequence);
						result.onReturn(out, this as ITask);
					});

			sequence.await(args, result);

			verify().that(task.await(It.isAny(), It.isAny()));
			verify().that(result.onReturn(It.isAny(), It.isAny()));

			verify().that(task.await(args, sequence))
					.verify().that(result.onReturn(out, sequence));

			assertFalse(sequence.active);
		}
	}
}
