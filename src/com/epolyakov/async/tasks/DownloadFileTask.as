package com.epolyakov.async.tasks
{
	import com.epolyakov.async.core.Task;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;

	/**
	 * @author Evgeniy S. Polyakov
	 *
	 * The DownloadFileTask uses FileReference object to browse and download files.
	 *
	 * @return FileReference object.
	 * @throw Event.CANCEL, IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR, errors thrown by FileReference.download().
	 */
	public class DownloadFileTask extends Task
	{
		private var _file:FileReference;
		private var _source:Object;
		private var _defaultFileName:String;

		/**
		 * @param source - The URLRequest object or string with url of file to download.
		 * @param defaultFileName - The name of the file displayed in the download dialog.
		 */
		public function DownloadFileTask(source:Object, defaultFileName:String)
		{
			_source = source;
			_defaultFileName = defaultFileName;
		}

		override protected function onAwait():void
		{
			_file = new FileReference();

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
				_file.download(request, _defaultFileName);
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
				_file.addEventListener(Event.CANCEL, errorEventHandler);
				_file.addEventListener(Event.COMPLETE, completeEventHandler);
				_file.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
				_file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			}
		}

		private function removeEventHandlers():void
		{
			if (_file)
			{
				_file.removeEventListener(Event.CANCEL, errorEventHandler);
				_file.removeEventListener(Event.COMPLETE, completeEventHandler);
				_file.removeEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
				_file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			}
		}

		private function completeEventHandler(event:Event):void
		{
			removeEventHandlers();
			var file:FileReference = _file;
			_file = null;
			onReturn(file);
		}

		private function errorEventHandler(event:Event):void
		{
			removeEventHandlers();
			_file = null;
			onThrow(event);
		}
	}
}