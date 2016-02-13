package com.epolyakov.async.core
{
	/**
	 * @author epolyakov
	 */
	internal class Return implements ITask, IReliable
	{
		private var _value:Object;

		public function Return(value:Object)
		{
			_value = value;
		}

		internal function get value():Object
		{
			return _value;
		}

		public function await(args:Object = null, result:IResult = null):void
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