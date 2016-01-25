package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mocks.MockResult;
	import com.epolyakov.mock.Mock;

	import org.flexunit.asserts.assertEquals;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class ReturnTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test]
		public function constructor_ShouldSetValue():void
		{
			var value:Object = {};
			assertEquals(value, new Return(value).value);
		}

		[Test]
		public function await_ShouldCallResultOnReturn():void
		{
			var value:Object = {};
			var task:Return = new Return(value);
			var result:MockResult = new MockResult();

			task.await(null, result);
			Mock.verify().that(result.onReturn(value, task))
					.verify().total(1);
		}

		[Test]
		public function await_ShouldNotThrowIfNullResult():void
		{
			new Return({}).await();
		}

		[Test]
		public function cancel_ShouldNotThrow():void
		{
			var task:Return = new Return({});
			task.cancel();
			task.await();
			task.cancel();
		}
	}
}
