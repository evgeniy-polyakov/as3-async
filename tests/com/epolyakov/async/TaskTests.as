package com.epolyakov.async
{
	import com.epolyakov.async.mocks.MockResult;
	import com.epolyakov.async.mocks.MockTask;
	import com.epolyakov.async.mocks.MockTaskExtension;
	import com.epolyakov.async.tasks.TimeoutTask;
	import com.epolyakov.async.tasks.mocks.SampleITaskImplementation;
	import com.epolyakov.async.tasks.mocks.SampleTaskExtension;
	import com.epolyakov.mock.Mock;

	import flash.errors.IOError;
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
	public class TaskTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test]
		public function await_ShouldSetActiveAndArgs():void
		{
			var task:Task = new Task();
			var args:Object = {};
			assertFalse(task.active);
			task.await(args);
			assertTrue(task.active);
			assertEquals(args, task.args);
		}

		[Test]
		public function await_ShouldCallTargetAwait():void
		{
			var target:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var task:Task = new Task(target);
			var args:Object = {};

			task.await(args, result);

			Mock.verify().that(target.await(args, task))
					.verify().total(1);
		}

		[Test]
		public function await_ShouldCallOnAwait():void
		{
			var result:MockResult = new MockResult();
			var task:MockTaskExtension = new MockTaskExtension();

			task.await({}, result);

			Mock.verify().that(task.public_onAwait())
					.verify().total(1);
		}

		[Test]
		public function await_CalledTwice_ShouldHaveNoEffect():void
		{
			var target:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var task:Task = new Task(target);
			var args:Object = {};

			task.await(args, result);
			task.await(null, result);

			assertEquals(args, task.args);
			assertTrue(task.active);
			Mock.verify().that(target.await(args, task))
					.verify().total(1);
		}

		[Test]
		public function cancel_ShouldSetActiveAndArgs():void
		{
			var task:Task = new Task();
			task.await({});
			task.cancel();
			assertFalse(task.active);
			assertNull(task.args);
		}

		[Test]
		public function cancel_ShouldCallTargetCancel():void
		{
			var target:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var task:Task = new Task(target);
			var args:Object = {};

			task.await(args, result);
			task.cancel();

			Mock.verify().that(target.await(args, task))
					.verify().that(target.cancel())
					.verify().total(2);
		}

		[Test]
		public function cancel_ShouldCallOnCancel():void
		{
			var result:MockResult = new MockResult();
			var task:MockTaskExtension = new MockTaskExtension();

			task.await({}, result);
			task.cancel();

			Mock.verify().that(task.public_onAwait())
					.verify().that(task.public_onCancel())
					.verify().total(2);
		}

		[Test]
		public function cancel_CalledTwice_ShouldHaveNoEffect():void
		{
			var target:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var task:Task = new Task(target);
			var args:Object = {};

			task.await(args, result);
			task.cancel();
			task.cancel();

			assertNull(task.args);
			assertFalse(task.active);
			Mock.verify().that(target.await(args, task))
					.verify().that(target.cancel())
					.verify().total(2);
		}

		[Test]
		public function cancel_ShouldNotThrow():void
		{
			new Task().cancel();
			new Task(new MockTask()).cancel();
		}

		[Test]
		public function onReturn_ShouldSetActiveAndArgs():void
		{
			var task:Task = new Task();
			task.await({});
			task.onReturn({});
			assertFalse(task.active);
			assertNull(task.args);
		}

		[Test]
		public function onReturn_ShouldCallResultOnReturn():void
		{
			var task:Task = new Task();
			var result:MockResult = new MockResult();
			var out:Object = {};

			task.await({}, result);
			task.onReturn(out);

			Mock.verify().that(result.onReturn(out, task))
					.verify().total(1);
		}

		[Test]
		public function onReturn_ShouldCallResultOnReturnWithCustomTarget():void
		{
			var target:MockTask = new MockTask();
			var task:Task = new Task();
			var result:MockResult = new MockResult();
			var out:Object = {};

			task.await({}, result);
			task.onReturn(out, target);

			Mock.verify().that(result.onReturn(out, target))
					.verify().total(1);
		}

		[Test]
		public function onReturn_ShouldCallResultOnReturnIfTargetSetInConstructor():void
		{
			var target:MockTask = new MockTask();
			var task:Task = new Task(target);
			var result:MockResult = new MockResult();
			var arg:Object = {};
			var out:Object = {};

			Mock.setup().that(target.await(arg, task)).returns(function (a:Object, r:IResult):void
			{
				r.onReturn(out, this as ITask);
			});

			task.await(arg, result);

			Mock.verify().that(result.onReturn(out, task))
					.verify().total(2);
		}

		[Test]
		public function onThrow_ShouldSetActiveAndArgs():void
		{
			var task:Task = new Task();
			task.await({}, new MockResult());
			task.onThrow({});
			assertFalse(task.active);
			assertNull(task.args);
		}

		[Test]
		public function onThrow_ShouldCallResultOnThrow():void
		{
			var task:Task = new Task();
			var result:MockResult = new MockResult();
			var out:Object = {};

			task.await({}, result);
			task.onThrow(out);

			Mock.verify().that(result.onThrow(out, task))
					.verify().total(1);
		}

		[Test]
		public function onThrow_ShouldCallResultOnThrowWithCustomTarget():void
		{
			var target:MockTask = new MockTask();
			var task:Task = new Task();
			var result:MockResult = new MockResult();
			var out:Object = {};

			task.await({}, result);
			task.onThrow(out, target);

			Mock.verify().that(result.onThrow(out, target))
					.verify().total(1);
		}

		[Test(expects="flash.errors.IOError")]
		public function onThrow_ShouldThrow():void
		{
			var task:Task = new Task();

			task.await({});
			task.onThrow(new IOError());
		}

		[Test(async, timeout=500)]
		public function timeoutImplementation_TimeoutTask_ShouldReturn():void
		{
			var result:MockResult = new MockResult();
			var arg:Object = {};
			var out:Object = {};

			var task:ITask = async(new TimeoutTask(100)).then(out);
			task.await(arg, result);

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(result.onReturn(out, task))
						.verify().total(1);
			}, 300);
			Async.failOnEvent(this, result, Event.CANCEL, 400);
		}

		[Test(async, timeout=500)]
		public function timeoutImplementation_Closure_ShouldReturn():void
		{
			var result:MockResult = new MockResult();
			var arg:Object = {};
			var out:Object = {};

			var task:ITask = async(function (a:Object):ITask
			{
				var t:Task = new Task();
				setTimeout(a == arg ? t.onReturn : t.onThrow, 100, out);
				return t;
			});
			task.await(arg, result);

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(result.onReturn(out, task))
						.verify().total(1);
			}, 300);
			Async.failOnEvent(this, result, Event.CANCEL, 400);
		}

		[Test(async, timeout=500)]
		public function timeoutImplementation_Wrapper_ShouldReturn():void
		{
			var result:MockResult = new MockResult();
			var arg:Object = {};
			var out:Object = {};

			var task:ITask = async(new Task(new TimeoutTask(100))).then(out);
			task.await(arg, result);
			task.await(arg, result);

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(result.onReturn(out, task))
						.verify().total(1);
			}, 300);
			Async.failOnEvent(this, result, Event.CANCEL, 400);
		}

		[Test(async, timeout=500)]
		public function timeoutImplementation_ExtendTask_ShouldReturn():void
		{
			var result:MockResult = new MockResult();
			var arg:Object = {};
			var out:Object = {};

			var task:ITask = new SampleTaskExtension(100, arg, out);
			task.await(arg, result);
			task.await(arg, result);

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(result.onReturn(out, task))
						.verify().total(1);
			}, 300);
			Async.failOnEvent(this, result, Event.CANCEL, 400);
		}

		[Test(async, timeout=500)]
		public function timeoutImplementation_ImplementITask_ShouldReturn():void
		{
			var result:MockResult = new MockResult();
			var arg:Object = {};
			var out:Object = {};

			var task:ITask = new SampleITaskImplementation(100, arg, out);
			task.await(arg, result);
			task.await(arg, result);

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(result.onReturn(out, task))
						.verify().total(1);
			}, 300);
			Async.failOnEvent(this, result, Event.CANCEL, 400);
		}
	}
}
