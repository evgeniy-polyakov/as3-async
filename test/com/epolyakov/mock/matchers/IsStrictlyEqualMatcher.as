package com.epolyakov.mock.matchers
{
	import com.epolyakov.mock.IMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class IsStrictlyEqualMatcher extends MultiMatcher implements IMatcher
	{
		public function IsStrictlyEqualMatcher(value:*, values:Array = null)
		{
			super("It.isStrictlyEqual", value, values);
		}

		public function match(value:*):Boolean
		{
			for each(var v:* in _values)
			{
				if (v === value)
				{
					return true;
				}
			}
			return false;
		}
	}
}
