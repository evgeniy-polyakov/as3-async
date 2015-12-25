package com.epolyakov.async.core
{
	/**
	 * @author epolyakov
	 */
	internal class Fork implements ITask
	{
		private var _success:ITask;
		private var _failure:ITask;

		public function Fork(success:ITask, failure:ITask)
		{
			_success = success;
			_failure = failure;
		}

		internal function get success():ITask
		{
			return _success;
		}

		internal function get failure():ITask
		{
			return _failure;
		}

		public function await(args:Object = null, result:IResult = null):void
		{
		}

		public function cancel():void
		{
		}
	}
}