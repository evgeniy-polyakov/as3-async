package com.epolyakov.async.core.mocks
{
	import com.epolyakov.async.core.Task;
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
