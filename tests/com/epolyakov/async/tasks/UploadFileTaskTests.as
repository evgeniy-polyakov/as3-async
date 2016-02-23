package com.epolyakov.async.tasks
{
	import com.epolyakov.async.core.mocks.MockResult;
	import com.epolyakov.async.tasks.mocks.MockFileReference;
	import com.epolyakov.mock.It;
	import com.epolyakov.mock.Mock;

	import flash.events.DataEvent;
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
	public class UploadFileTaskTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test]
		public function await_ShouldFailIfNotFileReference():void
		{
			var task:UploadFileTask = new UploadFileTask("test");
			var result:MockResult = new MockResult();

			task.await({}, result);

			Mock.verify().that(result.onThrow(It.isOfType(ArgumentError), task))
					.verify().total(1);
		}

		[Test]
		public function await_URLRequest_ShouldCallUpload():void
		{
			var request:URLRequest = new URLRequest();
			var task:UploadFileTask = new UploadFileTask(request, "file-data-field");
			var fileReference:MockFileReference = new MockFileReference();
			var result:MockResult = new MockResult();

			task.await(fileReference, result);

			Mock.verify().that(fileReference.upload(request, "file-data-field", false))
					.verify().total(1);
		}

		[Test]
		public function await_String_ShouldCallUpload():void
		{
			var task:UploadFileTask = new UploadFileTask("path/to/file", "file-data-field");
			var fileReference:MockFileReference = new MockFileReference();
			var result:MockResult = new MockResult();

			task.await(fileReference, result);

			Mock.verify().that(fileReference.upload(It.match(function (r:URLRequest):Boolean
					{
						return r.url == "path/to/file";
					}), "file-data-field", It.isFalse()))
					.verify().total(1);
		}

		[Test]
		public function await_ShouldThrowIfUploadThrows():void
		{
			var task:UploadFileTask = new UploadFileTask("test");
			var fileReference:MockFileReference = new MockFileReference();
			var result:MockResult = new MockResult();
			var error:Error = new Error();

			Mock.setup().that(fileReference.upload(It.isAny(), It.isAny(), It.isAny())).throws(error);

			task.await(fileReference, result);

			Mock.verify().that(fileReference.upload(It.isAny(), It.isAny(), It.isAny()))
					.verify().that(result.onThrow(error, task))
					.verify().total(2);

			assertFalse(fileReference.hasEventListener(DataEvent.UPLOAD_COMPLETE_DATA));
			assertFalse(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			assertFalse(fileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
		}

		[Test]
		public function await_ShouldReturnIfComplete():void
		{
			var result:MockResult = new MockResult();
			var task:UploadFileTask = new UploadFileTask("test");
			var fileReference:MockFileReference = new MockFileReference();

			task.await(fileReference, result);

			var event:DataEvent = new DataEvent(DataEvent.UPLOAD_COMPLETE_DATA);
			event.data = "some-data";
			fileReference.dispatchEvent(event);

			Mock.verify().that(fileReference.upload(It.isAny(), It.isAny(), It.isAny()))
					.verify().that(result.onReturn("some-data", task))
					.verify().total(2);

			assertFalse(fileReference.hasEventListener(DataEvent.UPLOAD_COMPLETE_DATA));
			assertFalse(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			assertFalse(fileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
		}

		[Test]
		public function await_ShouldThrowIfIOError():void
		{
			var result:MockResult = new MockResult();
			var task:UploadFileTask = new UploadFileTask("test");
			var event:Event = new IOErrorEvent(IOErrorEvent.IO_ERROR);
			var fileReference:MockFileReference = new MockFileReference();

			task.await(fileReference, result);

			fileReference.dispatchEvent(event);

			Mock.verify().that(fileReference.upload(It.isAny(), It.isAny(), It.isAny()))
					.verify().that(result.onThrow(event, task))
					.verify().total(2);

			assertFalse(fileReference.hasEventListener(DataEvent.UPLOAD_COMPLETE_DATA));
			assertFalse(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			assertFalse(fileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
		}

		[Test]
		public function await_ShouldThrowIfSecurityError():void
		{
			var result:MockResult = new MockResult();
			var task:UploadFileTask = new UploadFileTask("test");
			var event:Event = new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR);
			var fileReference:MockFileReference = new MockFileReference();

			task.await(fileReference, result);

			fileReference.dispatchEvent(event);

			Mock.verify().that(fileReference.upload(It.isAny(), It.isAny(), It.isAny()))
					.verify().that(result.onThrow(event, task))
					.verify().total(2);

			assertFalse(fileReference.hasEventListener(DataEvent.UPLOAD_COMPLETE_DATA));
			assertFalse(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			assertFalse(fileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
		}

		[Test(async, timeout=1000)]
		public function await_ShouldReturnICompleteAsync():void
		{
			var result:MockResult = new MockResult();
			var task:UploadFileTask = new UploadFileTask("test");
			var fileReference:MockFileReference = new MockFileReference();

			task.await(fileReference, result);

			var event:DataEvent = new DataEvent(DataEvent.UPLOAD_COMPLETE_DATA);
			event.data = "some-data";
			setTimeout(fileReference.dispatchEvent, 100, event);

			Async.handleEvent(this, result, Event.COMPLETE, function (...arg):void
			{
				Mock.verify().that(fileReference.upload(It.isAny(), It.isAny(), It.isAny()))
						.verify().that(result.onReturn("some-data", task))
						.verify().total(2);

				assertFalse(fileReference.hasEventListener(DataEvent.UPLOAD_COMPLETE_DATA));
				assertFalse(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
				assertFalse(fileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
			});
			Async.failOnEvent(this, result, Event.CANCEL);
		}

		[Test(async, timeout=1000)]
		public function await_ShouldThrowIfIOErrorAsync():void
		{
			var result:MockResult = new MockResult();
			var task:UploadFileTask = new UploadFileTask("test");
			var event:Event = new IOErrorEvent(IOErrorEvent.IO_ERROR);
			var fileReference:MockFileReference = new MockFileReference();

			task.await(fileReference, result);

			setTimeout(fileReference.dispatchEvent, 100, event);

			Async.handleEvent(this, result, Event.CANCEL, function (...arg):void
			{
				Mock.verify().that(fileReference.upload(It.isAny(), It.isAny(), It.isAny()))
						.verify().that(result.onThrow(event, task))
						.verify().total(2);

				assertFalse(fileReference.hasEventListener(DataEvent.UPLOAD_COMPLETE_DATA));
				assertFalse(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
				assertFalse(fileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
			});
			Async.failOnEvent(this, result, Event.COMPLETE);
		}

		[Test]
		public function cancel_ShouldCallCancel():void
		{
			var result:MockResult = new MockResult();
			var task:UploadFileTask = new UploadFileTask("test");
			var fileReference:MockFileReference = new MockFileReference();

			task.await(fileReference, result);
			task.cancel();

			Mock.verify().that(fileReference.upload(It.isAny(), It.isAny(), It.isAny()))
					.verify().that(fileReference.cancel())
					.verify().total(2);
		}

		[Test]
		public function cancel_ShouldRemoveEventHandlers():void
		{
			var result:MockResult = new MockResult();
			var task:UploadFileTask = new UploadFileTask("test");
			var fileReference:MockFileReference = new MockFileReference();

			task.await(fileReference, result);

			assertTrue(fileReference.hasEventListener(DataEvent.UPLOAD_COMPLETE_DATA));
			assertTrue(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			assertTrue(fileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));

			task.cancel();

			assertFalse(fileReference.hasEventListener(DataEvent.UPLOAD_COMPLETE_DATA));
			assertFalse(fileReference.hasEventListener(IOErrorEvent.IO_ERROR));
			assertFalse(fileReference.hasEventListener(SecurityErrorEvent.SECURITY_ERROR));
		}
	}
}
