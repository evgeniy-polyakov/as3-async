package com.epolyakov.async.core.mocks
{
	import com.epolyakov.async.core.IResult;
	import com.epolyakov.async.core.ITask;
	import com.epolyakov.mock.Mock;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class MockResult implements IResult
	{
		public function onReturn(value:Object, target:ITask = null):void
		{
			Mock.invoke(this, onReturn, value, target);
		}

		public function onThrow(error:Object, target:ITask = null):void
		{
			Mock.invoke(this, onThrow, error, target);
		}
	}
}
