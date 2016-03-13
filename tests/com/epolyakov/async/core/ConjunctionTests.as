package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mocks.MockResult;
	import com.epolyakov.async.core.mocks.MockTask;
	import com.epolyakov.mock.It;
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
	public class ConjunctionTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test]
		public function Conjunction_ShouldAddTask():void
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
		public function Conjunction_ShouldNotAddNullTask():void
		{
			var conjunction:Conjunction = new Conjunction(null);

			assertEquals(0, conjunction.tasks.length);
		}

		[Test]
		public function Conjunction_Shortcuts_ShouldAddTask():void
		{
			var task:MockTask = new MockTask();
			var func:Function = function ():void
			{
			};
			var data:Object = {};
			var error:Error = new Error();
			var errorEvent:ErrorEvent = new ErrorEvent("test");

			var conjunction:Conjunction;

			conjunction = new Conjunction(task);
			assertEquals(conjunction.tasks[0], task);

			conjunction = new Conjunction(func);
			assertEquals(Func(conjunction.tasks[0]).func, func);

			conjunction = new Conjunction(data);
			assertEquals(Return(conjunction.tasks[0]).value, data);

			conjunction = new Conjunction(error);
			assertEquals(Throw(conjunction.tasks[0]).value, error);

			conjunction = new Conjunction(errorEvent);
			assertEquals(Throw(conjunction.tasks[0]).value, errorEvent);
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

			var conjunction:Conjunction;

			conjunction = new Conjunction({});
			conjunction.and(task);
			assertEquals(conjunction.tasks[1], task);

			conjunction = new Conjunction({});
			conjunction.and(func);
			assertEquals(Func(conjunction.tasks[1]).func, func);

			conjunction = new Conjunction({});
			conjunction.and(data);
			assertEquals(Return(conjunction.tasks[1]).value, data);

			conjunction = new Conjunction({});
			conjunction.and(error);
			assertEquals(Throw(conjunction.tasks[1]).value, error);

			conjunction = new Conjunction({});
			conjunction.and(errorEvent);
			assertEquals(Throw(conjunction.tasks[1]).value, errorEvent);
		}

		[Test]
		public function and_ShouldReturnConjunction():void
		{
			var conjunction:Conjunction = new Conjunction({});
			assertEquals(conjunction, conjunction.and({}));
		}

		[Test]
		public function and_ShouldNotAddNUllTask():void
		{
			var conjunction:Conjunction = new Conjunction({});
			assertEquals(1, conjunction.tasks.length);
			conjunction.and(null);
			assertEquals(1, conjunction.tasks.length);
		}

		[Test]
		public function and_ShouldAddTask():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.and(task1);
			conjunction.and(task2);

			assertEquals(3, conjunction.tasks.length);
			assertEquals(task, conjunction.tasks[0]);
			assertEquals(task1, conjunction.tasks[1]);
			assertEquals(task2, conjunction.tasks[2]);
			assertFalse(conjunction.active);
			assertNull(conjunction.result);
			Mock.verify().total(0);
		}

		[Test]
		public function and_ShouldNotAddTaskAgain():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.and(task);
			conjunction.and(task);
			conjunction.and(task1);
			conjunction.and(task1);

			assertEquals(2, conjunction.tasks.length);
			assertEquals(task, conjunction.tasks[0]);
			assertEquals(task1, conjunction.tasks[1]);
			assertFalse(conjunction.active);
			assertNull(conjunction.result);
			Mock.verify().total(0);
		}

		[Test]
		public function and_ShouldNotAddTaskWhenActive():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.await();
			conjunction.and(task1);

			assertEquals(1, conjunction.tasks.length);
			assertEquals(task, conjunction.tasks[0]);
		}

		[Test]
		public function await_ShouldSetActiveAndResult():void
		{
			var task:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.await({}, result);

			assertTrue(conjunction.active);
			assertEquals(result, conjunction.result);
		}

		[Test]
		public function await_ShouldStartAllTasks():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.and(task1);
			conjunction.and(task2);
			conjunction.await(args, result);

			Mock.verify().that(task.await(args, conjunction))
					.verify().that(task1.await(args, conjunction))
					.verify().that(task2.await(args, conjunction))
					.verify().total(3);
		}

		[Test]
		public function await_ShouldReturnIfEmpty():void
		{
			var task:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.tasks.splice(0, 1);
			conjunction.await(args, result);

			Mock.verify().that(result.onReturn(args, conjunction))
					.verify().total(1);
		}

		[Test]
		public function await_ShouldReturnIfAllTasksReturn():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var conjunction:Conjunction = new Conjunction(task);

			Mock.setup().that(task.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(10, this as ITask);
			});
			Mock.setup().that(task1.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(20, this as ITask);
			});
			Mock.setup().that(task2.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(30, this as ITask);
			});

			conjunction.and(task1);
			conjunction.and(task2);
			conjunction.await(args, result);

			Mock.verify().that(result.onReturn(It.match(function (value:Object):Boolean
					{
						return value is Array && (value as Array).length == 3
								&& value[0] == 10 && value[1] == 20 && value[2] == 30;
					}), conjunction))
					.verify().total(4);

			assertEquals(conjunction.tasks.length, 0);
		}

		[Test]
		public function await_ShouldReturnInOrderOfExecution():void
		{
			var task:Task = new Task();
			var task1:Task = new Task();
			var task2:Task = new Task();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.and(task1);
			conjunction.and(task2);
			conjunction.await(args, result);

			task1.onReturn(10);
			task2.onReturn(20);
			task.onReturn(0);

			Mock.verify().that(result.onReturn(It.match(function (value:Object):Boolean
					{
						return value is Array && (value as Array).length == 3
								&& value[0] == 10 && value[1] == 20 && value[2] == 0;
					}), conjunction))
					.verify().total(1);
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
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.and(task1);
			conjunction.and(task2);

			Mock.setup().that(task1.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(error, this as ITask);
			});
			conjunction.await(args, result);

			Mock.verify().that(task.await(args, conjunction))
					.verify().that(task1.await(args, conjunction))
					.verify().that(task2.await(args, conjunction), Times.never)
					.verify().that(task.cancel())
					.verify().that(task1.cancel(), Times.never)
					.verify().that(task2.cancel(), Times.never)
					.verify().that(result.onThrow(error, conjunction))
					.verify().total(4);

			assertEquals(conjunction.tasks.length, 0);
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
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.and(task1);
			conjunction.and(task2);

			Mock.setup().that(task1.await(args, conjunction)).throws(error);
			conjunction.await(args, result);

			Mock.verify().that(task.await(args, conjunction))
					.verify().that(task1.await(args, conjunction))
					.verify().that(task2.await(args, conjunction), Times.never)
					.verify().that(task.cancel())
					.verify().that(task1.cancel(), Times.never)
					.verify().that(task2.cancel(), Times.never)
					.verify().that(result.onThrow(error, conjunction))
					.verify().total(4);

			assertEquals(conjunction.tasks.length, 0);
		}

		[Test(expects="flash.errors.IOError")]
		public function await_NullResult_ShouldThrowErrorIfTaskThrows():void
		{
			var task:MockTask = new MockTask();
			var args:Object = {};
			var conjunction:Conjunction = new Conjunction(task);

			Mock.setup().that(task.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(new IOError(), this as ITask);
			});

			conjunction.await(args);
		}

		[Test(expects="flash.errors.IOError")]
		public function await_NullResult_ShouldThrowErrorIfTaskAwaitThrows():void
		{
			var task:MockTask = new MockTask();
			var args:Object = {};
			var conjunction:Conjunction = new Conjunction(task);

			Mock.setup().that(task.await(args, conjunction)).throws(new IOError());

			conjunction.await(args);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldReturnIfAllTasksReturnAsync():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var conjunction:Conjunction = new Conjunction(task);

			Mock.setup().that(task.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onReturn, 200, 10, this as ITask);
			});
			Mock.setup().that(task1.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onReturn, 100, 20, this as ITask);
			});
			Mock.setup().that(task2.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onReturn, 300, 30, this as ITask);
			});

			conjunction.and(task1);
			conjunction.and(task2);
			conjunction.await(args, result);

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(task.await(args, conjunction))
						.verify().that(task1.await(args, conjunction))
						.verify().that(task2.await(args, conjunction))
						.verify().that(result.onReturn(It.match(function (value:Object):Boolean
						{
							return value is Array && (value as Array).length == 3
									&& value[0] == 20 && value[1] == 10 && value[2] == 30;
						}), conjunction))
						.verify().total(4);

				assertNull(conjunction.result);
				assertFalse(conjunction.active);
				assertEquals(conjunction.tasks.length, 0);
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
			var error:Object = {};
			var conjunction:Conjunction = new Conjunction(task);

			Mock.setup().that(task.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onReturn, 100, 10, this as ITask);
			});
			Mock.setup().that(task1.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onThrow, 200, error, this as ITask);
			});
			Mock.setup().that(task2.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onReturn, 300, 30, this as ITask);
			});

			conjunction.and(task1);
			conjunction.and(task2);
			conjunction.await(args, result);

			Async.handleEvent(this, result, Event.CANCEL, function (...rest):void
			{
				Mock.verify().that(task.await(args, conjunction))
						.verify().that(task1.await(args, conjunction))
						.verify().that(task2.await(args, conjunction))
						.verify().that(task2.cancel())
						.verify().that(result.onThrow(error, conjunction))
						.verify().total(5);

				assertNull(conjunction.result);
				assertFalse(conjunction.active);
				assertEquals(conjunction.tasks.length, 0);
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
			var conjunction:Conjunction = new Conjunction(task);

			Mock.setup().that(task1.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onReturn, 100, out, this as ITask);
			});

			conjunction.and(task1);
			conjunction.and(task2);
			conjunction.await(args, result);

			setTimeout(function ():void
			{
				conjunction.cancel();
				result.dispatchEvent(new Event(Event.CLOSE));
			}, 200);

			Async.handleEvent(this, result, Event.CLOSE, function (...rest):void
			{
				Mock.verify().that(task.await(args, conjunction))
						.verify().that(task1.await(args, conjunction))
						.verify().that(task2.await(args, conjunction))
						.verify().that(task.cancel())
						.verify().that(task1.cancel(), Times.never)
						.verify().that(task2.cancel())
						.verify().total(5);

				assertNull(conjunction.result);
				assertFalse(conjunction.active);
				assertEquals(conjunction.tasks.length, 0);
			});
			Async.failOnEvent(this, result, Event.CANCEL);
			Async.failOnEvent(this, result, Event.COMPLETE);
		}

		[Test]
		public function cancel_ShouldSetActiveAndResult():void
		{
			var conjunction:Conjunction = new Conjunction(new MockTask());
			var result:MockResult = new MockResult();
			conjunction.await({}, result);
			conjunction.cancel();

			assertFalse(conjunction.active);
			assertNull(conjunction.result);
		}

		[Test]
		public function cancel_ShouldCancelAllTasks():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var args:Object = {};
			var result:MockResult = new MockResult();
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.and(task1);
			conjunction.and(task2);

			Mock.setup().that(task1.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn({}, this as ITask);
			});

			conjunction.await(args, result);
			conjunction.cancel();

			Mock.verify().that(task.await(args, conjunction))
					.verify().that(task1.await(args, conjunction))
					.verify().that(task2.await(args, conjunction))
					.verify().that(task.cancel())
					.verify().that(task1.cancel(), Times.never)
					.verify().that(task2.cancel())
					.verify().total(5);
		}
	}
}
