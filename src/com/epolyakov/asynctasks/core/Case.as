package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Case
	{
		private var _task:IAsync;

		public function get task():IAsync
		{
			return _task;
		}

		public function set task(value:IAsync):void
		{
			_task = value;
		}

		public function accept(value:Object):Boolean
		{
			return false;
		}
	}
}