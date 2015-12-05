package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Args implements ITask
	{
		private var _value:Object;

		public function Args(value:Object)
		{
			_value = value;
		}

		public function get value():Object
		{
			return _value;
		}

		public function await(data:Object = null, result:IResult = null):void
		{
			if (result)
			{
				result.onReturn(_value, this);
			}
		}

		public function cancel():void
		{
		}
	}
}