package com.epolyakov.asynctasks.impl
{
	import com.epolyakov.asynctasks.core.Task;

	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;

	/**
	 * @author Evgeniy S. Polyakov
	 *
	 * The UploadFileTask uses FileReference object to upload local files to the server.
	 *
	 * @param FileReference object.
	 * @return String data returned by the server.
	 * @throw TaskDataError, IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR, errors thrown by FileReference.upload().
	 */
	public class UploadFileTask extends Task
	{
		private var _file:FileReference;
		private var _source:Object;
		private var _dataFieldName:String;
		private var _testUpload:Boolean;
		private var _waitForServerData:Boolean;

		/**
		 * @param source - The URLRequest object or string with url of file to upload.
		 * @param dataFieldName - The data field name in the upload request.
		 * @param testUpload - If true just test upload function without sending the actual data.
		 * @param waitForServerData - If true wait until the server returns the response.
		 */
		public function UploadFileTask(source:Object = null, dataFieldName:String = "Filedata",
									   testUpload:Boolean = false, waitForServerData:Boolean = true)
		{
			_source = source;
			_dataFieldName = dataFieldName;
			_testUpload = testUpload;
			_waitForServerData = waitForServerData;
		}

		override protected function doExecute():void
		{
			_file = data as FileReference;
			if (!_file)
			{
				Throw(new ArgumentError("UploadFileTask expects a FileReference object, got " + data + "."));
				return;
			}
			var request:URLRequest;
			if (_source is URLRequest)
			{
				request = _source as URLRequest;
			}
			else
			{
				request = new URLRequest(String(_source));
			}
			addEventHandlers();
			try
			{
				_file.upload(request, _dataFieldName, _testUpload);
			}
			catch (error:Error)
			{
				removeEventHandlers();
				Throw(error);
			}
		}

		override protected function doInterrupt():void
		{
			removeEventHandlers();
			try
			{
				_file.cancel();
			}
			catch (error:Error)
			{
			}
			_file = null;
		}

		private function addEventHandlers():void
		{
			if (_file)
			{
				if (_waitForServerData)
				{
					_file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, completeEventDataHandler);
				}
				else
				{
					_file.addEventListener(Event.COMPLETE, completeEventHandler);
				}
				_file.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
				_file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			}
		}

		private function removeEventHandlers():void
		{
			if (_file)
			{
				_file.removeEventListener(Event.COMPLETE, completeEventHandler);
				_file.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, completeEventDataHandler);
				_file.removeEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
				_file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			}
		}

		private function completeEventHandler(event:Event):void
		{
			removeEventHandlers();
			var file:FileReference = _file;
			_file = null;
			Return(file);
		}

		private function completeEventDataHandler(event:DataEvent):void
		{
			removeEventHandlers();
			_file = null;
			Return(event.data);
		}

		private function errorEventHandler(event:Event):void
		{
			removeEventHandlers();
			_file = null;
			Throw(event);
		}
	}
}