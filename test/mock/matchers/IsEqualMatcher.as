package mock.matchers
{
	import mock.IMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class IsEqualMatcher extends MultiMatcher implements IMatcher
	{
		public function IsEqualMatcher(value:*, values:Array = null)
		{
			super("It.isEqual", value, values);
		}

		public function match(value:*):Boolean
		{
			for each(var v:* in _values)
			{
				if (v == value)
				{
					return true;
				}
			}
			return false;
		}

		override public function toString():String
		{
			if (_values.length == 1)
			{
				if (_values[0] === null)
				{
					return "It.isNull()";
				}
				if (_values[0] === true)
				{
					return "It.isTrue()";
				}
				if (_values[0] === false)
				{
					return "It.isFalse()";
				}
			}
			return super.toString();
		}
	}
}
