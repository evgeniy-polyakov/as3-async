package mock.matchers
{
	import mock.IMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class NotStrictlyEqualMatcher extends MultiMatcher implements IMatcher
	{
		public function NotStrictlyEqualMatcher(value:*, values:Array = null)
		{
			super("It.notStrictlyEqual", value, values);
		}

		public function match(value:*):Boolean
		{
			for each(var v:* in _values)
			{
				if (v === value)
				{
					return false;
				}
			}
			return true;
		}
	}
}
