package mock.matchers
{
	import mock.IMatcher;

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
	}
}