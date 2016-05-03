package com.epolyakov.async.tasks
{
	import com.epolyakov.async.mocks.MockResult;
	import com.epolyakov.async.tasks.mocks.MockFileReference;
	import com.epolyakov.mock.It;
	import com.epolyakov.mock.Mock;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;

	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class DownloadFileTaskTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test]
		public function await_URLRequest_ShouldCallDownload():void
		{
			var request:URLRequest = new URLRequest("path/to/file");
			var task:DownloadFileTask = new DownloadFileTask(request, "file-name");
			task.mockFileReference = new MockFileReference();
			var result:MockResult = new MockResult();

			task.await({}, result);

			Mock.verify().that(task.mockFileReference.download(request, "file-name"))
					.verify().total(1);
		}

		[Test]
		public function await_String_ShouldCallDownload():void
		{
			var task:DownloadFileTask = new DownloadFileTask("path/to/file", "file-name");
			task.mockFileReference = new MockFileReference();
			var result:MockResult = new MockResult();

			task.await({}, result);

			Mock.verify().that(task.mockFileReference.download(It.match(function (r:URLRequest):Boolean
					{
						return r.url == "path/to/file";
					}), "file-name"))
					.verify().total(1);
		}

		[Test]
		public function await_ShouldThrowIfDownloadThrows():void
		{
			var task:DownloadFileTask = new DownloadFileTask("path/to/file");
			task.mockFileReference = new MockFileReference();
			var result:MockResult = new MockResult();
			var error:Error = new Error();

			Mock.setup().that(task.mockFileReference.download(It.isAny(), It.isAny())).throws(error);

			task.await({}, result);

			Mock.verify().that(task.mockFileReference.download(It.isAny(), It.isAny()))
					.verify().that(result.onThrow(error, task))
					.verify().total(2);

			assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
			assertFalse(task.mockFileReference.hasEventListener(Event.COMPLETE));
			assertFalse(task.mockFileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			assertFalse(task.mockFileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
		}

		[Test]
		public function await_ShouldReturnIfComplete():void
		{
			var result:MockResult = new MockResult();
			var task:DownloadFileTask = new DownloadFileTask("test");
			task.mockFileReference = new MockFileReference();

			task.await({}, result);

			task.mockFileReference.dispatchEvent(new Event(Event.COMPLETE));

			Mock.verify().that(task.mockFileReference.download(It.isAny(), It.isAny()))
					.verify().that(result.onReturn(task.mockFileReference, task))
					.verify().total(2);

			assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
			assertFalse(task.mockFileReference.hasEventListener(Event.COMPLETE));
			assertFalse(task.mockFileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			assertFalse(task.mockFileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
		}

		[Test]
		public function await_ShouldThrowIfCancel():void
		{
			var result:MockResult = new MockResult();
			var task:DownloadFileTask = new DownloadFileTask("test");
			var event:Event = new Event(Event.CANCEL);
			task.mockFileReference = new MockFileReference();

			task.await({}, result);

			task.mockFileReference.dispatchEvent(event);

			Mock.verify().that(task.mockFileReference.download(It.isAny(), It.isAny()))
					.verify().that(result.onThrow(event, task))
					.verify().total(2);

			assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
			assertFalse(task.mockFileReference.hasEventListener(Event.COMPLETE));
			assertFalse(task.mockFileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			assertFalse(task.mockFileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
		}

		[Test]
		public function await_ShouldThrowIfIOError():void
		{
			var result:MockResult = new MockResult();
			var task:DownloadFileTask = new DownloadFileTask("test");
			var event:Event = new IOErrorEvent(IOErrorEvent.IO_ERROR);
			task.mockFileReference = new MockFileReference();

			task.await({}, result);

			task.mockFileReference.dispatchEvent(event);

			Mock.verify().that(task.mockFileReference.download(It.isAny(), It.isAny()))
					.verify().that(result.onThrow(event, task))
					.verify().total(2);

			assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
			assertFalse(task.mockFileReference.hasEventListener(Event.COMPLETE));
			assertFalse(task.mockFileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			assertFalse(task.mockFileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
		}

		[Test]
		public function await_ShouldThrowIfSecurityError():void
		{
			var result:MockResult = new MockResult();
			var task:DownloadFileTask = new DownloadFileTask("test");
			var event:Event = new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR);
			task.mockFileReference = new MockFileReference();

			task.await({}, result);

			task.mockFileReference.dispatchEvent(event);

			Mock.verify().that(task.mockFileReference.download(It.isAny(), It.isAny()))
					.verify().that(result.onThrow(event, task))
					.verify().total(2);

			assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
			assertFalse(task.mockFileReference.hasEventListener(Event.COMPLETE));
			assertFalse(task.mockFileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			assertFalse(task.mockFileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
		}

		[Test(async, timeout=1000)]
		public function await_ShouldReturnIfCompleteAsync():void
		{
			var result:MockResult = new MockResult();
			var task:DownloadFileTask = new DownloadFileTask("test");
			task.mockFileReference = new MockFileReference();

			task.await({}, result);

			setTimeout(task.mockFileReference.dispatchEvent, 100, new Event(Event.COMPLETE));

			Async.handleEvent(this, result, Event.COMPLETE, function (...arg):void
			{
				Mock.verify().that(task.mockFileReference.download(It.isAny(), It.isAny()))
						.verify().that(result.onReturn(task.mockFileReference, task))
						.verify().total(2);

				assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
				assertFalse(task.mockFileReference.hasEventListener(Event.COMPLETE));
				assertFalse(task.mockFileReference.hasEventListener(IOErrorEvent.IO_ERROR));
				assertFalse(task.mockFileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
			});
			Async.failOnEvent(this, result, Event.CANCEL);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldThrowIfCancelAsync():void
		{
			var result:MockResult = new MockResult();
			var task:DownloadFileTask = new DownloadFileTask("test");
			var event:Event = new Event(Event.CANCEL);
			task.mockFileReference = new MockFileReference();

			task.await({}, result);

			setTimeout(task.mockFileReference.dispatchEvent, 100, event);

			Async.handleEvent(this, result, Event.CANCEL, function (...arg):void
			{
				Mock.verify().that(task.mockFileReference.download(It.isAny(), It.isAny()))
						.verify().that(result.onThrow(event, task))
						.verify().total(2);

				assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
				assertFalse(task.mockFileReference.hasEventListener(Event.COMPLETE));
				assertFalse(task.mockFileReference.hasEventListener(IOErrorEvent.IO_ERROR));
				assertFalse(task.mockFileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
			});
			Async.failOnEvent(this, result, Event.COMPLETE);
		}

		[Test]
		public function cancel_ShouldCallCancel():void
		{
			var result:MockResult = new MockResult();
			var task:DownloadFileTask = new DownloadFileTask("test");
			task.mockFileReference = new MockFileReference();

			task.await({}, result);
			task.cancel();

			Mock.verify().that(task.mockFileReference.download(It.isAny(), It.isAny()))
					.verify().that(task.mockFileReference.cancel())
					.verify().total(2);
		}

		[Test]
		public function cancel_ShouldRemoveEventHandlers():void
		{
			var result:MockResult = new MockResult();
			var task:DownloadFileTask = new DownloadFileTask("test");
			task.mockFileReference = new MockFileReference();

			task.await({}, result);

			assertTrue(task.mockFileReference.hasEventListener(Event.CANCEL));
			assertTrue(task.mockFileReference.hasEventListener(Event.COMPLETE));
			assertTrue(task.mockFileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			assertTrue(task.mockFileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));

			task.cancel();

			assertFalse(task.mockFileReference.hasEventListener(Event.CANCEL));
			assertFalse(task.mockFileReference.hasEventListener(Event.COMPLETE));
			assertFalse(task.mockFileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			assertFalse(task.mockFileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
		}
	}
}
