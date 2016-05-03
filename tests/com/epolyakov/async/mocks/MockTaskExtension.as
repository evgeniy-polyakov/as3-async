package com.epolyakov.async.mocks
{
	import com.epolyakov.async.Task;
	import com.epolyakov.mock.Mock;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class MockTaskExtension extends Task
	{
		public function public_onAwait():void
		{
			Mock.invoke(this, public_onAwait);
		}

		public function public_onCancel():void
		{
			Mock.invoke(this, public_onCancel);
		}

		override protected function onAwait():void
		{
			public_onAwait();
		}

		override protected function onCancel():void
		{
			public_onCancel();
		}
	}
}
