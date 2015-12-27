package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mock.MockResult;
	import com.epolyakov.async.core.mock.MockTask;

	import flash.events.ErrorEvent;

	import mock.Mock;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class SequenceTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

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
		public function await_ShouldCallTaskAwait():void
		{
			var task:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var sequence:Sequence = new Sequence(task);

			sequence.await(args, result);

			Mock.verify().that(task.await(args, sequence));
			Mock.verify().total(1);

			assertTrue(sequence.active);
			assertEquals(sequence.result, result);

			sequence.cancel();
		}

		[Test]
		public function await_NullArgs_ShouldCallTaskAwait():void
		{
			var task:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);

			sequence.await();

			Mock.verify().that(task.await(null, sequence));
			Mock.verify().total(1);

			assertTrue(sequence.active);
			assertNull(sequence.result);

			sequence.cancel();
		}

		[Test]
		public function await_ShouldCallForkAwait():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var sequence:Sequence = new Sequence(new Fork(task, task1));

			sequence.await(args, result);

			Mock.verify().that(task.await(args, sequence));
			Mock.verify().total(1);

			assertTrue(sequence.active);
			assertEquals(sequence.result, result);
			assertEquals(sequence.tasks[0], task);

			sequence.cancel();
		}

		[Test]
		public function await_ShouldKeepInstance():void
		{
			var task:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);

			assertEquals(Sequence.instances.length, 0);

			sequence.await();

			assertEquals(Sequence.instances.length, 1);
			assertEquals(Sequence.instances[0], sequence);

			sequence.cancel();

			assertEquals(Sequence.instances.length, 0);
		}

		[Test]
		public function await_CalledTwice_ShouldHaveNoEffect():void
		{
			var task:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);

			sequence.await();
			sequence.await();
			assertTrue(sequence.active);
			Mock.verify().that(task.await(null, sequence));
			Mock.verify().total(1);

			sequence.cancel();
		}
	}
}
