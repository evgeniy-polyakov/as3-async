package com.epolyakov.async.core.mock
{
	import com.epolyakov.async.core.IResult;
	import com.epolyakov.async.core.ITask;

	import mock.It;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class MockResult implements IResult
	{
		public function onReturn(value:Object, target:ITask):void
		{
			It.invoke(this, onReturn, value, target);
		}

		public function onThrow(error:Object, target:ITask):void
		{
			It.invoke(this, onThrow, error, target);
		}
	}
}
