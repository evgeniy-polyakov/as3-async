package com.epolyakov.async.tasks
{
	import com.epolyakov.async.tasks.mocks.MockResultDispatcher;
	import com.epolyakov.mock.It;
	import com.epolyakov.mock.Mock;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
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
		[Embed("data/32.png", mimeType="application/octet-stream")]
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
			shouldLoad(new LoaderTask("com/epolyakov/async/tasks/data/32.png"));
		}

		[Test(async, timeout=1000)]
		public function await_ShouldLoadUrlRequest():void
		{
			shouldLoad(new LoaderTask(new URLRequest("com/epolyakov/async/tasks/data/32.png")));
		}

		[Test]
		public function await_ShouldThrowIfWrongClass():void
		{
			var result:MockResultDispatcher = new MockResultDispatcher();
			var task:LoaderTask = new LoaderTask(Sprite);

			task.await(null, result);
			Mock.verify().that(result.onThrow(It.isOfType(TypeError), It.isEqual(task)), 1)
					.verify().total(1);
		}

		[Test]
		public function await_ShouldThrowIfWrongContext():void
		{
			var result:MockResultDispatcher = new MockResultDispatcher();
			var context:LoaderContext = new LoaderContext();
			context.parameters = [Sprite];
			var task:LoaderTask = new LoaderTask("test", context);

			task.await(null, result);
			Mock.verify().that(result.onThrow(It.isOfType(IllegalOperationError), It.isEqual(task)), 1)
					.verify().total(1);
		}

		private function shouldLoad(task:LoaderTask):void
		{
			var result:MockResultDispatcher = new MockResultDispatcher();

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
