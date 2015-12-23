package com.epolyakov.async.tasks
{
	import com.epolyakov.async.core.Task;

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

		override protected function onAwait():void
		{
			if (_dispatcher)
			{
				_dispatcher.addEventListener(_type, eventHandler, _useCapture, _priority, _useWeakReference);
			}
		}

		override protected function onCancel():void
		{
			if (_dispatcher)
			{
				_dispatcher.removeEventListener(_type, eventHandler, _useCapture);
			}
		}

		private function eventHandler(event:Event):void
		{
			_dispatcher.removeEventListener(_type, eventHandler, _useCapture);
			onReturn(event);
		}
	}
}