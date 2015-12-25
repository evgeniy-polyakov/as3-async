package mock.matchers
{
	import mock.IMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class NotOfTypeMatcher extends MultiMatcher implements IMatcher
	{
		public function NotOfTypeMatcher(value:Class, values:Array = null)
		{
			super("It.notOfType", value, values);
		}

		public function match(value:*):Boolean
		{
			for each (var type:Class in _values)
			{
				if (value is type)
				{
					return false;
				}
			}
			return true;
		}
	}
}
