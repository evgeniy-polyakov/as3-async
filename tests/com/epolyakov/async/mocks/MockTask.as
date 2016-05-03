package com.epolyakov.async.mocks
{
	import com.epolyakov.async.IResult;
	import com.epolyakov.async.ITask;
	import com.epolyakov.mock.Mock;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class MockTask implements ITask
	{
		public function await(args:Object = null, result:IResult = null):void
		{
			Mock.invoke(this, await, args, result);
		}

		public function cancel():void
		{
			Mock.invoke(this, cancel);
		}
	}
}
