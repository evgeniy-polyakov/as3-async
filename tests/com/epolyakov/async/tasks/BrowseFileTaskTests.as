package com.epolyakov.async.tasks
{
	import com.epolyakov.async.core.mocks.MockResult;
	import com.epolyakov.async.tasks.mocks.MockFileReference;
	import com.epolyakov.mock.It;
	import com.epolyakov.mock.Mock;

	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.utils.setTimeout;

	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class BrowseFileTaskTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test]
		public function await_ShouldCallBrowse():void
		{
			var filters:Array = [new FileFilter("", ""), new FileFilter("", "")];
			var task:BrowseFileTask = new BrowseFileTask(filters);
			task.mockFileReference = new MockFileReference();
			var result:MockResult = new MockResult();

			task.await({}, result);

			Mock.verify().that(task.mockFileReference.browse(filters))
					.verify().total(1);
		}

		[Test]
		public function await_ShouldThrowIfBrowseThrows():void
		{
			var filters:Array = [new FileFilter("", ""), new FileFilter("", "")];
			var task:BrowseFileTask = new BrowseFileTask(filters);
			task.mockFileReference = new MockFileReference();
			var result:MockResult = new MockResult();
			var error:Error = new Error();

			Mock.setup().that(task.mockFileReference.browse(filters)).throws(error);

			task.await({}, result);

			Mock.verify().that(task.mockFileReference.browse(filters))
					.verify().that(result.onThrow(error, task))
					.verify().total(2);

			assertFalse(task.mockFileReference.hasEventListener(Event.SELECT));
			assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
		}

		[Test]
		public function await_ShouldReturnIfSelect():void
		{
			var result:MockResult = new MockResult();
			var task:BrowseFileTask = new BrowseFileTask();
			task.mockFileReference = new MockFileReference();

			task.await({}, result);

			task.mockFileReference.dispatchEvent(new Event(Event.SELECT));

			Mock.verify().that(task.mockFileReference.browse(It.isAny()))
					.verify().that(result.onReturn(task.mockFileReference, task))
					.verify().total(2);

			assertFalse(task.mockFileReference.hasEventListener(Event.SELECT));
			assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
		}

		[Test]
		public function await_ShouldThrowIfCancel():void
		{
			var result:MockResult = new MockResult();
			var task:BrowseFileTask = new BrowseFileTask();
			var event:Event = new Event(Event.CANCEL);
			task.mockFileReference = new MockFileReference();

			task.await({}, result);

			task.mockFileReference.dispatchEvent(event);

			Mock.verify().that(task.mockFileReference.browse(It.isAny()))
					.verify().that(result.onThrow(event, task))
					.verify().total(2);

			assertFalse(task.mockFileReference.hasEventListener(Event.SELECT));
			assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
		}

		[Test(async, timeout=1000)]
		public function await_ShouldReturnIfSelectAsync():void
		{
			var result:MockResult = new MockResult();
			var task:BrowseFileTask = new BrowseFileTask();
			task.mockFileReference = new MockFileReference();

			task.await({}, result);

			setTimeout(task.mockFileReference.dispatchEvent, 100, new Event(Event.SELECT));

			Async.handleEvent(this, result, Event.COMPLETE, function (...arg):void
			{
				Mock.verify().that(task.mockFileReference.browse(It.isAny()))
						.verify().that(result.onReturn(task.mockFileReference, task))
						.verify().total(2);

				assertFalse(task.mockFileReference.hasEventListener(Event.SELECT));
				assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
			});
			Async.failOnEvent(this, result, Event.CANCEL);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldThrowIfCancelAsync():void
		{
			var result:MockResult = new MockResult();
			var task:BrowseFileTask = new BrowseFileTask();
			var event:Event = new Event(Event.CANCEL);
			task.mockFileReference = new MockFileReference();

			task.await({}, result);

			setTimeout(task.mockFileReference.dispatchEvent, 100, event);

			Async.handleEvent(this, result, Event.CANCEL, function (...arg):void
			{
				Mock.verify().that(task.mockFileReference.browse(It.isAny()))
						.verify().that(result.onThrow(event, task))
						.verify().total(2);

				assertFalse(task.mockFileReference.hasEventListener(Event.SELECT));
				assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
			});
			Async.failOnEvent(this, result, Event.COMPLETE);
		}

		[Test]
		public function cancel_ShouldCallCancel():void
		{
			var result:MockResult = new MockResult();
			var task:BrowseFileTask = new BrowseFileTask();
			task.mockFileReference = new MockFileReference();

			task.await({}, result);
			task.cancel();

			Mock.verify().that(task.mockFileReference.browse(It.isAny()))
					.verify().that(task.mockFileReference.cancel())
					.verify().total(2);
		}

		[Test]
		public function cancel_ShouldRemoveEventHandlers():void
		{
			var result:MockResult = new MockResult();
			var task:BrowseFileTask = new BrowseFileTask();
			task.mockFileReference = new MockFileReference();

			task.await({}, result);

			assertTrue(task.mockFileReference.hasEventListener(Event.SELECT));
			assertTrue(task.mockFileReference.hasEventListener(Event.CANCEL));

			task.cancel();

			assertFalse(task.mockFileReference.hasEventListener(Event.SELECT));
			assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
		}
	}
}
