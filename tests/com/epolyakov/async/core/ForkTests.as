package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mocks.MockResult;
	import com.epolyakov.async.core.mocks.MockTask;
	import com.epolyakov.mock.Mock;

	import flash.errors.EOFError;
	import flash.errors.IOError;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNull;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class ForkTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test]
		public function constructor_ShouldSetTasks():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var fork:Fork = new Fork(task1, task2);

			assertEquals(task1, fork.task1);
			assertEquals(task2, fork.task2);

			Mock.verify().total(0);
		}

		[Test]
		public function await_ShouldStartTask1():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var fork:Fork = new Fork(task1, task2);
			var result:MockResult = new MockResult();
			var args:Object = {};

			assertEquals(0, fork.state);
			assertNull(fork.result);

			fork.await(args, result);

			assertEquals(1, fork.state);
			assertEquals(result, fork.result);

			Mock.verify().that(task1.await(args, fork))
					.verify().total(1);
		}

		[Test]
		public function await2_ShouldStartTask2():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var fork:Fork = new Fork(task1, task2);
			var result:MockResult = new MockResult();
			var args:Object = {};

			assertEquals(0, fork.state);
			assertNull(fork.result);

			fork.await2(args, result);

			assertEquals(2, fork.state);
			assertEquals(result, fork.result);

			Mock.verify().that(task2.await(args, fork))
					.verify().total(1);
		}

		[Test]
		public function await_ShouldCallOnReturnIfNullTask1():void
		{
			var task2:MockTask = new MockTask();
			var fork:Fork = new Fork(null, task2);
			var result:MockResult = new MockResult();
			var args:Object = {};

			fork.await(args, result);

			assertEquals(0, fork.state);
			assertNull(fork.result);

			Mock.verify().that(result.onReturn(args, fork))
					.verify().total(1);
		}

		[Test]
		public function await2_ShouldCallOnThrowIfNullTask2():void
		{
			var task1:MockTask = new MockTask();
			var fork:Fork = new Fork(task1, null);
			var result:MockResult = new MockResult();
			var args:Object = {};

			fork.await2(args, result);

			assertEquals(0, fork.state);
			assertNull(fork.result);

			Mock.verify().that(result.onThrow(args, fork))
					.verify().total(1);
		}

		[Test(expects="flash.errors.IOError")]
		public function await2_ShouldThrowIfNullTask2AndResult():void
		{
			var task1:MockTask = new MockTask();
			var fork:Fork = new Fork(task1, null);
			var args:Object = new IOError();

			fork.await2(args, null);
		}

		[Test]
		public function await_ShouldCallTaskOnReturn():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var fork:Fork = new Fork(task1, task2);
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out1:Object = {};
			var out2:Object = {};

			Mock.setup().that(task1.await(args, fork)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out1, this as ITask);
			});
			Mock.setup().that(task2.await(args, fork)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out2, this as ITask);
			});

			fork.await(args, result);

			assertEquals(0, fork.state);
			assertNull(fork.result);
			assertNull(fork.task1);
			assertNull(fork.task2);
			Mock.verify().that(task1.await(args, fork))
					.verify().that(result.onReturn(out1, fork))
					.verify().total(2);
		}

		[Test]
		public function await2_ShouldCallTaskOnReturn():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var fork:Fork = new Fork(task1, task2);
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out1:Object = {};
			var out2:Object = {};

			Mock.setup().that(task1.await(args, fork)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out1, this as ITask);
			});
			Mock.setup().that(task2.await(args, fork)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(out2, this as ITask);
			});

			fork.await2(args, result);

			assertEquals(0, fork.state);
			assertNull(fork.result);
			assertNull(fork.task1);
			assertNull(fork.task2);
			Mock.verify().that(task2.await(args, fork))
					.verify().that(result.onReturn(out2, fork))
					.verify().total(2);
		}

		[Test]
		public function await_ShouldCallTaskOnThrow():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var fork:Fork = new Fork(task1, task2);
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out1:Object = {};
			var out2:Object = {};

			Mock.setup().that(task1.await(args, fork)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(out1, this as ITask);
			});
			Mock.setup().that(task2.await(args, fork)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(out2, this as ITask);
			});

			fork.await(args, result);

			assertEquals(0, fork.state);
			assertNull(fork.result);
			assertNull(fork.task1);
			assertNull(fork.task2);
			Mock.verify().that(task1.await(args, fork))
					.verify().that(result.onThrow(out1, fork))
					.verify().total(2);
		}

		[Test]
		public function await2_ShouldCallTaskOnThrow():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var fork:Fork = new Fork(task1, task2);
			var result:MockResult = new MockResult();
			var args:Object = {};
			var out1:Object = {};
			var out2:Object = {};

			Mock.setup().that(task1.await(args, fork)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(out1, this as ITask);
			});
			Mock.setup().that(task2.await(args, fork)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(out2, this as ITask);
			});

			fork.await2(args, result);

			assertEquals(0, fork.state);
			assertNull(fork.result);
			assertNull(fork.task1);
			assertNull(fork.task2);
			Mock.verify().that(task2.await(args, fork))
					.verify().that(result.onThrow(out2, fork))
					.verify().total(2);
		}

		[Test(expects="flash.errors.IOError")]
		public function await_ShouldThrowIfNullResult():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var fork:Fork = new Fork(task1, task2);
			var args:Object = {};
			var out1:Object = new IOError();
			var out2:Object = new EOFError();

			Mock.setup().that(task1.await(args, fork)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(out1, this as ITask);
			});
			Mock.setup().that(task2.await(args, fork)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(out2, this as ITask);
			});

			fork.await(args, null);
		}

		[Test(expects="flash.errors.EOFError")]
		public function await2_ShouldThrowIfNullResult():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var fork:Fork = new Fork(task1, task2);
			var args:Object = {};
			var out1:Object = new IOError();
			var out2:Object = new EOFError();

			Mock.setup().that(task1.await(args, fork)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(out1, this as ITask);
			});
			Mock.setup().that(task2.await(args, fork)).returns(function (args:Object, result:IResult):void
			{
				result.onThrow(out2, this as ITask);
			});

			fork.await2(args, null);
		}

		[Test(expects="flash.errors.IOError")]
		public function await_ShouldThrowIfNullResult1():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var fork:Fork = new Fork(task1, task2);
			var args:Object = {};
			var out1:Object = new IOError();
			var out2:Object = new EOFError();

			Mock.setup().that(task1.await(args, fork)).throws(out1);
			Mock.setup().that(task2.await(args, fork)).throws(out2);

			fork.await(args, null);
		}

		[Test(expects="flash.errors.EOFError")]
		public function await2_ShouldThrowIfNullResult1():void
		{
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var fork:Fork = new Fork(task1, task2);
			var args:Object = {};
			var out1:Object = new IOError();
			var out2:Object = new EOFError();

			Mock.setup().that(task1.await(args, fork)).throws(out1);
			Mock.setup().that(task2.await(args, fork)).throws(out2);

			fork.await2(args, null);
		}
	}
}
