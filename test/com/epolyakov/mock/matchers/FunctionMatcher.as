package com.epolyakov.mock.matchers
{
	import com.epolyakov.mock.IMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class FunctionMatcher implements IMatcher
	{
		private var _func:Function;

		public function FunctionMatcher(func:Function)
		{
			_func = func;
		}

		public function match(value:*):Boolean
		{
			return _func(value);
		}

		public function toString():String
		{
			return "It.matches(" + _func + ")";
		}
	}
}
