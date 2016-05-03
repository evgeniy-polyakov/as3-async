package com.epolyakov.async
{
	import com.epolyakov.async.mocks.MockResult;
	import com.epolyakov.async.mocks.MockTask;
	import com.epolyakov.mock.It;
	import com.epolyakov.mock.Mock;

	import flash.errors.IOError;
	import flash.events.Event;
	import flash.utils.setTimeout;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.async.Async;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class FuncTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test]
		public function constructor_ShouldSetFunc():void
		{
			var func:Function = function ():void
			{
				Mock.invoke(null, func);
			};
			var task:Func = new Func(func);

			assertEquals(func, task.func);
			Mock.verify().total(0);
		}

		[Test]
		public function await_ShouldCallFunc0Args():void
		{
			var out:Object = {};
			var func:Function = function ():Object
			{
				Mock.invoke(null, func);
				return out;
			};
			var task:Func = new Func(func);
			var result:MockResult = new MockResult();

			task.await({}, result);

			Mock.verify().that(func())
					.verify().that(result.onReturn(out, task))
					.verify().total(2);
		}

		[Test]
		public function await_ShouldCallFunc1Arg():void
		{
			var out:Object = {};
			var args:Object = {};
			var func:Function = function (obj:Object):Object
			{
				Mock.invoke(null, func, obj);
				return out;
			};
			var task:Func = new Func(func);
			var result:MockResult = new MockResult();

			task.await(args, result);

			Mock.verify().that(func(args))
					.verify().that(result.onReturn(out, task))
					.verify().total(2);
		}

		[Test]
		public function await_ShouldThrowIfMoreThan1Args():void
		{
			var out:Object = {};
			var args:Object = {};
			var func:Function = function (obj:Object, obj2:Object):Object
			{
				return out;
			};
			var task:Func = new Func(func);
			var result:MockResult = new MockResult();

			task.await(args, result);

			Mock.verify().that(result.onThrow(It.isOfType(ArgumentError), task))
					.verify().total(1);
		}

		[Test]
		public function await_ShouldThrowIfFuncThrows():void
		{
			var args:Object = {};
			var func:Function = function (obj:Object):Object
			{
				throw new IOError();
			};
			var task:Func = new Func(func);
			var result:MockResult = new MockResult();

			task.await(args, result);

			Mock.verify().that(result.onThrow(It.isOfType(IOError), task))
					.verify().total(1);
		}

		[Test(expects="flash.errors.IOError")]
		public function await_ShouldThrowErrorIfFuncThrows():void
		{
			var args:Object = {};
			var func:Function = function (obj:Object):Object
			{
				throw new IOError();
			};
			var task:Func = new Func(func);

			task.await(args, null);
		}

		[Test]
		public function await_ShouldPassArgs():void
		{
			var args:Object = {};
			var func:Function = function (obj:Object):void
			{
				Mock.invoke(null, func, obj);
			};
			var task:Func = new Func(func);
			var result:MockResult = new MockResult();

			task.await(args, result);

			Mock.verify().that(func(args))
					.verify().that(result.onReturn(args, task))
					.verify().total(2);
		}

		[Test]
		public function await_ShouldAwaitTask():void
		{
			var task:MockTask = new MockTask();
			var func:Func = new Func(function (obj:Object):ITask
			{
				return task;
			});
			var result:MockResult = new MockResult();
			var args:Object = {};

			func.await(args, result);

			Mock.verify().that(task.await(args, func))
					.verify().total(1);
		}

		[Test]
		public function await_ShouldReturnIfTaskReturns():void
		{
			var task:MockTask = new MockTask();
			var func:Func = new Func(function (obj:Object):ITask
			{
				return task;
			});
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out:Object = {};

			Mock.setup().that(task.await(args, func)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out, this as ITask);
			});

			func.await(args, result);

			Mock.verify().that(task.await(args, func))
					.verify().that(result.onReturn(out, func))
					.verify().total(2);
		}

		[Test]
		public function await_ShouldThrowIfTaskThrows():void
		{
			var task:MockTask = new MockTask();
			var func:Func = new Func(function (obj:Object):ITask
			{
				return task;
			});
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out:Object = {};

			Mock.setup().that(task.await(args, func)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(out, this as ITask);
			});

			func.await(args, result);

			Mock.verify().that(task.await(args, func))
					.verify().that(result.onThrow(out, func))
					.verify().total(2);
		}

		[Test]
		public function await_ShouldThrowIfTaskAwaitThrows():void
		{
			var task:MockTask = new MockTask();
			var func:Func = new Func(function (obj:Object):ITask
			{
				return task;
			});
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out:Object = new IOError();

			Mock.setup().that(task.await(args, func)).throws(out);

			func.await(args, result);

			Mock.verify().that(task.await(args, func))
					.verify().that(result.onThrow(out, func))
					.verify().total(2);
		}

		[Test(expects="flash.errors.IOError")]
		public function await_ShouldThrowErrorIfTaskThrows():void
		{
			var task:MockTask = new MockTask();
			var func:Func = new Func(function (obj:Object):ITask
			{
				return task;
			});
			var args:Object = {};
			var out:Object = new IOError();

			Mock.setup().that(task.await(args, func)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(out, this as ITask);
			});

			func.await(args, null);
		}

		[Test(expects="flash.errors.IOError")]
		public function await_ShouldThrowErrorIfTaskAwaitThrows():void
		{
			var task:MockTask = new MockTask();
			var func:Func = new Func(function (obj:Object):ITask
			{
				return task;
			});
			var args:Object = {};
			var out:Object = new IOError();

			Mock.setup().that(task.await(args, func)).throws(out);

			func.await(args, null);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldReturnIfTaskReturnsAsync():void
		{
			var task:MockTask = new MockTask();
			var func:Func = new Func(function (obj:Object):ITask
			{
				return task;
			});
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out:Object = {};

			Mock.setup().that(task.await(args, func)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onReturn, 100, out, this as ITask);
			});

			func.await(args, result);

			assertEquals(task, func.task);
			assertEquals(result, func.result);

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(task.await(args, func))
						.verify().that(result.onReturn(out, func))
						.verify().total(2);

				assertNull(func.task);
				assertNull(func.result);
			});
			Async.failOnEvent(this, result, Event.CANCEL);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldThrowIfTaskThrowsAsync():void
		{
			var task:MockTask = new MockTask();
			var func:Func = new Func(function (obj:Object):ITask
			{
				return task;
			});
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out:Object = {};

			Mock.setup().that(task.await(args, func)).returns(function (args:Object, result:IResult):void
			{
				setTimeout(result.onReturn, 100, out, this as ITask);
			});

			func.await(args, result);

			assertEquals(task, func.task);
			assertEquals(result, func.result);

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(task.await(args, func))
						.verify().that(result.onReturn(out, func))
						.verify().total(2);

				assertNull(func.task);
				assertNull(func.result);
			});
			Async.failOnEvent(this, result, Event.CANCEL);
		}
	}
}
