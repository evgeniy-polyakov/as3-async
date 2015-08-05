package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class CaseFunc extends Case
	{
		private var _func:Function;

		public function CaseFunc(func:Function)
		{
			_func = func;
		}

		override public function accept(value:Object):Boolean
		{
			return _func != null && _func(value);
		}
	}
}