package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mocks.MockResult;
	import com.epolyakov.async.core.mocks.MockTask;
	import com.epolyakov.async.core.mocks.MockTaskExtension;
	import com.epolyakov.mock.Mock;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;

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
		public function await_ShouldSetActive():void
		{
			var task:Task = new Task();
			assertFalse(task.active);
			task.await();
			assertTrue(task.active);
		}

		[Test]
		public function await_ShouldSetArgs():void
		{
			var task:Task = new Task();
			var args:Object = {};
			assertNull(task.args);
			task.await(args);
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
		public function cancel_ShouldSetActive():void
		{
			var task:Task = new Task();
			task.await();
			task.cancel();
			assertFalse(task.active);
		}

		[Test]
		public function cancel_ShouldSetArgs():void
		{
			var task:Task = new Task();
			task.await({});
			task.cancel();
			assertNull(task.args);
		}

		[Test]
		public function cacnel_ShouldCallTargetCancel():void
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
		public function cancel_ShouldCallOnAwait():void
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
	}
}
