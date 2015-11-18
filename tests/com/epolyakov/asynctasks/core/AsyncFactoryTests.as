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
		public function async_shouldResultReturn():void
		{
			var factory:IAsyncFactory = async(testTask);

			given(testTask.execute(any(), any())).will(
					useArgument(1).method("onReturn").andCallWithArgs(testOutput, testTask) as Answer);

			factory.execute(testInput, testResult);

			inOrder().verify().that(testTask.execute(eq(testInput), eq(factory)));
			inOrder().verify().that(testResult.onReturn(eq(testOutput), eq(factory)));
		}

		[Test]
		public function async_shouldResultThrow():void
		{
			var factory:IAsyncFactory = async(testTask);

			given(testTask.execute(any(), any())).will(
					useArgument(1).method("onThrow").andCallWithArgs(testOutput, testTask) as Answer);

			factory.execute(testInput, testResult);

			inOrder().verify().that(testTask.execute(eq(testInput), eq(factory)));
			inOrder().verify().that(testResult.onThrow(eq(testOutput), eq(factory)));
		}

		[Test]
		public function async_shouldReturn():void
		{
			var factory:IAsyncFactory = async(testTask);

			given(testTask.execute(any(), any())).will(
					useArgument(1).method("onReturn").andCallWithArgs(testOutput, testTask) as Answer);

			factory.execute(testInput);

			verify().that(testTask.execute(eq(testInput), eq(factory)));
		}

		[Test(expects="Error")]
		public function async_shouldThrow():void
		{
			var factory:IAsyncFactory = async(testTask);

			given(testTask.execute(any(), any())).will(
					useArgument(1).method("Throw").andCallWithArgs(new Error(), testTask) as Answer);

			factory.execute(testInput);

			verify().that(testTask.execute(eq(testInput), eq(factory)));
		}

		[Test]
		public function async_shouldSetIAsync():void
		{
			var factory:AsyncFactory = async(testTask) as AsyncFactory;
			assertNotNull(factory);
			assertEquals(factory.task, testTask);
		}

		[Test]
		public function async_shouldSetFunction():void
		{
			var func:Function = function ():void
			{
			};
			var factory:AsyncFactory = async(func) as AsyncFactory;

			assertNotNull(factory);
			assertTrue(factory.task is Func);
			assertEquals(Func(factory.task).func, func);
		}

		[Test]
		public function async_shouldSetData():void
		{
			var factory:AsyncFactory = async(testInput) as AsyncFactory;

			assertNotNull(factory);
			assertTrue(factory.task is Data);
			assertTrue(Data(factory.task).value, testInput);
		}

		[Test]
		public function async_shouldSetNull():void
		{
			var factory:AsyncFactory = async(null) as AsyncFactory;

			assertNotNull(factory);
			assertTrue(factory.task is Data);
			assertNull(Data(factory.task).value);
		}

		[Test]
		public function next_shouldCreateSequence():void
		{
			var func:Function = function ():void
			{
			};
			var factory:AsyncFactory = async(null)
							.then(testTask)
							.then(func)
							.then(testInput) as AsyncFactory;

			assertNotNull(factory);
			assertTrue(factory.task is AsyncFactory);
			assertNotNull(AsyncFactory(factory.task).tasks);
			assertEquals(AsyncFactory(factory.task).tasks.length, 4);
			assertTrue(AsyncFactory(factory.task).tasks[0] is Data);
			assertNull(Data(AsyncFactory(factory.task).tasks[0]).value);
			assertEquals(AsyncFactory(factory.task).tasks[1], testTask);
			assertTrue(AsyncFactory(factory.task).tasks[2] is Func);
			assertEquals(Func(AsyncFactory(factory.task).tasks[2]).func, func);
			assertTrue(AsyncFactory(factory.task).tasks[3] is Data);
			assertTrue(Data(AsyncFactory(factory.task).tasks[3]), testInput);
		}

		[Test]
		public function concurrent_shouldCreateConcurrence():void
		{
			var func:Function = function ():void
			{
			};
			var factory:AsyncFactory = async(null)
							.and(testTask)
							.and(func)
							.and(testInput) as AsyncFactory;

			assertNotNull(factory);
			assertTrue(factory.task is Concurrency);
			assertNotNull(Concurrency(factory.task).tasks);
			assertEquals(Concurrency(factory.task).tasks.length, 4);
			assertTrue(Concurrency(factory.task).tasks[0] is Data);
			assertNull(Data(Concurrency(factory.task).tasks[0]).value);
			assertEquals(Concurrency(factory.task).tasks[1], testTask);
			assertTrue(Concurrency(factory.task).tasks[2] is Func);
			assertEquals(Func(Concurrency(factory.task).tasks[2]).func, func);
			assertTrue(Concurrency(factory.task).tasks[3] is Data);
			assertTrue(Data(Concurrency(factory.task).tasks[3]), testInput);
		}
	}
}