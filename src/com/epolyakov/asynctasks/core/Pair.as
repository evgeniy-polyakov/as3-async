package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Pair implements IAsync
	{
		private var _success:IAsync;
		private var _failure:IAsync;

		public function Pair(success:IAsync, failure:IAsync)
		{
			_success = success;
			_failure = failure;
		}

		public function get success():IAsync
		{
			return _success;
		}

		public function get failure():IAsync
		{
			return _failure;
		}

		public function execute(data:Object = null, result:IResult = null):void
		{
		}

		public function interrupt():void
		{
		}
	}
}