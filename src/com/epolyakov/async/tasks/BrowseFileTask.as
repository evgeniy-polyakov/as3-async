package com.epolyakov.async.tasks
{
	import com.epolyakov.async.Task;

	import flash.events.Event;
	import flash.net.FileReference;

	/**
	 * @author Evgeniy S. Polyakov
	 *
	 * The BrowseFileTask uses FileReference object to browse files.
	 *
	 * @return FileReference object.
	 * @throw Event.CANCEL, errors thrown by FileReference.browse().
	 */
	public class BrowseFileTask extends Task
	{
		internal var mockFileReference:FileReference;
		private var _file:FileReference;
		private var _filters:Array;

		/**
		 * @param filters - The Array of FileFilter objects
		 */
		public function BrowseFileTask(filters:Array = null)
		{
			_filters = filters;
		}

		override protected function onAwait():void
		{
			_file = mockFileReference || new FileReference();
			addEventHandlers();

			try
			{
				_file.browse(_filters);
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
				_file.addEventListener(Event.SELECT, selectEventHandler);
				_file.addEventListener(Event.CANCEL, cancelEventHandler);
			}
		}

		private function removeEventHandlers():void
		{
			if (_file)
			{
				_file.removeEventListener(Event.SELECT, selectEventHandler);
				_file.removeEventListener(Event.CANCEL, cancelEventHandler);
			}
		}

		private function selectEventHandler(event:Event):void
		{
			removeEventHandlers();
			var file:FileReference = _file;
			_file = null;
			onReturn(file);
		}

		private function cancelEventHandler(event:Event):void
		{
			removeEventHandlers();
			_file = null;
			onThrow(event);
		}
	}
}