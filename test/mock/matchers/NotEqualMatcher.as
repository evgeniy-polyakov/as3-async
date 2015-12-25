package mock.matchers
{
	import mock.IMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class NotEqualMatcher extends MultiMatcher implements IMatcher
	{
		public function NotEqualMatcher(value:*, values:Array = null)
		{
			super("It.notEqual", value, values);
		}

		public function match(value:*):Boolean
		{
			for each(var v:* in _values)
			{
				if (v == value)
				{
					return false;
				}
			}
			return true;
		}
	}
}
