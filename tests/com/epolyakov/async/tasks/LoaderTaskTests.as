package com.epolyakov.async.tasks
{
	import com.epolyakov.async.core.mocks.MockResult;
	import com.epolyakov.mock.It;
	import com.epolyakov.mock.Mock;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class LoaderTaskTests
	{
		[Embed("data/data.png", mimeType="application/octet-stream")]
		private var _byteArrayClass:Class;

		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test(async, timeout=1000)]
		public function await_ShouldLoadByteArrayClass():void
		{
			shouldLoad(new LoaderTask(_byteArrayClass));
		}

		[Test(async, timeout=1000)]
		public function await_ShouldLoadByteArray():void
		{
			shouldLoad(new LoaderTask(new _byteArrayClass()));
		}

		[Test(async, timeout=1000)]
		public function await_ShouldLoadUrl():void
		{
			shouldLoad(new LoaderTask("com/epolyakov/async/tasks/data/data.png"));
		}

		[Test(async, timeout=1000)]
		public function await_ShouldLoadUrlRequest():void
		{
			shouldLoad(new LoaderTask(new URLRequest("com/epolyakov/async/tasks/data/data.png")));
		}

		[Test]
		public function await_ShouldThrowIfWrongClass():void
		{
			var result:MockResult = new MockResult();
			var task:LoaderTask = new LoaderTask(Sprite);

			task.await(null, result);
			Mock.verify().that(result.onThrow(It.isOfType(TypeError), It.isEqual(task)), 1)
					.verify().total(1);
		}

		[Test]
		public function await_ShouldThrowIfWrongContext():void
		{
			var result:MockResult = new MockResult();
			var context:LoaderContext = new LoaderContext();
			context.parameters = [Sprite];
			var task:LoaderTask = new LoaderTask("test", context);

			task.await(null, result);
			Mock.verify().that(result.onThrow(It.isOfType(IllegalOperationError), It.isEqual(task)), 1)
					.verify().total(1);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldRemoveEventListenersIfComplete():void
		{
			var result:MockResult = new MockResult();
			var task:LoaderTask = new LoaderTask(_byteArrayClass);

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				Mock.verify().that(result.onReturn(It.match(function (value:Object):Boolean
						{
							return value is Loader
									&& !Loader(value).contentLoaderInfo.hasEventListener(Event.COMPLETE)
									&& !Loader(value).contentLoaderInfo.hasEventListener(IOErrorEvent.IO_ERROR)
									&& !Loader(value).contentLoaderInfo.hasEventListener(SecurityErrorEvent.SECURITY_ERROR);
						}), It.isEqual(task)), 1)
						.verify().total(1);
			});
			Async.failOnEvent(this, result, Event.CANCEL);

			task.await(null, result);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldRemoveEventListenersIfError():void
		{
			var result:MockResult = new MockResult();
			var task:LoaderTask = new LoaderTask("wrong-url");

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

		[Test]
		public function cancel_ShouldNotThrow():void
		{
			new LoaderTask("test").cancel();
		}

		[Test(async, timeout=1000)]
		public function cancel_ShouldCancelLoading():void
		{
			var result:MockResult = new MockResult();
			var task:LoaderTask = new LoaderTask(_byteArrayClass);

			task.await(null, result);
			task.cancel();

			Mock.verify().total(0);

			Async.failOnEvent(this, result, Event.COMPLETE, 400);
			Async.failOnEvent(this, result, Event.CANCEL, 400);
		}

		private function shouldLoad(task:LoaderTask):void
		{
			var result:MockResult = new MockResult();

			Async.handleEvent(this, result, Event.COMPLETE, function (...rest):void
			{
				assertFalse(task.active);
				Mock.verify().that(result.onReturn(It.match(function (value:Object):Boolean
						{
							return value is Loader
									&& Loader(value).content is Bitmap
									&& Bitmap(Loader(value).content).width == 32
									&& Bitmap(Loader(value).content).height == 32
						}), It.isEqual(task)), 1)
						.verify().total(1);
			});
			Async.failOnEvent(this, result, Event.CANCEL);

			task.await(null, result);
			assertTrue(task.active);
		}
	}
}
