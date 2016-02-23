package com.epolyakov.async.tasks.mocks
{
	import com.epolyakov.mock.Mock;

	import flash.net.FileReference;
	import flash.net.URLRequest;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class MockFileReference extends FileReference
	{
		override public function browse(typeFilter:Array = null):Boolean
		{
			return Mock.invoke(this, browse, typeFilter);
		}

		override public function cancel():void
		{
			Mock.invoke(this, cancel);
		}

		override public function download(request:URLRequest, defaultFileName:String = null):void
		{
			Mock.invoke(this, download, request, defaultFileName);
		}

		override public function upload(request:URLRequest, uploadDataFieldName:String = "Filedata", testUpload:Boolean = false):void
		{
			Mock.invoke(this, upload, request, uploadDataFieldName, testUpload);
		}

		[Version("10")]
		override public function load():void
		{
			Mock.invoke(this, load);
		}
	}
}
