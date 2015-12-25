package mock
{
	import mock.matchers.AnyMatcher;
	import mock.matchers.ArgumentsMatcher;
	import mock.matchers.FunctionMatcher;
	import mock.matchers.IsEqualMatcher;
	import mock.matchers.IsOfTypeMatcher;
	import mock.matchers.IsStrictlyEqualMatcher;
	import mock.matchers.NotEqualMatcher;
	import mock.matchers.NotOfTypeMatcher;
	import mock.matchers.NotStrictlyEqualMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class It
	{
		public static function matches(matcher:*):void
		{
			if (matcher is IMatcher)
			{
				Mock.getArgumentsMatcher().arguments.push(matcher);
			}
			else if (matcher is Function)
			{
				Mock.getArgumentsMatcher().arguments.push(new FunctionMatcher(matcher));
			}
			else if (matcher is Class)
			{
				Mock.getArgumentsMatcher().arguments.push(new FunctionMatcher(matcher));
			}
			else
			{
				Mock.getArgumentsMatcher().arguments.push(new IsEqualMatcher(matcher));
			}
		}

		public static function isEqual(value:*, ...values):*
		{
			Mock.getArgumentsMatcher().arguments.push(new IsEqualMatcher(value, values));
			return undefined;
		}

		public static function notEqual(value:*, ...values):*
		{
			Mock.getArgumentsMatcher().arguments.push(new NotEqualMatcher(value, values));
			return undefined;
		}

		public static function isStrictlyEqual(value:*, ...values):*
		{
			Mock.getArgumentsMatcher().arguments.push(new IsStrictlyEqualMatcher(value, values));
			return undefined;
		}

		public static function notStrictlyEqual(value:*, ...values):*
		{
			Mock.getArgumentsMatcher().arguments.push(new NotStrictlyEqualMatcher(value, values));
			return undefined;
		}

		public static function isOfType(type:Class, ...types):*
		{
			Mock.getArgumentsMatcher().arguments.push(new IsOfTypeMatcher(type, types));
			return undefined;
		}

		public static function notOfType(type:Class, ...types):*
		{
			Mock.getArgumentsMatcher().arguments.push(new NotOfTypeMatcher(type, types));
			return undefined;
		}

		public static function isNull():*
		{
			Mock.getArgumentsMatcher().arguments.push(new IsEqualMatcher(null));
			return undefined;
		}

		public static function notNull():*
		{
			Mock.getArgumentsMatcher().arguments.push(new NotEqualMatcher(null));
			return undefined;
		}

		public static function isFalse():*
		{
			Mock.getArgumentsMatcher().arguments.push(new IsEqualMatcher(false));
			return undefined;
		}

		public static function isTrue():*
		{
			Mock.getArgumentsMatcher().arguments.push(new IsEqualMatcher(true));
			return undefined;
		}

		public static function isAny():*
		{
			Mock.getArgumentsMatcher().arguments.push(new AnyMatcher());
			return undefined;
		}
	}
}
