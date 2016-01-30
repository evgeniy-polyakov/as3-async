package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mocks.MockResult;
	import com.epolyakov.mock.Mock;

	import org.flexunit.asserts.assertEquals;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class FuncTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test]
		public function constructor_ShouldSetTasks():void
		{
			var func:Function = function ():void
			{
				Mock.invoke(null, func);
			};
			var task:Func = new Func(func);

			assertEquals(func, task.func);
			Mock.verify().total(0);
		}

		[Test]
		public function await_ShouldCallFunc0Args():void
		{
			var out:Object = {};
			var func:Function = function ():Object
			{
				Mock.invoke(null, func);
				return out;
			};
			var task:Func = new Func(func);
			var result:MockResult = new MockResult();

			task.await({}, result);

			Mock.verify().that(func())
					.verify().that(result.onReturn(out, task))
					.verify().total(2);
		}
	}
}
