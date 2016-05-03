package com.epolyakov.async.tasks
{
	import com.epolyakov.async.Task;

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

		/**
		 * @param source - The URLRequest object or string with url of file to upload.
		 * @param dataFieldName - The data field name in the upload request.
		 */
		public function UploadFileTask(source:Object, dataFieldName:String = "Filedata")
		{
			_source = source;
			_dataFieldName = dataFieldName;
		}

		override protected function onAwait():void
		{
			_file = args as FileReference;
			if (!_file)
			{
				onThrow(new ArgumentError("UploadFileTask expects a FileReference object, got " + args + "."));
				return;
			}
			addEventHandlers();
			try
			{
				var request:URLRequest;
				if (_source is URLRequest)
				{
					request = _source as URLRequest;
				}
				else
				{
					request = new URLRequest(String(_source));
				}
				_file.upload(request, _dataFieldName);
			}
			catch (error:Error)
			{
				removeEventHandlers();
				_file = null;
				onThrow(error);
			}
		}

		override protected function onCancel():void
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
				_file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, completeEventHandler);
				_file.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
				_file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			}
		}

		private function removeEventHandlers():void
		{
			if (_file)
			{
				_file.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, completeEventHandler);
				_file.removeEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
				_file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			}
		}

		private function completeEventHandler(event:DataEvent):void
		{
			removeEventHandlers();
			_file = null;
			onReturn(event.data);
		}

		private function errorEventHandler(event:Event):void
		{
			removeEventHandlers();
			_file = null;
			onThrow(event);
		}
	}
}