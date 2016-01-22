package com.epolyakov.async.tasks.mocks
{
	import com.epolyakov.async.core.IResult;
	import com.epolyakov.async.core.ITask;
	import com.epolyakov.mock.Mock;

	import flash.events.Event;

	import flash.events.EventDispatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class MockResultDispatcher extends EventDispatcher implements IResult
	{
		public function onReturn(value:Object, target:ITask):void
		{
			Mock.invoke(this, onReturn, value, target);
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function onThrow(error:Object, target:ITask):void
		{
			Mock.invoke(this, onThrow, error, target);
			dispatchEvent(new Event(Event.CANCEL));
		}
	}
}
