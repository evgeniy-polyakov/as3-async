package com.epolyakov.async
{
	import com.epolyakov.async.mocks.MockResult;
	import com.epolyakov.mock.Mock;

	import org.flexunit.asserts.assertEquals;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class ThrowTests
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
			assertEquals(value, new Throw(value).value);
		}

		[Test]
		public function await_ShouldCallResultOnThrow():void
		{
			var value:Object = {};
			var task:Throw = new Throw(value);
			var result:MockResult = new MockResult();

			task.await(null, result);
			Mock.verify().that(result.onThrow(value, task))
					.verify().total(1);
		}

		[Test]
		public function await_ShouldNotThrowIfNullResult():void
		{
			new Throw({}).await();
		}

		[Test]
		public function cancel_ShouldNotThrow():void
		{
			var task:Throw = new Throw({});
			task.cancel();
			task.await();
			task.cancel();
		}
	}
}
