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
		private static var _expectations:Vector.<Expectation> = new <Expectation>[];
		private static var _invocations:Vector.<Invocation> = new <Invocation>[];

		private static var _isInSetupMode:Boolean;
		private static var _isInVerifyMode:Boolean;

		private static var _currentInvocation:Invocation;
		private static var _currentArguments:ArgumentsMatcher = new ArgumentsMatcher();

		internal static function getInvocations():Vector.<Invocation>
		{
			return _invocations;
		}

		internal static function getCurrentInvocation():Invocation
		{
			return _currentInvocation;
		}

		internal static function getArgumentsMatcher():ArgumentsMatcher
		{
			return _currentArguments;
		}

		internal static function setup():ISetup
		{
			if (_isInVerifyMode)
			{
				throw new MockError("Can not setup in verification mode.");
			}
			_isInSetupMode = true;
			var expectation:Expectation = new Expectation();
			_expectations.unshift(expectation);
			return expectation;
		}

		internal static function setupComplete():void
		{
			_isInSetupMode = false;
			_currentArguments = new ArgumentsMatcher();
			_currentInvocation = null;
		}

		internal static function invoke(object:Object, method:Function, args:Array):*
		{
			var invocation:Invocation = new Invocation(object, method, args);

			if (_isInSetupMode || _isInVerifyMode)
			{
				_currentInvocation = invocation;
				return undefined;
			}

			_invocations.push(invocation);
			for each (var expectation:Expectation in _expectations)
			{
				if (expectation.match(invocation))
				{
					return expectation.execute(invocation);
				}
			}
			return undefined;
		}

		internal static function verify():IVerify
		{
			if (_isInSetupMode)
			{
				throw new MockError("Can not verify in setup mode.");
			}
			_isInVerifyMode = true;
			return new Verification();
		}

		internal static function verifyComplete():void
		{
			_isInVerifyMode = false;
			_currentArguments = new ArgumentsMatcher();
			_currentInvocation = null;
		}

		public static function matches(matcher:*):void
		{
			if (matcher is IMatcher)
			{
				_currentArguments.arguments.push(matcher);
			}
			else if (matcher is Function)
			{
				_currentArguments.arguments.push(new FunctionMatcher(matcher));
			}
			else if (matcher is Class)
			{
				_currentArguments.arguments.push(new FunctionMatcher(matcher));
			}
			else
			{
				_currentArguments.arguments.push(new IsEqualMatcher(matcher));
			}
		}

		public static function isEqual(value:*, ...values):*
		{
			_currentArguments.arguments.push(new IsEqualMatcher(value, values));
			return undefined;
		}

		public static function notEqual(value:*, ...values):*
		{
			_currentArguments.arguments.push(new NotEqualMatcher(value, values));
			return undefined;
		}

		public static function isStrictlyEqual(value:*, ...values):*
		{
			_currentArguments.arguments.push(new IsStrictlyEqualMatcher(value, values));
			return undefined;
		}

		public static function notStrictlyEqual(value:*, ...values):*
		{
			_currentArguments.arguments.push(new NotStrictlyEqualMatcher(value, values));
			return undefined;
		}

		public static function isOfType(type:Class, ...types):*
		{
			_currentArguments.arguments.push(new IsOfTypeMatcher(type, types));
			return undefined;
		}

		public static function notOfType(type:Class, ...types):*
		{
			_currentArguments.arguments.push(new NotOfTypeMatcher(type, types));
			return undefined;
		}

		public static function isNull():*
		{
			_currentArguments.arguments.push(new IsEqualMatcher(null));
			return undefined;
		}

		public static function notNull():*
		{
			_currentArguments.arguments.push(new NotEqualMatcher(null));
			return undefined;
		}

		public static function isFalse():*
		{
			_currentArguments.arguments.push(new IsEqualMatcher(false));
			return undefined;
		}

		public static function isTrue():*
		{
			_currentArguments.arguments.push(new IsEqualMatcher(true));
			return undefined;
		}

		public static function isAny():*
		{
			_currentArguments.arguments.push(new AnyMatcher());
			return undefined;
		}
	}
}
