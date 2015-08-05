package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class CaseEqual extends Case
	{
		private var _value:Object;

		public function CaseEqual(value:Object)
		{
			_value = value;
		}

		override public function accept(value:Object):Boolean
		{
			return value === _value;
		}
	}
}