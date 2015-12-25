package mock.matchers
{
	import mock.IMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class AnyMatcher implements IMatcher
	{
		public function match(value:*):Boolean
		{
			return true;
		}
	}
}
