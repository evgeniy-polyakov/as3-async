package com.epolyakov.asynctasks.impl
{
	import com.epolyakov.asynctasks.core.Task;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;

	/**
	 * @author Evgeniy S. Polyakov
	 *
	 * The LoadFileTask uses FileReference object to load files.
	 *
	 * @param FileReference object.
	 * @return FileReference object.
	 * @throw TaskDataError, IOErrorEvent.IO_ERROR, errors thrown by FileReference.load().
	 */
	public class LoadFileTask extends Task
	{
		private var _file:FileReference;

		override protected function execute():void
		{
			_file = data as FileReference;
			if (!_file)
			{
				Throw(new ArgumentError("LoadFileTask expects a FileReference object, got " + data + "."));
				return;
			}
			addEventHandlers();
			try
			{
				_file.load();
			}
			catch (error:Error)
			{
				removeEventHandlers();
				Throw(error);
			}
		}

		override protected function interrupt():void
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
				_file.addEventListener(Event.COMPLETE, completeEventHandler);
				_file.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			}
		}

		private function removeEventHandlers():void
		{
			if (_file)
			{
				_file.removeEventListener(Event.COMPLETE, completeEventHandler);
				_file.removeEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			}
		}

		private function completeEventHandler(event:Event):void
		{
			removeEventHandlers();
			var file:FileReference = _file;
			_file = null;
			Return(file);
		}

		private function errorEventHandler(event:Event):void
		{
			removeEventHandlers();
			_file = null;
			Throw(event);
		}
	}
}