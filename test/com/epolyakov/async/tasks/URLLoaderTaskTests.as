package com.epolyakov.async.tasks
{
	import com.epolyakov.async.tasks.mocks.MockResultDispatcher;
	import com.epolyakov.mock.It;
	import com.epolyakov.mock.Mock;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;

	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class URLLoaderTaskTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test(async, timeout=1000)]
		public function await_ShouldLoadUrl():void
		{
			shouldLoad(new URLLoaderTask("com/epolyakov/async/tasks/data/data.txt"));
		}

		[Test(async, timeout=1000)]
		public function await_ShouldLoadUrlRequest():void
		{
			shouldLoad(new URLLoaderTask(new URLRequest("com/epolyakov/async/tasks/data/data.txt")));
		}

		[Test]
		public function await_ShouldThrowIfWrongURLRequest():void
		{
			var result:MockResultDispatcher = new MockResultDispatcher();
			var task:URLLoaderTask = new URLLoaderTask(new URLRequest(null));

			task.await(null, result);
			Mock.verify().that(result.onThrow(It.isOfType(TypeError), It.isEqual(task)), 1)
					.verify().total(1);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldRemoveEventListenersIfComplete():void
		{
			var result:MockResultDispatcher = new MockResultDispatcher();
			var task:URLLoaderTask = new URLLoaderTask("com/epolyakov/async/tasks/data/data.txt");

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(result.onReturn(It.match(function (value:Object):Boolean
						{
							return value is URLLoader
									&& !URLLoader(value).hasEventListener(Event.COMPLETE)
									&& !URLLoader(value).hasEventListener(IOErrorEvent.IO_ERROR)
									&& !URLLoader(value).hasEventListener(SecurityErrorEvent.SECURITY_ERROR);
						}), It.isEqual(task)), 1)
						.verify().total(1);
			});
			Async.failOnEvent(this, result, Event.CANCEL);

			task.await(null, result);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldRemoveEventListenersIfError():void
		{
			var result:MockResultDispatcher = new MockResultDispatcher();
			var task:URLLoaderTask = new URLLoaderTask("wrong-url");

			Async.handleEvent(this, result, Event.CANCEL, function (...rest):void
			{
				Mock.verify().that(result.onThrow(It.match(function (value:Object):Boolean
						{
							return value is Event
									&& !Event(value).target.hasEventListener(Event.COMPLETE)
									&& !Event(value).target.hasEventListener(IOErrorEvent.IO_ERROR)
									&& !Event(value).target.hasEventListener(SecurityErrorEvent.SECURITY_ERROR);
						}), It.isEqual(task)), 1)
						.verify().total(1);
			});
			Async.failOnEvent(this, result, Event.COMPLETE);

			task.await(null, result);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldLoadText():void
		{
			var result:MockResultDispatcher = new MockResultDispatcher();
			var task:URLLoaderTask = new URLLoaderTask("com/epolyakov/async/tasks/data/data.txt", URLLoaderDataFormat.TEXT);

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(result.onReturn(It.match(function (value:Object):Boolean
						{
							return value is URLLoader
									&& URLLoader(value).dataFormat == URLLoaderDataFormat.TEXT
									&& URLLoader(value).data == "test=data";
						}), It.isEqual(task)), 1)
						.verify().total(1);
			});
			Async.failOnEvent(this, result, Event.CANCEL);

			task.await(null, result);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldLoadBinary():void
		{
			var result:MockResultDispatcher = new MockResultDispatcher();
			var task:URLLoaderTask = new URLLoaderTask("com/epolyakov/async/tasks/data/data.txt", URLLoaderDataFormat.BINARY);

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(result.onReturn(It.match(function (value:Object):Boolean
						{
							return value is URLLoader
									&& URLLoader(value).dataFormat == URLLoaderDataFormat.BINARY
									&& URLLoader(value).data is ByteArray;
						}), It.isEqual(task)), 1)
						.verify().total(1);
			});
			Async.failOnEvent(this, result, Event.CANCEL);

			task.await(null, result);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldLoadVariables():void
		{
			var result:MockResultDispatcher = new MockResultDispatcher();
			var task:URLLoaderTask = new URLLoaderTask("com/epolyakov/async/tasks/data/data.txt", URLLoaderDataFormat.VARIABLES);

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(result.onReturn(It.match(function (value:Object):Boolean
						{
							return value is URLLoader
									&& URLLoader(value).dataFormat == URLLoaderDataFormat.VARIABLES
									&& URLLoader(value).data is URLVariables
									&& URLLoader(value).data.test == "data";
						}), It.isEqual(task)), 1)
						.verify().total(1);
			});
			Async.failOnEvent(this, result, Event.CANCEL);

			task.await(null, result);
		}

		[Test]
		public function cancel_ShouldNotThrow():void
		{
			new URLLoaderTask("test").cancel();
		}

		[Test(async, timeout=1000)]
		public function cancel_ShouldCancelLoading():void
		{
			var result:MockResultDispatcher = new MockResultDispatcher();
			var task:URLLoaderTask = new URLLoaderTask("com/epolyakov/async/tasks/data/data.txt");

			task.await(null, result);
			task.cancel();

			Mock.verify().total(0);

			Async.failOnEvent(this, result, Event.COMPLETE, 400);
			Async.failOnEvent(this, result, Event.CANCEL, 400);
		}

		private function shouldLoad(task:URLLoaderTask):void
		{
			var result:MockResultDispatcher = new MockResultDispatcher();

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				assertFalse(task.active);
				Mock.verify().that(result.onReturn(It.match(function (value:Object):Boolean
						{
							return value is URLLoader
									&& URLLoader(value).data == "test=data";
						}), It.isEqual(task)), 1)
						.verify().total(1);
			});
			Async.failOnEvent(this, result, Event.CANCEL);

			task.await(null, result);
			assertTrue(task.active);
		}
	}
}
