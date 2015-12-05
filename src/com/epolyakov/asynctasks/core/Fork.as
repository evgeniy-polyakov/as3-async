package com.epolyakov.asynctasks.core
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

		public function get success():ITask
		{
			return _success;
		}

		public function get failure():ITask
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