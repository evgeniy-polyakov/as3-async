package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Fork implements IAwaitable
	{
		private var _success:IAwaitable;
		private var _failure:IAwaitable;

		public function Fork(success:IAwaitable, failure:IAwaitable)
		{
			_success = success;
			_failure = failure;
		}

		public function get success():IAwaitable
		{
			return _success;
		}

		public function get failure():IAwaitable
		{
			return _failure;
		}

		public function await(data:Object = null, result:IResult = null):ICancelable
		{
			return null;
		}
	}
}