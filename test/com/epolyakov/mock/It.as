package com.epolyakov.mock
{
	import com.epolyakov.mock.matchers.AnyMatcher;
	import com.epolyakov.mock.matchers.ArgumentsMatcher;
	import com.epolyakov.mock.matchers.FunctionMatcher;
	import com.epolyakov.mock.matchers.IsEqualMatcher;
	import com.epolyakov.mock.matchers.IsOfTypeMatcher;
	import com.epolyakov.mock.matchers.IsStrictlyEqualMatcher;
	import com.epolyakov.mock.matchers.NotEqualMatcher;
	import com.epolyakov.mock.matchers.NotOfTypeMatcher;
	import com.epolyakov.mock.matchers.NotStrictlyEqualMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class It
	{
		public static function matches(matcher:*):*
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
				Mock.getArgumentsMatcher().arguments.push(new IsOfTypeMatcher(matcher as Class, []));
			}
			else
			{
				Mock.getArgumentsMatcher().arguments.push(new IsEqualMatcher(matcher));
			}
			return undefined;
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

		public static function isFalse():Boolean
		{
			Mock.getArgumentsMatcher().arguments.push(new IsEqualMatcher(false));
			return undefined;
		}

		public static function isTrue():Boolean
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
