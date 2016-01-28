package com.epolyakov.mock.matchers
{
	import com.epolyakov.mock.IMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class RegExpMatcher implements IMatcher
	{
		private var _regexp:RegExp;

		public function RegExpMatcher(regexp:RegExp)
		{
			_regexp = regexp;
		}

		public function match(value:*):Boolean
		{
			return _regexp.test(value == null ? "" : value.toString());
		}

		public function toString():String
		{
			return "It.matches(" + _regexp + ")";
		}
	}
}
