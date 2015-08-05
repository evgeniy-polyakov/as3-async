package com.epolyakov.asynctasks.core
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.mockito.api.Answer;
	import org.mockito.integrations.any;
	import org.mockito.integrations.eq;
	import org.mockito.integrations.given;
	import org.mockito.integrations.inOrder;
	import org.mockito.integrations.useArgument;
	import org.mockito.integrations.verify;

	/**
	 * @author epolyakov
	 */
	[RunWith("org.mockito.integrations.flexunit4.MockitoClassRunner")]
	public class AsyncFactoryTests
	{
		[Mock]
		public var testTask:IAsync;

		[Mock]
		public var testResult:IResult;

		public var testInput:Object = {};
		public var testOutput:Object = {};

		[Test]
		public function Async_ShouldResultReturn():void
		{
			var factory:IAsyncFactory = async1(testTask);

			given(testTask.execute(any(), any())).will(
					useArgument(1).method("onReturn").andCallWithArgs(testOutput, testTask) as Answer);

			factory.execute(testInput, testResult);

			inOrder().verify().that(testTask.execute(eq(testInput), eq(factory)));
			inOrder().verify().that(testResult.onReturn(eq(testOutput), eq(factory)));
		}

		[Test]
		public function Async_ShouldResultThrow():void
		{
			var factory:IAsyncFactory = async1(testTask);

			given(testTask.execute(any(), any())).will(
					useArgument(1).method("onThrow").andCallWithArgs(testOutput, testTask) as Answer);

			factory.execute(testInput, testResult);

			inOrder().verify().that(testTask.execute(eq(testInput), eq(factory)));
			inOrder().verify().that(testResult.onThrow(eq(testOutput), eq(factory)));
		}

		[Test]
		public function Async_ShouldReturn():void
		{
			var factory:IAsyncFactory = async1(testTask);

			given(testTask.execute(any(), any())).will(
					useArgument(1).method("onReturn").andCallWithArgs(testOutput, testTask) as Answer);

			factory.execute(testInput);

			verify().that(testTask.execute(eq(testInput), eq(factory)));
		}

		[Test(expects="Error")]
		public function Async_ShouldThrow():void
		{
			var factory:IAsyncFactory = async1(testTask);

			given(testTask.execute(any(), any())).will(
					useArgument(1).method("Throw").andCallWithArgs(new Error(), testTask) as Answer);

			factory.execute(testInput);

			verify().that(testTask.execute(eq(testInput), eq(factory)));
		}

		[Test]
		public function Async_ShouldSetIAsync():void
		{
			var factory:AsyncFactory = async1(testTask) as AsyncFactory;
			assertNotNull(factory);
			assertEquals(factory.task, testTask);
		}

		[Test]
		public function Async_ShouldSetFunction():void
		{
			var func:Function = function ():void
			{
			};
			var factory:AsyncFactory = async1(func) as AsyncFactory;

			assertNotNull(factory);
			assertTrue(factory.task is Func);
			assertEquals(Func(factory.task).func, func);
		}

		[Test]
		public function Async_ShouldSetData():void
		{
			var factory:AsyncFactory = async1(testInput) as AsyncFactory;

			assertNotNull(factory);
			assertTrue(factory.task is Data);
			assertTrue(Data(factory.task).value, testInput);
		}

		[Test]
		public function Async_ShouldSetNull():void
		{
			var factory:AsyncFactory = async1(null) as AsyncFactory;

			assertNotNull(factory);
			assertTrue(factory.task is Data);
			assertNull(Data(factory.task).value);
		}

		[Test]
		public function Next_ShouldCreateSequence():void
		{
			var func:Function = function ():void
			{
			};
			var factory:AsyncFactory = async1(null)
							.Next(testTask)
							.Next(func)
							.Next(testInput) as AsyncFactory;

			assertNotNull(factory);
			assertTrue(factory.task is Sequence);
			assertNotNull(Sequence(factory.task).tasks);
			assertEquals(Sequence(factory.task).tasks.length, 4);
			assertTrue(Sequence(factory.task).tasks[0] is Data);
			assertNull(Data(Sequence(factory.task).tasks[0]).value);
			assertEquals(Sequence(factory.task).tasks[1], testTask);
			assertTrue(Sequence(factory.task).tasks[2] is Func);
			assertEquals(Func(Sequence(factory.task).tasks[2]).func, func);
			assertTrue(Sequence(factory.task).tasks[3] is Data);
			assertTrue(Data(Sequence(factory.task).tasks[3]), testInput);
		}

		[Test]
		public function Concurrent_ShouldCreateConcurrence():void
		{
			var func:Function = function ():void
			{
			};
			var factory:AsyncFactory = async1(null)
							.Concurrent(testTask)
							.Concurrent(func)
							.Concurrent(testInput) as AsyncFactory;

			assertNotNull(factory);
			assertTrue(factory.task is Concurrence);
			assertNotNull(Concurrence(factory.task).tasks);
			assertEquals(Concurrence(factory.task).tasks.length, 4);
			assertTrue(Concurrence(factory.task).tasks[0] is Data);
			assertNull(Data(Concurrence(factory.task).tasks[0]).value);
			assertEquals(Concurrence(factory.task).tasks[1], testTask);
			assertTrue(Concurrence(factory.task).tasks[2] is Func);
			assertEquals(Func(Concurrence(factory.task).tasks[2]).func, func);
			assertTrue(Concurrence(factory.task).tasks[3] is Data);
			assertTrue(Data(Concurrence(factory.task).tasks[3]), testInput);
		}
	}
}