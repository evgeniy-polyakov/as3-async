package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mock.MockResult;
	import com.epolyakov.async.core.mock.MockTask;

	import flash.events.ErrorEvent;

	import mock.It;
	import mock.Mock;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
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
		}

		[Test]
		public function Sequence_Shortcuts_ShouldAddTask():void
		{
			var task:MockTask = new MockTask();
			var func:Function = function ():void
			{
			};
			var data:Object = {};
			var error:Error = new Error();
			var errorEvent:ErrorEvent = new ErrorEvent("test");

			var sequence:Sequence;

			sequence = new Sequence(task);
			assertEquals(sequence.tasks[0], task);

			sequence = new Sequence(func);
			assertEquals(Func(sequence.tasks[0]).func, func);

			sequence = new Sequence(data);
			assertEquals(Return(sequence.tasks[0]).value, data);

			sequence = new Sequence(error);
			assertEquals(Throw(sequence.tasks[0]).value, error);

			sequence = new Sequence(errorEvent);
			assertEquals(Throw(sequence.tasks[0]).value, errorEvent);
		}

		[Test]
		public function await_ShouldCallTaskAwait():void
		{
			var task:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var sequence:Sequence = new Sequence(task);

			assertFalse(sequence.active);

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

			assertEquals(Cache.instances.length, 0);

			sequence.await();

			assertEquals(Cache.instances.length, 1);
			assertEquals(Cache.instances[0], sequence);

			sequence.cancel();

			assertEquals(Cache.instances.length, 0);
		}

		[Test]
		public function await_CalledTwice_ShouldHaveNoEffect():void
		{
			var task:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);

			sequence.await();
			sequence.await();

			assertTrue(sequence.active);
			assertEquals(Cache.instances.length, 1);
			assertEquals(Cache.instances[0], sequence);
			Mock.verify().that(task.await(null, sequence));
			Mock.verify().total(1);

			sequence.cancel();
		}

		[Test]
		public function cancel_CalledFirst_ShouldHaveNoEffect():void
		{
			var task:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);

			sequence.cancel();

			assertFalse(sequence.active);
			assertNotNull(sequence.tasks);
			assertEquals(Cache.instances.length, 0);
			Mock.verify().total(0);
		}

		[Test]
		public function cancel_ShouldCancelActiveTask():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);
			sequence.then(task1);
			sequence.then(task2);

			Mock.setup().that(task.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(args, this as ITask);
			});

			sequence.await();
			sequence.cancel();

			Mock.verify().that(task.await(null, sequence))
					.verify().that(task1.await(null, sequence))
					.verify().that(task1.cancel())
					.verify().total(3);
		}

		[Test]
		public function cancel_ShouldClearSequence():void
		{
			var sequence:Sequence = new Sequence(new MockTask());

			sequence.await({}, new MockResult());
			sequence.cancel();

			assertFalse(sequence.active);
			assertEquals(sequence.tasks.length, 0);
			assertNull(sequence.result);
			assertEquals(Cache.instances.length, 0);
		}

		[Test]
		public function then_ShouldAddTask():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);
			sequence.then(task1);
			sequence.then(task2);

			assertEquals(sequence.tasks.length, 3);
			assertEquals(sequence.tasks[0], task);
			assertEquals(sequence.tasks[1], task1);
			assertEquals(sequence.tasks[2], task2);
			Mock.verify().total(0);
		}

		[Test]
		public function then_ShouldReturnSequence():void
		{
			var sequence:Sequence = new Sequence(new MockTask());

			assertEquals(sequence.then(new MockTask()), sequence);
		}

		[Test]
		public function then_ActiveSequence_ShouldNotAddTask():void
		{
			var task:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);

			sequence.await();
			sequence.then(new MockTask());

			assertEquals(sequence.tasks.length, 1);
			assertEquals(sequence.tasks[0], task);

			sequence.cancel();
		}

		[Test]
		public function then_Shortcuts_ShouldAddTask():void
		{
			var task:MockTask = new MockTask();
			var func:Function = function ():void
			{
			};
			var data:Object = {};
			var error:Error = new Error();
			var errorEvent:ErrorEvent = new ErrorEvent("test");

			var sequence:Sequence;

			sequence = new Sequence(null);
			sequence.then(task);
			assertEquals(sequence.tasks[1], task);

			sequence = new Sequence(null);
			sequence.then(func);
			assertEquals(Func(sequence.tasks[1]).func, func);

			sequence = new Sequence(null);
			sequence.then(data);
			assertEquals(Return(sequence.tasks[1]).value, data);

			sequence = new Sequence(null);
			sequence.then(error);
			assertEquals(Throw(sequence.tasks[1]).value, error);

			sequence = new Sequence(null);
			sequence.then(errorEvent);
			assertEquals(Throw(sequence.tasks[1]).value, errorEvent);
		}
	}
}
