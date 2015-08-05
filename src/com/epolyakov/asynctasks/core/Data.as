package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Data implements IAsync
	{
		private var _value:Object;

		public function Data(value:Object)
		{
			_value = value;
		}

		public function get value():Object
		{
			return _value;
		}

		public function Await(data:Object = null, result:IResult = null):void
		{
			if (result)
			{
				result.Return(_value, this);
			}
		}

		public function Break():void
		{
		}
	}
}