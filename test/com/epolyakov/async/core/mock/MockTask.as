package com.epolyakov.async.core.mock
{
	import com.epolyakov.async.core.IResult;
	import com.epolyakov.async.core.ITask;

	import mock.It;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class MockTask implements ITask
	{
		public function await(args:Object = null, result:IResult = null):void
		{
			It.invoke(this, await, args, result);
		}

		public function cancel():void
		{
			It.invoke(this, cancel);
		}
	}
}
