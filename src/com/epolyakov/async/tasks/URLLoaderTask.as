package com.epolyakov.async.tasks
{
	import com.epolyakov.async.core.Task;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * @author Evgeniy S. Polyakov
	 *
	 * The URLLoader uses URLLoader object to download data from any URL.
	 *
	 * @return URLLoader object.
	 * @throws IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR, errors thrown by URLLoader.load().
	 */
	public class URLLoaderTask extends Task
	{
		private var _loader:URLLoader;
		private var _source:Object;
		private var _format:String;

		/**
		 * @param source - The loading source: URLRequest or String.
		 * @param format - The format of loading data.
		 */
		public function URLLoaderTask(source:Object = null, format:String = "text")
		{
			_source = source;
			_format = format;
		}

		override protected function onAwait():void
		{
			_loader = new URLLoader();
			_loader.dataFormat = _format;
			addEventHandlers();

			var request:URLRequest;
			if (_source is URLRequest)
			{
				request = _source as URLRequest;
			}
			else
			{
				request = new URLRequest(String(_source));
			}

			try
			{
				_loader.load(request);
			}
			catch (error:Error)
			{
				removeEventHandlers();
				_loader = null;
				onThrow(error);
			}
		}

		override protected function onCancel():void
		{
			removeEventHandlers();
			try
			{
				_loader.close();
			}
			catch (error:Error)
			{
			}
			_loader = null;
		}

		private function addEventHandlers():void
		{
			if (_loader)
			{
				_loader.addEventListener(Event.COMPLETE, completeEventHandler);
				_loader.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
				_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			}
		}

		private function removeEventHandlers():void
		{
			if (_loader)
			{
				_loader.removeEventListener(Event.COMPLETE, completeEventHandler);
				_loader.removeEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
				_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			}
		}

		private function completeEventHandler(event:Event):void
		{
			removeEventHandlers();
			var loader:URLLoader = _loader;
			_loader = null;
			onReturn(loader);
		}

		private function errorEventHandler(event:Event):void
		{
			removeEventHandlers();
			_loader = null;
			onThrow(event);
		}
	}
}