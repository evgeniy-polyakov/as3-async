package com.epolyakov.mock
{
	import com.epolyakov.mock.matchers.AnyMatcher;
	import com.epolyakov.mock.matchers.FunctionMatcher;
	import com.epolyakov.mock.matchers.IsEqualMatcher;
	import com.epolyakov.mock.matchers.IsOfTypeMatcher;
	import com.epolyakov.mock.matchers.IsStrictlyEqualMatcher;
	import com.epolyakov.mock.matchers.NotEqualMatcher;
	import com.epolyakov.mock.matchers.NotOfTypeMatcher;
	import com.epolyakov.mock.matchers.NotStrictlyEqualMatcher;
	import com.epolyakov.mock.matchers.RegExpMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class It
	{
		public static function match(matcher:*):*
		{
			if (matcher is IMatcher)
			{
				Mock.getArgumentsMatcher().add(matcher);
			}
			else if (matcher is Function)
			{
				Mock.getArgumentsMatcher().add(new FunctionMatcher(matcher));
			}
			else if (matcher is RegExp)
			{
				Mock.getArgumentsMatcher().add(new RegExpMatcher(matcher as RegExp));
			}
			else
			{
				throw new SetupError("Expected argument matcher of type IMatcher, Function or RegExp, but got " + matcher);
			}
			return undefined;
		}

		public static function isEqual(value:*, ...values):*
		{
			Mock.getArgumentsMatcher().add(new IsEqualMatcher(value, values));
			return undefined;
		}

		public static function notEqual(value:*, ...values):*
		{
			Mock.getArgumentsMatcher().add(new NotEqualMatcher(value, values));
			return undefined;
		}

		public static function isStrictlyEqual(value:*, ...values):*
		{
			Mock.getArgumentsMatcher().add(new IsStrictlyEqualMatcher(value, values));
			return undefined;
		}

		public static function notStrictlyEqual(value:*, ...values):*
		{
			Mock.getArgumentsMatcher().add(new NotStrictlyEqualMatcher(value, values));
			return undefined;
		}

		public static function isOfType(type:Class, ...types):*
		{
			Mock.getArgumentsMatcher().add(new IsOfTypeMatcher(type, types));
			return undefined;
		}

		public static function notOfType(type:Class, ...types):*
		{
			Mock.getArgumentsMatcher().add(new NotOfTypeMatcher(type, types));
			return undefined;
		}

		public static function isNull():*
		{
			Mock.getArgumentsMatcher().add(new IsEqualMatcher(null));
			return undefined;
		}

		public static function notNull():*
		{
			Mock.getArgumentsMatcher().add(new NotEqualMatcher(null));
			return undefined;
		}

		public static function isFalse():Boolean
		{
			Mock.getArgumentsMatcher().add(new IsEqualMatcher(false));
			return undefined;
		}

		public static function isTrue():Boolean
		{
			Mock.getArgumentsMatcher().add(new IsEqualMatcher(true));
			return undefined;
		}

		public static function isAny():*
		{
			Mock.getArgumentsMatcher().add(new AnyMatcher());
			return undefined;
		}
	}
}
