package mock.matchers
{
	import mock.IMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class EqualMatcher implements IMatcher
	{
		private var _value:*;

		public function EqualMatcher(value:*)
		{
			_value = value;
		}

		public function match(value:*):Boolean
		{
			return _value == value;
		}
	}
}
