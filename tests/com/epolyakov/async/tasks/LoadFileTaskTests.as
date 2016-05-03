package com.epolyakov.async.tasks
{
	import com.epolyakov.async.mocks.MockResult;
	import com.epolyakov.async.tasks.mocks.MockFileReference;
	import com.epolyakov.mock.It;
	import com.epolyakov.mock.Mock;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.setTimeout;

	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class LoadFileTaskTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test]
		public function await_ShouldFailIfNotFileReference():void
		{
			var task:LoadFileTask = new LoadFileTask();
			var result:MockResult = new MockResult();

			task.await({}, result);

			Mock.verify().that(result.onThrow(It.isOfType(ArgumentError), task))
					.verify().total(1);
		}

		[Test]
		public function await_ShouldCallLoad():void
		{
			var task:LoadFileTask = new LoadFileTask();
			var fileReference:MockFileReference = new MockFileReference();
			var result:MockResult = new MockResult();

			task.await(fileReference, result);

			Mock.verify().that(fileReference.load())
					.verify().total(1);
		}

		[Test]
		public function await_ShouldThrowIfLoadThrows():void
		{
			var task:LoadFileTask = new LoadFileTask();
			var fileReference:MockFileReference = new MockFileReference();
			var result:MockResult = new MockResult();
			var error:Error = new Error();

			Mock.setup().that(fileReference.load()).throws(error);

			task.await(fileReference, result);

			Mock.verify().that(fileReference.load())
					.verify().that(result.onThrow(error, task))
					.verify().total(2);

			assertFalse(fileReference.hasEventListener(Event.COMPLETE));
			assertFalse(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
		}

		[Test]
		public function await_ShouldReturnIfComplete():void
		{
			var result:MockResult = new MockResult();
			var task:LoadFileTask = new LoadFileTask();
			var fileReference:MockFileReference = new MockFileReference();

			task.await(fileReference, result);

			fileReference.dispatchEvent(new Event(Event.COMPLETE));

			Mock.verify().that(fileReference.load())
					.verify().that(result.onReturn(fileReference, task))
					.verify().total(2);

			assertFalse(fileReference.hasEventListener(Event.COMPLETE));
			assertFalse(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
		}

		[Test]
		public function await_ShouldThrowIfIOError():void
		{
			var result:MockResult = new MockResult();
			var task:LoadFileTask = new LoadFileTask();
			var event:Event = new IOErrorEvent(IOErrorEvent.IO_ERROR);
			var fileReference:MockFileReference = new MockFileReference();

			task.await(fileReference, result);

			fileReference.dispatchEvent(event);

			Mock.verify().that(fileReference.load())
					.verify().that(result.onThrow(event, task))
					.verify().total(2);

			assertFalse(fileReference.hasEventListener(Event.COMPLETE));
			assertFalse(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
		}

		[Test(async, timeout=1000)]
		public function await_ShouldReturnICompleteAsync():void
		{
			var result:MockResult = new MockResult();
			var task:LoadFileTask = new LoadFileTask();
			var fileReference:MockFileReference = new MockFileReference();

			task.await(fileReference, result);

			setTimeout(fileReference.dispatchEvent, 100, new Event(Event.COMPLETE));

			Async.handleEvent(this, result, Event.COMPLETE, function (...arg):void
			{
				Mock.verify().that(fileReference.load())
						.verify().that(result.onReturn(fileReference, task))
						.verify().total(2);

				assertFalse(fileReference.hasEventListener(Event.COMPLETE));
				assertFalse(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			});
			Async.failOnEvent(this, result, Event.CANCEL);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldThrowIfIOErrorAsync():void
		{
			var result:MockResult = new MockResult();
			var task:LoadFileTask = new LoadFileTask();
			var event:Event = new IOErrorEvent(IOErrorEvent.IO_ERROR);
			var fileReference:MockFileReference = new MockFileReference();

			task.await(fileReference, result);

			setTimeout(fileReference.dispatchEvent, 100, event);

			Async.handleEvent(this, result, Event.CANCEL, function (...arg):void
			{
				Mock.verify().that(fileReference.load())
						.verify().that(result.onThrow(event, task))
						.verify().total(2);

				assertFalse(fileReference.hasEventListener(Event.COMPLETE));
				assertFalse(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			});
			Async.failOnEvent(this, result, Event.COMPLETE);
		}

		[Test]
		public function cancel_ShouldCallCancel():void
		{
			var result:MockResult = new MockResult();
			var task:LoadFileTask = new LoadFileTask();
			var fileReference:MockFileReference = new MockFileReference();

			task.await(fileReference, result);
			task.cancel();

			Mock.verify().that(fileReference.load())
					.verify().that(fileReference.cancel())
					.verify().total(2);
		}

		[Test]
		public function cancel_ShouldRemoveEventHandlers():void
		{
			var result:MockResult = new MockResult();
			var task:LoadFileTask = new LoadFileTask();
			var fileReference:MockFileReference = new MockFileReference();

			task.await(fileReference, result);

			assertTrue(fileReference.hasEventListener(Event.COMPLETE));
			assertTrue(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));

			task.cancel();

			assertFalse(fileReference.hasEventListener(Event.COMPLETE));
			assertFalse(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
		}
	}
}
