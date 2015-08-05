package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class CaseClass extends Case
	{
		private var _type:Class;

		public function CaseClass(type:Class)
		{
			_type = type;
		}

		override public function accept(value:Object):Boolean
		{
			return value is _type;
		}
	}
}