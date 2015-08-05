package com.epolyakov.asynctasks.impl
{
	import com.epolyakov.asynctasks.core.Task;

	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * @author Evgeniy S. Polyakov
	 */
	public class EventTask extends Task
	{
		private var _dispatcher:IEventDispatcher;
		private var _type:String;
		private var _useCapture:Boolean;
		private var _priority:int;
		private var _useWeakReference:Boolean;

		public function EventTask(dispatcher:IEventDispatcher = null, type:String = null, useCapture:Boolean = false,
								  priority:int = 0, useWeakReference:Boolean = false)
		{
			_dispatcher = dispatcher;
			_type = type;
			_useCapture = useCapture;
			_priority = priority;
			_useWeakReference = useWeakReference;
		}

		override protected function doExecute():void
		{
			if (_dispatcher)
			{
				_dispatcher.addEventListener(_type, eventHandler, _useCapture, _priority, _useWeakReference);
			}
		}

		override protected function doInterrupt():void
		{
			if (_dispatcher)
			{
				_dispatcher.removeEventListener(_type, eventHandler, _useCapture);
			}
		}

		private function eventHandler(event:Event):void
		{
			_dispatcher.removeEventListener(_type, eventHandler, _useCapture);
			Return(event);
		}
	}
}