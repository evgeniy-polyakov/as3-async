package com.epolyakov.async.tasks
{
	import com.epolyakov.async.Task;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * @author Evgeniy S. Polyakov
	 */
	public class FramesTask extends Task
	{
		private static var _dispatcher:IEventDispatcher;
		private var _current:int;
		private var _frames:int;

		public function FramesTask(frames:int = 0)
		{
			_frames = frames;
		}

		override protected function onAwait():void
		{
			if (_dispatcher == null)
			{
				_dispatcher = new Sprite();
			}
			_current = _frames;
			if (_current > 0)
			{
				_dispatcher.addEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
			}
			else
			{
				onReturn(args);
			}
		}

		override protected function onCancel():void
		{
			if (_dispatcher != null)
			{
				_dispatcher.removeEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
			}
		}

		private function enterFrameEventHandler(event:Event):void
		{
			_current--;
			if (_current <= 0)
			{
				_dispatcher.removeEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
				onReturn(args);
			}
		}
	}
}