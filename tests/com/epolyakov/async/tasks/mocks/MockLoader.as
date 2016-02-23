package com.epolyakov.async.tasks.mocks
{
	import com.epolyakov.mock.Mock;

	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class MockLoader extends Loader
	{
		override public function load(request:URLRequest, context:LoaderContext = null):void
		{
			Mock.invoke(this, load, request, context);
		}

		override public function loadBytes(bytes:ByteArray, context:LoaderContext = null):void
		{
			Mock.invoke(this, loadBytes, bytes, context);
		}

		override public function close():void
		{
			Mock.invoke(this, close);
		}
	}
}
