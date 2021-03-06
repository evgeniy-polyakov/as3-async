package com.epolyakov.async.tasks
{
	import com.epolyakov.async.Task;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	/**
	 * @author Evgeniy S. Polyakov
	 *
	 * The LoaderTask uses Loader object to download graphic content.
	 *
	 * @return Loader object.
	 * @throws IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR, errors thrown by Loader.load(), Loader.loadBytes().
	 */
	public class LoaderTask extends Task
	{
		internal var mockLoader:Loader;
		private var _loader:Loader;
		private var _source:Object;
		private var _context:LoaderContext;

		/**
		 * @param source - The loading source: ByteArray class, ByteArray, URLRequest, String.
		 * @param context - The loader context.
		 */
		public function LoaderTask(source:Object, context:LoaderContext = null)
		{
			_source = source;
			_context = context;
		}

		override protected function onAwait():void
		{
			_loader = mockLoader || new Loader();
			addEventHandlers();

			try
			{
				var bytes:ByteArray;
				var request:URLRequest;
				if (_source is Class)
				{
					bytes = new (_source as Class)();
				}
				else if (_source is ByteArray)
				{
					bytes = _source as ByteArray;
				}
				else if (_source is URLRequest)
				{
					request = _source as URLRequest;
				}
				else
				{
					request = new URLRequest(String(_source));
				}
				if (bytes)
				{
					_loader.loadBytes(bytes, _context);
				}
				else
				{
					_loader.load(request, _context);
				}
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
				var loaderInfo:LoaderInfo = _loader.contentLoaderInfo;
				loaderInfo.addEventListener(Event.COMPLETE, completeEventHandler);
				loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
				loaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			}
		}

		private function removeEventHandlers():void
		{
			if (_loader)
			{
				var loaderInfo:LoaderInfo = _loader.contentLoaderInfo;
				loaderInfo.removeEventListener(Event.COMPLETE, completeEventHandler);
				loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
				loaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			}
		}

		private function completeEventHandler(event:Event):void
		{
			removeEventHandlers();
			var loader:Loader = _loader;
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