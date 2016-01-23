package com.epolyakov.async.tasks.mocks
{
	import com.epolyakov.async.core.IResult;
	import com.epolyakov.async.core.ITask;
	import com.epolyakov.mock.It;
	import com.epolyakov.mock.Mock;

	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class MockResultDispatcher extends EventDispatcher implements IResult
	{
		public function MockResultDispatcher()
		{
			Mock.setup().that(onReturn(It.isAny(), It.isAny())).returns(function ():void
			{
				dispatchEvent(new Event(Event.COMPLETE));
			});
			Mock.setup().that(onThrow(It.isAny(), It.isAny())).returns(function ():void
			{
				dispatchEvent(new Event(Event.CANCEL));
			});
		}

		public function onReturn(value:Object, target:ITask):void
		{
			Mock.invoke(this, onReturn, value, target);
		}

		public function onThrow(error:Object, target:ITask):void
		{
			Mock.invoke(this, onThrow, error, target);
		}
	}
}
