package mock.matchers
{
	import mock.IMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class ClassMatcher implements IMatcher
	{
		private var _type:Class;

		public function ClassMatcher(type:Class)
		{
			_type = type;
		}

		public function match(value:*):Boolean
		{
			return value is _type;
		}
	}
}
