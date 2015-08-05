package com.epolyakov.asynctasks.impl
{
	import com.epolyakov.asynctasks.core.Task;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * @author Evgeniy S. Polyakov
	 */
	public class FrameTask extends Task
	{
		private static var _dispatcher:IEventDispatcher;
		private var _current:int;
		private var _delay:int;

		public function FrameTask(delay:int = 0)
		{
			_delay = delay;
		}

		override protected function execute():void
		{
			if (_dispatcher == null)
			{
				_dispatcher = new Sprite();
			}
			_current = _delay;
			if (_current > 0)
			{
				_dispatcher.addEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
			}
			else
			{
				Return(data);
			}
		}

		override protected function interrupt():void
		{
			_dispatcher.removeEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
		}

		private function enterFrameEventHandler(event:Event):void
		{
			_current--;
			if (_current <= 0)
			{
				_dispatcher.removeEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
				Return(data);
			}
		}
	}
}