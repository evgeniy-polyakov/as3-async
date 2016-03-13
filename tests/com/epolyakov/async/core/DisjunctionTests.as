package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mocks.MockResult;
	import com.epolyakov.async.core.mocks.MockTask;
	import com.epolyakov.mock.Mock;
	import com.epolyakov.mock.Times;

	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.utils.setTimeout;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class DisjunctionTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
			Cache.clear();
		}

		[Test]
		public function Disjunction_ShouldAddTask():void
		{
			var task:MockTask = new MockTask();
			var disjunction:Disjunction = new Disjunction(task);

			assertEquals(1, disjunction.tasks.length);
			assertEquals(task, disjunction.tasks[0]);
			assertFalse(disjunction.active);
			assertNull(disjunction.result);
			Mock.verify().total(0);
		}

		[Test]
		public function Disjunction_ShouldNotAddNullTask():void
		{
			var disjunction:Disjunction = new Disjunction(null);

			assertEquals(0, disjunction.tasks.length);
		}

		[Test]
		public function Disjunction_Shortcuts_ShouldAddTask():void
		{
			var task:MockTask = new MockTask();
			var func:Function = function ():void
			{
			};
			var data:Object = {};
			var error:Error = new Error();
			var errorEvent:ErrorEvent = new ErrorEvent("test");

			var disjunction:Disjunction;

			disjunction = new Disjunction(task);
			assertEquals(disjunction.tasks[0], task);

			disjunction = new Disjunction(func);
			assertEquals(Func(disjunction.tasks[0]).func, func);

			disjunction = new Disjunction(data);
			assertEquals(Return(disjunction.tasks[0]).value, data);

			disjunction = new Disjunction(error);
			assertEquals(Throw(disjunction.tasks[0]).value, error);

			disjunction = new Disjunction(errorEvent);
			assertEquals(Throw(disjunction.tasks[0]).value, errorEvent);
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

			var disjunction:Disjunction;

			disjunction = new Disjunction({});
			disjunction.or(task);
			assertEquals(disjunction.tasks[1], task);

			disjunction = new Disjunction({});
			disjunction.or(func);
			assertEquals(Func(disjunction.tasks[1]).func, func);

			disjunction = new Disjunction({});
			disjunction.or(data);
			assertEquals(Return(disjunction.tasks[1]).value, data);

			disjunction = new Disjunction({});
			disjunction.or(error);
			assertEquals(Throw(disjunction.tasks[1]).value, error);

			disjunction = new Disjunction({});
			disjunction.or(errorEvent);
			assertEquals(Throw(disjunction.tasks[1]).value, errorEvent);
		}

		[Test]
		public function or_ShouldReturnDisjunction():void
		{
			var disjunction:Disjunction = new Disjunction({});
			assertEquals(disjunction, disjunction.or({}));
		}

		[Test]
		public function or_ShouldNotAddNUllTask():void
		{
			var disjunction:Disjunction = new Disjunction({});
			assertEquals(1, disjunction.tasks.length);
			disjunction.or(null);
			assertEquals(1, disjunction.tasks.length);
		}

		[Test]
		public function or_ShouldAddTask():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var disjunction:Disjunction = new Disjunction(task);
			disjunction.or(task1);
			disjunction.or(task2);

			assertEquals(3, disjunction.tasks.length);
			assertEquals(task, disjunction.tasks[0]);
			assertEquals(task1, disjunction.tasks[1]);
			assertEquals(task2, disjunction.tasks[2]);
			assertFalse(disjunction.active);
			assertNull(disjunction.result);
			Mock.verify().total(0);
		}

		[Test]
		public function or_ShouldNotAddTaskAgain():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var disjunction:Disjunction = new Disjunction(task);
			disjunction.or(task);
			disjunction.or(task);
			disjunction.or(task1);
			disjunction.or(task1);

			assertEquals(2, disjunction.tasks.length);
			assertEquals(task, disjunction.tasks[0]);
			assertEquals(task1, disjunction.tasks[1]);
			assertFalse(disjunction.active);
			assertNull(disjunction.result);
			Mock.verify().total(0);
		}

		[Test]
		public function or_ShouldNotAddTaskWhenActive():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var disjunction:Disjunction = new Disjunction(task);
			disjunction.await();
			disjunction.or(task1);

			assertEquals(1, disjunction.tasks.length);
			assertEquals(task, disjunction.tasks[0]);
		}

		[Test]
		public function await_ShouldKeepInstance():void
		{
			var task:MockTask = new MockTask();
			var disjunction:Disjunction = new Disjunction(task);

			assertEquals(Cache.instances.length, 0);

			disjunction.await();

			assertEquals(Cache.instances.length, 1);
			assertEquals(Cache.instances[0], disjunction);

			disjunction.cancel();

			assertEquals(Cache.instances.length, 0);
		}

		[Test]
		public function await_ReliableResult_ShouldNotKeepInstance():void
		{
			var task:MockTask = new MockTask();
			var disjunction:Disjunction = new Disjunction(task);

			assertEquals(Cache.instances.length, 0);

			disjunction.await(null, new Disjunction(null));

			assertEquals(Cache.instances.length, 0);

			disjunction.cancel();
		}

		[Test]
		public function await_ShouldClearInstanceOnReturn():void
		{
			var task:Task = new Task();
			var disjunction:Disjunction = new Disjunction(task);

			disjunction.await({}, new MockResult());
			assertEquals(Cache.instances.length, 1);
			assertEquals(Cache.instances[0], disjunction);

			task.onReturn({});
			assertEquals(Cache.instances.length, 0);
		}

		[Test]
		public function await_ShouldClearInstanceOnThrow():void
		{
			var task:Task = new Task();
			var disjunction:Disjunction = new Disjunction(task);

			disjunction.await({}, new MockResult());
			assertEquals(Cache.instances.length, 1);
			assertEquals(Cache.instances[0], disjunction);

			task.onThrow({});
			assertEquals(Cache.instances.length, 0);
		}

		[Test]
		public function await_ShouldSetActiveAndResult():void
		{
			var task:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var disjunction:Disjunction = new Disjunction(task);
			disjunction.await({}, result);

			assertTrue(disjunction.active);
			assertEquals(result, disjunction.result);
		}

		[Test]
		public function await_ShouldStartAllTasks():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var disjunction:Disjunction = new Disjunction(task);
			disjunction.or(task1);
			disjunction.or(task2);
			disjunction.await(args, result);

			Mock.verify().that(task.await(args, disjunction))
					.verify().that(task1.await(args, disjunction))
					.verify().that(task2.await(args, disjunction))
					.verify().total(3);
		}

		[Test]
		public function await_ShouldReturnIfEmpty():void
		{
			var task:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var disjunction:Disjunction = new Disjunction(task);
			disjunction.tasks.splice(0, 1);
			disjunction.await(args, result);

			Mock.verify().that(result.onReturn(args, disjunction))
					.verify().total(1);
		}

		[Test]
		public function await_ShouldReturnIfOneOfTasksReturns():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out:Object = {};
			var disjunction:Disjunction = new Disjunction(task);

			Mock.setup().that(task1.await(args, disjunction)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out, this as ITask);
			});

			disjunction.or(task1);
			disjunction.or(task2);
			disjunction.await(args, result);

			Mock.verify().that(task.await(args, disjunction))
					.verify().that(task1.await(args, disjunction))
					.verify().that(task2.await(args, disjunction), Times.never)
					.verify().that(task.cancel())
					.verify().that(task1.cancel(), Times.never)
					.verify().that(task2.cancel(), Times.never)
					.verify().that(result.onReturn(out, disjunction))
					.verify().total(4);

			assertEquals(disjunction.tasks.length, 0);
		}

		[Test]
		public function await_ShouldThrowIfOneOfTasksThrows():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var error:Object = {};
			var disjunction:Disjunction = new Disjunction(task);
			disjunction.or(task1);
			disjunction.or(task2);

			Mock.setup().that(task1.await(args, disjunction)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(error, this as ITask);
			});
			disjunction.await(args, result);

			Mock.verify().that(task.await(args, disjunction))
					.verify().that(task1.await(args, disjunction))
					.verify().that(task2.await(args, disjunction), Times.never)
					.verify().that(task.cancel())
					.verify().that(task1.cancel(), Times.never)
					.verify().that(task2.cancel(), Times.never)
					.verify().that(result.onThrow(error, disjunction))
					.verify().total(4);

			assertEquals(disjunction.tasks.length, 0);
		}

		[Test]
		public function await_ShouldThrowIfOneOfTasksAwaitThrows():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var error:Object = {};
			var disjunction:Disjunction = new Disjunction(task);
			disjunction.or(task1);
			disjunction.or(task2);

			Mock.setup().that(task1.await(args, disjunction)).throws(error);
			disjunction.await(args, result);

			Mock.verify().that(task.await(args, disjunction))
					.verify().that(task1.await(args, disjunction))
					.verify().that(task2.await(args, disjunction), Times.never)
					.verify().that(task.cancel())
					.verify().that(task1.cancel(), Times.never)
					.verify().that(task2.cancel(), Times.never)
					.verify().that(result.onThrow(error, disjunction))
					.verify().total(4);

			assertEquals(disjunction.tasks.length, 0);
		}

		[Test(expects="flash.errors.IOError")]
		public function await_NullResult_ShouldThrowErrorIfTaskThrows():void
		{
			var task:MockTask = new MockTask();
			var args:Object = {};
			var disjunction:Disjunction = new Disjunction(task);

			Mock.setup().that(task.await(args, disjunction)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(new IOError(), this as ITask);
			});

			disjunction.await(args);
		}

		[Test(expects="flash.errors.IOError")]
		public function await_NullResult_ShouldThrowErrorIfTaskAwaitThrows():void
		{
			var task:MockTask = new MockTask();
			var args:Object = {};
			var disjunction:Disjunction = new Disjunction(task);

			Mock.setup().that(task.await(args, disjunction)).throws(new IOError());

			disjunction.await(args);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldReturnIfOneTaskReturnsAsync():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var disjunction:Disjunction = new Disjunction(task);

			Mock.setup().that(task.await(args, disjunction)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onReturn, 200, 10, this as ITask);
			});
			Mock.setup().that(task1.await(args, disjunction)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onReturn, 100, 20, this as ITask);
			});
			Mock.setup().that(task2.await(args, disjunction)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onReturn, 300, 30, this as ITask);
			});

			disjunction.or(task1);
			disjunction.or(task2);
			disjunction.await(args, result);

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(task.await(args, disjunction))
						.verify().that(task1.await(args, disjunction))
						.verify().that(task2.await(args, disjunction))
						.verify().that(task.cancel())
						.verify().that(task1.cancel(), Times.never)
						.verify().that(task2.cancel())
						.verify().that(result.onReturn(20, disjunction))
						.verify().total(6);

				assertNull(disjunction.result);
				assertFalse(disjunction.active);
				assertEquals(disjunction.tasks.length, 0);
			});
			Async.failOnEvent(this, result, Event.CANCEL);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldThrowIfOneOfTaskThrowsAsync():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var disjunction:Disjunction = new Disjunction(task);

			Mock.setup().that(task.await(args, disjunction)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onReturn, 200, 10, this as ITask);
			});
			Mock.setup().that(task1.await(args, disjunction)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onThrow, 100, 20, this as ITask);
			});
			Mock.setup().that(task2.await(args, disjunction)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onReturn, 300, 30, this as ITask);
			});

			disjunction.or(task1);
			disjunction.or(task2);
			disjunction.await(args, result);

			Async.handleEvent(this, result, Event.CANCEL, function (...rest):void
			{
				Mock.verify().that(task.await(args, disjunction))
						.verify().that(task1.await(args, disjunction))
						.verify().that(task2.await(args, disjunction))
						.verify().that(task.cancel())
						.verify().that(task1.cancel(), Times.never)
						.verify().that(task2.cancel())
						.verify().that(result.onThrow(20, disjunction))
						.verify().total(6);

				assertNull(disjunction.result);
				assertFalse(disjunction.active);
				assertEquals(disjunction.tasks.length, 0);
			});
			Async.failOnEvent(this, result, Event.COMPLETE);
		}

		[Test(async, timeout=1000)]
		public function cancel_ShouldCancelAllTasksAsync():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out:Object = {};
			var disjunction:Disjunction = new Disjunction(task);

			disjunction.or(task1);
			disjunction.or(task2);
			disjunction.await(args, result);

			setTimeout(function ():void
			{
				disjunction.cancel();
				result.dispatchEvent(new Event(Event.CLOSE));
			}, 200);

			Async.handleEvent(this, result, Event.CLOSE, function (...rest):void
			{
				Mock.verify().that(task.await(args, disjunction))
						.verify().that(task1.await(args, disjunction))
						.verify().that(task2.await(args, disjunction))
						.verify().that(task.cancel())
						.verify().that(task1.cancel())
						.verify().that(task2.cancel())
						.verify().total(6);

				assertNull(disjunction.result);
				assertFalse(disjunction.active);
				assertEquals(disjunction.tasks.length, 0);
			});
			Async.failOnEvent(this, result, Event.CANCEL);
			Async.failOnEvent(this, result, Event.COMPLETE);
		}

		[Test]
		public function cancel_ShouldSetActiveAndResult():void
		{
			var disjunction:Disjunction = new Disjunction(new MockTask());
			var result:MockResult = new MockResult();
			disjunction.await({}, result);
			disjunction.cancel();

			assertFalse(disjunction.active);
			assertNull(disjunction.result);
		}

		[Test]
		public function cancel_ShouldCancelAllTasks():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var args:Object = {};
			var result:MockResult = new MockResult();
			var disjunction:Disjunction = new Disjunction(task);
			disjunction.or(task1);
			disjunction.or(task2);

			disjunction.await(args, result);
			disjunction.cancel();

			Mock.verify().that(task.await(args, disjunction))
					.verify().that(task1.await(args, disjunction))
					.verify().that(task2.await(args, disjunction))
					.verify().that(task.cancel())
					.verify().that(task1.cancel())
					.verify().that(task2.cancel())
					.verify().total(6);
		}
	}
}
