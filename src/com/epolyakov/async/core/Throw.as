package com.epolyakov.async.core
{
	/**
	 * @author epolyakov
	 */
	internal class Throw implements ITask
	{
		private var _value:Object;

		public function Throw(value:Object)
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
				result.onThrow(_value, this);
			}
		}

		public function cancel():void
		{
		}
	}
}