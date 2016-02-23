package com.epolyakov.async.tasks.mocks
{
	import com.epolyakov.mock.Mock;

	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class MockURLLoader extends URLLoader
	{
		override public function load(request:URLRequest):void
		{
			Mock.invoke(this, load, request);
		}

		override public function close():void
		{
			Mock.invoke(this, close);
		}
	}
}
