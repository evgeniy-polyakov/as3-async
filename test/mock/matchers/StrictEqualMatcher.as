package mock.matchers
{
	import mock.IMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class StrictEqualMatcher implements IMatcher
	{
		private var _value:*;

		public function StrictEqualMatcher(value:*)
		{
			_value = value;
		}

		public function match(value:*):Boolean
		{
			return _value === value;
		}
	}
}
