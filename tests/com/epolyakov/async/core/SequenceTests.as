package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mocks.MockResult;
	import com.epolyakov.async.core.mocks.MockTask;
	import com.epolyakov.mock.It;
	import com.epolyakov.mock.Mock;
	import com.epolyakov.mock.Times;

	import flash.errors.IOError;
	import flash.events.ErrorEvent;

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
			Cache.clear();
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
		public function await_ShouldReturnInResult():void
		{
			var task:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out:Object = {};
			var sequence:Sequence = new Sequence(task);

			Mock.setup().that(task.await(args, sequence)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out, this as ITask);
			});

			sequence.await(args, result);

			assertFalse(sequence.active);
			Mock.verify().that(task.await(args, sequence))
					.verify().that(result.onReturn(out, sequence))
					.verify().total(2);
		}

		[Test]
		public function await_ShouldThrowInResult():void
		{
			var task:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out:Object = {};
			var sequence:Sequence = new Sequence(task);

			Mock.setup().that(task.await(args, sequence)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(out, this as ITask);
			});

			sequence.await(args, result);

			assertFalse(sequence.active);
			Mock.verify().that(task.await(args, sequence))
					.verify().that(result.onThrow(out, sequence))
					.verify().total(2);
		}

		[Test(expects="flash.errors.IOError")]
		public function await_ShouldThrowError():void
		{
			var task:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out:Object = {};
			var sequence:Sequence = new Sequence(task);

			Mock.setup().that(task.await(args, sequence)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(new IOError(), this as ITask);
			});

			sequence.await(args);
		}

		[Test]
		public function await_ShouldClearInstanceOnReturn():void
		{
			var task:Task = new Task();
			var sequence:Sequence = new Sequence(task);

			sequence.await({}, new MockResult());
			assertEquals(Cache.instances.length, 1);
			assertEquals(Cache.instances[0], sequence);

			task.onReturn({});
			assertEquals(Cache.instances.length, 0);
		}

		[Test]
		public function await_ShouldClearInstanceOnThrow():void
		{
			var task:Task = new Task();
			var sequence:Sequence = new Sequence(task);

			sequence.await({}, new MockResult());
			assertEquals(Cache.instances.length, 1);
			assertEquals(Cache.instances[0], sequence);

			task.onThrow({});
			assertEquals(Cache.instances.length, 0);
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

			Mock.verify().that(task.await(It.isEqual(args), It.isOfType(Fork)));
			Mock.verify().total(1);

			assertTrue(sequence.active);
			assertEquals(sequence.result, result);
			assertTrue(sequence.tasks[0] is Fork);
			assertEquals(task, Fork(sequence.tasks[0]).task1);
			assertEquals(task1, Fork(sequence.tasks[0]).task2);

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
		public function await_ShouldExecuteTasksInSequence():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var args1:Object = {};
			var args2:Object = {};
			var out:Object = {};
			var sequence:Sequence = new Sequence(task);
			sequence.then(task1).then(task2);

			Mock.setup().that(task.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(args1, this as ITask);
			});
			Mock.setup().that(task1.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(args2, this as ITask);
			});
			Mock.setup().that(task2.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out, this as ITask);
			});

			sequence.await(args, result);

			Mock.verify().that(task.await(args, sequence))
					.verify().that(task1.await(args1, sequence))
					.verify().that(task2.await(args2, sequence))
					.verify().that(result.onReturn(out, sequence))
					.verify().total(4);
		}

		[Test]
		public function await_ShouldThrowInSequence():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var args1:Object = {};
			var args2:Object = {};
			var error:Error = new Error();
			var sequence:Sequence = new Sequence(task);
			sequence.then(task1).then(task2);

			Mock.setup().that(task.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(args1, this as ITask);
			});
			Mock.setup().that(task1.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(error, this as ITask);
			});

			sequence.await(args, result);

			Mock.verify().that(task.await(args, sequence))
					.verify().that(task1.await(args1, sequence))
					.verify().that(result.onThrow(error, sequence))
					.verify().total(3);
		}

		[Test]
		public function await_ShouldExecuteForksInSequence():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var error:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var args1:Object = {};
			var args2:Object = {};
			var out:Object = {};
			var sequence:Sequence = new Sequence(task);
			sequence.fork(task1, error)
					.fork(task2, error);

			Mock.setup().that(task.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(args1, this as ITask);
			});
			Mock.setup().that(task1.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(args2, this as ITask);
			});
			Mock.setup().that(task2.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out, this as ITask);
			});

			sequence.await(args, result);

			Mock.verify().that(task.await(args, sequence))
					.verify().that(task1.await(It.isEqual(args1), It.isOfType(Fork)))
					.verify().that(task2.await(It.isEqual(args2), It.isOfType(Fork)))
					.verify().that(result.onReturn(out, sequence))
					.verify().total(4);
		}

		[Test]
		public function await_ShouldExecuteTasksAndForksInSequence():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var task3:MockTask = new MockTask();
			var task4:MockTask = new MockTask();
			var error:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var args1:Object = {};
			var args2:Object = {};
			var args3:Object = {};
			var args4:Object = {};
			var out:Object = {};
			var sequence:Sequence = new Sequence(task);
			sequence.fork(task1, error)
					.then(task2)
					.fork(task3, error)
					.then(task4);

			Mock.setup().that(task.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(args1, this as ITask);
			});
			Mock.setup().that(task1.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(args2, this as ITask);
			});
			Mock.setup().that(task2.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(args3, this as ITask);
			});
			Mock.setup().that(task3.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(args4, this as ITask);
			});
			Mock.setup().that(task4.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out, this as ITask);
			});

			sequence.await(args, result);

			Mock.verify().that(task.await(args, sequence))
					.verify().that(task1.await(It.isEqual(args1), It.isOfType(Fork)))
					.verify().that(task2.await(args2, sequence))
					.verify().that(task3.await(It.isEqual(args3), It.isOfType(Fork)))
					.verify().that(task4.await(args4, sequence))
					.verify().that(result.onReturn(out, sequence))
					.verify().total(6);
		}

		[Test]
		public function await_ShouldExecuteForkWithError():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var error:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var args1:Object = {};
			var args2:Object = {};
			var out:Object = {};
			var sequence:Sequence = new Sequence(task);
			sequence.fork(task1, error)
					.fork(task2, error);

			Mock.setup().that(task.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(args1, this as ITask);
			});
			Mock.setup().that(error.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(args2, this as ITask);
			});
			Mock.setup().that(task2.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out, this as ITask);
			});

			sequence.await(args, result);

			Mock.verify().that(task.await(args, sequence))
					.verify().that(task1.await(It.isAny(), It.isAny()), Times.never)
					.verify().that(error.await(It.isEqual(args1), It.isOfType(Fork)))
					.verify().that(task2.await(It.isEqual(args2), It.isOfType(Fork)))
					.verify().that(result.onReturn(out, sequence))
					.verify().total(4);
		}

		[Test]
		public function await_ShouldExecuteHookWithError():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var error:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var args1:Object = {};
			var args2:Object = {};
			var out:Object = {};
			var sequence:Sequence = new Sequence(task);
			sequence.hook(error)
					.fork(task2, error);

			Mock.setup().that(task.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(args1, this as ITask);
			});
			Mock.setup().that(error.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(args2, this as ITask);
			});
			Mock.setup().that(task2.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out, this as ITask);
			});

			sequence.await(args, result);

			Mock.verify().that(task.await(args, sequence))
					.verify().that(task1.await(It.isAny(), It.isAny()), Times.never)
					.verify().that(error.await(It.isEqual(args1), It.isOfType(Fork)))
					.verify().that(task2.await(It.isEqual(args2), It.isOfType(Fork)))
					.verify().that(result.onReturn(out, sequence))
					.verify().total(4);
		}

		[Test]
		public function await_ShouldSkipHooks():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var error:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var args1:Object = {};
			var args2:Object = {};
			var out:Object = {};
			var sequence:Sequence = new Sequence(task);
			sequence.hook(task1).hook(error).then(task2);

			Mock.setup().that(task.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(args2, this as ITask);
			});
			Mock.setup().that(task2.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out, this as ITask);
			});

			sequence.await(args, result);

			Mock.verify().that(task.await(args, sequence))
					.verify().that(task1.await(It.isAny(), It.isAny()), Times.never)
					.verify().that(error.await(It.isAny(), It.isAny()), Times.never)
					.verify().that(task2.await(args2, sequence))
					.verify().that(result.onReturn(out, sequence))
					.verify().total(3);
		}

		[Test]
		public function await_ShouldExecuteSubsequentHooks():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var args1:Object = {};
			var args2:Object = {};
			var out:Object = {};
			var sequence:Sequence = new Sequence(task);
			sequence.hook(task1)
					.hook(task2);

			Mock.setup().that(task.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(args1, this as ITask);
			});
			Mock.setup().that(task1.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(args2, this as ITask);
			});
			Mock.setup().that(task2.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out, this as ITask);
			});

			sequence.await(args, result);

			Mock.verify().that(task.await(args, sequence))
					.verify().that(task1.await(It.isEqual(args1), It.isOfType(Fork)))
					.verify().that(task2.await(It.isEqual(args2), It.isOfType(Fork)))
					.verify().that(result.onReturn(out, sequence))
					.verify().total(4);
		}

		[Test]
		public function await_ShouldHandleErrorsInTaskAwait():void
		{
			var task:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out:Object = {};
			var sequence:Sequence = new Sequence(task);

			Mock.setup().that(task.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				throw out;
			});

			sequence.await(args, result);

			Mock.verify().that(task.await(args, sequence))
					.verify().that(result.onThrow(out, sequence))
					.verify().total(2);
		}

		[Test]
		public function await_ShouldHandleErrorsInTaskAwait2():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out:Object = {};
			var out1:Object = {};
			var sequence:Sequence = new Sequence(task);
			sequence.hook(task1);

			Mock.setup().that(task.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				throw out;
			});
			Mock.setup().that(task1.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				throw out1;
			});

			sequence.await(args, result);

			Mock.verify().that(task.await(args, sequence))
					.verify().that(task1.await(It.isEqual(out), It.isOfType(Fork)))
					.verify().that(result.onThrow(out1, sequence))
					.verify().total(3);
		}

		[Test(expects="flash.errors.IOError")]
		public function await_ShouldThrowIfNoResult():void
		{
			var task:MockTask = new MockTask();
			var args:Object = {};
			var out:IOError = new IOError();
			var sequence:Sequence = new Sequence(task);

			Mock.setup().that(task.await(It.isAny(), It.isAny())).returns(function (args:Object, result:IResult):void
			{
				throw out;
			});

			sequence.await(args, null);
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

		[Test]
		public function and_ShouldAddConjunction():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);
			sequence.and(task1);
			sequence.and(task2);

			assertEquals(sequence.tasks.length, 1);
			assertEquals(Conjunction(sequence.tasks[0]).tasks.length, 3);
			assertEquals(Conjunction(sequence.tasks[0]).tasks[0], task);
			assertEquals(Conjunction(sequence.tasks[0]).tasks[1], task1);
			assertEquals(Conjunction(sequence.tasks[0]).tasks[2], task2);
			Mock.verify().total(0);
		}

		[Test]
		public function and_ShouldAddConjunctionAtTheEnd():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);
			sequence.then(task1);
			sequence.and(task2);

			assertEquals(sequence.tasks.length, 2);
			assertEquals(sequence.tasks[0], task);
			assertEquals(Conjunction(sequence.tasks[1]).tasks.length, 2);
			assertEquals(Conjunction(sequence.tasks[1]).tasks[0], task1);
			assertEquals(Conjunction(sequence.tasks[1]).tasks[1], task2);
			Mock.verify().total(0);
		}

		[Test]
		public function and_ShouldNotRecreateConjunction():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var conjunction:Conjunction = new Conjunction(task);
			var sequence:Sequence = new Sequence(conjunction);
			sequence.and(task1);
			sequence.and(task2);

			assertEquals(sequence.tasks.length, 1);
			assertEquals(sequence.tasks[0], conjunction);
			assertEquals(Conjunction(sequence.tasks[0]).tasks.length, 3);
			assertEquals(Conjunction(sequence.tasks[0]).tasks[0], task);
			assertEquals(Conjunction(sequence.tasks[0]).tasks[1], task1);
			assertEquals(Conjunction(sequence.tasks[0]).tasks[2], task2);
			Mock.verify().total(0);
		}

		[Test]
		public function and_ShouldReturnSequence():void
		{
			var sequence:Sequence = new Sequence(new MockTask());

			assertEquals(sequence.and(new MockTask()), sequence);
		}

		[Test]
		public function and_ActiveSequence_ShouldNotAddTask():void
		{
			var task:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);
			sequence.await();
			sequence.and(new MockTask());

			assertEquals(sequence.tasks.length, 1);
			assertEquals(sequence.tasks[0], task);

			sequence.cancel();
		}

		[Test]
		public function and_EmptySequence_ShouldNotAddTask():void
		{
			var sequence:Sequence = new Sequence(new MockTask());
			sequence.await();
			sequence.cancel();
			sequence.and(new MockTask());

			assertEquals(sequence.tasks.length, 0);

			sequence.cancel();
		}

		[Test]
		public function and_Shortcuts_ShouldAddTask():void
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
			sequence.and(task);
			assertEquals(Conjunction(sequence.tasks[0]).tasks[1], task);

			sequence = new Sequence(null);
			sequence.and(func);
			assertEquals(Func(Conjunction(sequence.tasks[0]).tasks[1]).func, func);

			sequence = new Sequence(null);
			sequence.and(data);
			assertEquals(Return(Conjunction(sequence.tasks[0]).tasks[1]).value, data);

			sequence = new Sequence(null);
			sequence.and(error);
			assertEquals(Throw(Conjunction(sequence.tasks[0]).tasks[1]).value, error);

			sequence = new Sequence(null);
			sequence.and(errorEvent);
			assertEquals(Throw(Conjunction(sequence.tasks[0]).tasks[1]).value, errorEvent);
		}

		[Test]
		public function or_ShouldAddDisjunction():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);
			sequence.or(task1);
			sequence.or(task2);

			assertEquals(sequence.tasks.length, 1);
			assertEquals(Disjunction(sequence.tasks[0]).tasks.length, 3);
			assertEquals(Disjunction(sequence.tasks[0]).tasks[0], task);
			assertEquals(Disjunction(sequence.tasks[0]).tasks[1], task1);
			assertEquals(Disjunction(sequence.tasks[0]).tasks[2], task2);
			Mock.verify().total(0);
		}

		[Test]
		public function or_ShouldAddDisjunctionAtTheEnd():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);
			sequence.then(task1);
			sequence.or(task2);

			assertEquals(sequence.tasks.length, 2);
			assertEquals(sequence.tasks[0], task);
			assertEquals(Disjunction(sequence.tasks[1]).tasks.length, 2);
			assertEquals(Disjunction(sequence.tasks[1]).tasks[0], task1);
			assertEquals(Disjunction(sequence.tasks[1]).tasks[1], task2);
			Mock.verify().total(0);
		}

		[Test]
		public function or_ShouldNotRecreateDisjunction():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var disjunction:Disjunction = new Disjunction(task);
			var sequence:Sequence = new Sequence(disjunction);
			sequence.or(task1);
			sequence.or(task2);

			assertEquals(sequence.tasks.length, 1);
			assertEquals(sequence.tasks[0], disjunction);
			assertEquals(Disjunction(sequence.tasks[0]).tasks.length, 3);
			assertEquals(Disjunction(sequence.tasks[0]).tasks[0], task);
			assertEquals(Disjunction(sequence.tasks[0]).tasks[1], task1);
			assertEquals(Disjunction(sequence.tasks[0]).tasks[2], task2);
			Mock.verify().total(0);
		}

		[Test]
		public function or_ShouldReturnSequence():void
		{
			var sequence:Sequence = new Sequence(new MockTask());

			assertEquals(sequence.or(new MockTask()), sequence);
		}

		[Test]
		public function or_ActiveSequence_ShouldNotAddTask():void
		{
			var task:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);
			sequence.await();
			sequence.or(new MockTask());

			assertEquals(sequence.tasks.length, 1);
			assertEquals(sequence.tasks[0], task);

			sequence.cancel();
		}

		[Test]
		public function or_EmptySequence_ShouldNotAddTask():void
		{
			var sequence:Sequence = new Sequence(new MockTask());
			sequence.await();
			sequence.cancel();
			sequence.or(new MockTask());

			assertEquals(sequence.tasks.length, 0);

			sequence.cancel();
		}

		[Test]
		public function or_Shortcuts_ShouldAddTask():void
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
			sequence.or(task);
			assertEquals(Disjunction(sequence.tasks[0]).tasks[1], task);

			sequence = new Sequence(null);
			sequence.or(func);
			assertEquals(Func(Disjunction(sequence.tasks[0]).tasks[1]).func, func);

			sequence = new Sequence(null);
			sequence.or(data);
			assertEquals(Return(Disjunction(sequence.tasks[0]).tasks[1]).value, data);

			sequence = new Sequence(null);
			sequence.or(error);
			assertEquals(Throw(Disjunction(sequence.tasks[0]).tasks[1]).value, error);

			sequence = new Sequence(null);
			sequence.or(errorEvent);
			assertEquals(Throw(Disjunction(sequence.tasks[0]).tasks[1]).value, errorEvent);
		}

		[Test]
		public function fork_ShouldAddFork():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);
			sequence.fork(task1, task2);

			assertEquals(sequence.tasks.length, 2);
			assertEquals(sequence.tasks[0], task);
			assertEquals(Fork(sequence.tasks[1]).task1, task1);
			assertEquals(Fork(sequence.tasks[1]).task2, task2);
			Mock.verify().total(0);
		}

		[Test]
		public function fork_ShouldReturnSequence():void
		{
			var sequence:Sequence = new Sequence(new MockTask());

			assertEquals(sequence.fork(new MockTask(), new MockTask()), sequence);
		}

		[Test]
		public function fork_ActiveSequence_ShouldNotAddFork():void
		{
			var task:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);

			sequence.await();
			sequence.fork(new MockTask(), new MockTask());

			assertEquals(sequence.tasks.length, 1);
			assertEquals(sequence.tasks[0], task);

			sequence.cancel();
		}

		[Test]
		public function fork_Shortcuts_ShouldAddFork():void
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
			sequence.fork(task, null);
			assertEquals(Fork(sequence.tasks[1]).task1, task);

			sequence = new Sequence(null);
			sequence.fork(func, null);
			assertEquals(Func(Fork(sequence.tasks[1]).task1).func, func);

			sequence = new Sequence(null);
			sequence.fork(data, null);
			assertEquals(Return(Fork(sequence.tasks[1]).task1).value, data);

			sequence = new Sequence(null);
			sequence.fork(error, null);
			assertEquals(Throw(Fork(sequence.tasks[1]).task1).value, error);

			sequence = new Sequence(null);
			sequence.fork(errorEvent, null);
			assertEquals(Throw(Fork(sequence.tasks[1]).task1).value, errorEvent);

			sequence = new Sequence(null);
			sequence.fork(null, task);
			assertEquals(Fork(sequence.tasks[1]).task2, task);

			sequence = new Sequence(null);
			sequence.fork(null, func);
			assertEquals(Func(Fork(sequence.tasks[1]).task2).func, func);

			sequence = new Sequence(null);
			sequence.fork(null, data);
			assertEquals(Return(Fork(sequence.tasks[1]).task2).value, data);

			sequence = new Sequence(null);
			sequence.fork(null, error);
			assertEquals(Throw(Fork(sequence.tasks[1]).task2).value, error);

			sequence = new Sequence(null);
			sequence.fork(null, errorEvent);
			assertEquals(Throw(Fork(sequence.tasks[1]).task2).value, errorEvent);
		}

		[Test]
		public function hook_ShouldAddFork():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);
			sequence.hook(task1);
			sequence.hook(task2);

			assertEquals(sequence.tasks.length, 3);
			assertEquals(sequence.tasks[0], task);
			assertEquals(Fork(sequence.tasks[1]).task1, null);
			assertEquals(Fork(sequence.tasks[1]).task2, task1);
			assertEquals(Fork(sequence.tasks[2]).task1, null);
			assertEquals(Fork(sequence.tasks[2]).task2, task2);
			Mock.verify().total(0);
		}

		[Test]
		public function hook_ShouldReturnSequence():void
		{
			var sequence:Sequence = new Sequence(new MockTask());

			assertEquals(sequence.hook(new MockTask()), sequence);
		}

		[Test]
		public function hook_ActiveSequence_ShouldNotAddFork():void
		{
			var task:MockTask = new MockTask();
			var sequence:Sequence = new Sequence(task);

			sequence.await();
			sequence.hook(new MockTask());

			assertEquals(sequence.tasks.length, 1);
			assertEquals(sequence.tasks[0], task);

			sequence.cancel();
		}

		[Test]
		public function hook_Shortcuts_ShouldAddTask():void
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
			sequence.hook(task);
			assertEquals(Fork(sequence.tasks[1]).task1, null);
			assertEquals(Fork(sequence.tasks[1]).task2, task);

			sequence = new Sequence(null);
			sequence.hook(func);
			assertEquals(Fork(sequence.tasks[1]).task1, null);
			assertEquals(Func(Fork(sequence.tasks[1]).task2).func, func);

			sequence = new Sequence(null);
			sequence.hook(data);
			assertEquals(Fork(sequence.tasks[1]).task1, null);
			assertEquals(Return(Fork(sequence.tasks[1]).task2).value, data);

			sequence = new Sequence(null);
			sequence.hook(error);
			assertEquals(Fork(sequence.tasks[1]).task1, null);
			assertEquals(Throw(Fork(sequence.tasks[1]).task2).value, error);

			sequence = new Sequence(null);
			sequence.hook(errorEvent);
			assertEquals(Fork(sequence.tasks[1]).task1, null);
			assertEquals(Throw(Fork(sequence.tasks[1]).task2).value, errorEvent);
		}
	}
}
