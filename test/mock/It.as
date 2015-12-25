package mock
{
	import mock.matchers.AnyMatcher;
	import mock.matchers.ArgumentsMatcher;
	import mock.matchers.ClassMatcher;
	import mock.matchers.EqualMatcher;
	import mock.matchers.FunctionMatcher;
	import mock.matchers.StrictEqualMatcher;

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

		public static function setup():ISetup
		{
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

		public static function invoke(object:Object, method:Function, ...args):*
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

		public static function verify():IVerify
		{
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
				_currentArguments.arguments.push(new EqualMatcher(matcher));
			}
		}

		public static function equals(value:*):void
		{
			_currentArguments.arguments.push(new EqualMatcher(value));
		}

		public static function strictlyEquals(value:*):void
		{
			_currentArguments.arguments.push(new StrictEqualMatcher(value));
		}

		public static function isOfType(type:Class):void
		{
			_currentArguments.arguments.push(new ClassMatcher(type));
		}

		public static function isNull():void
		{
			_currentArguments.arguments.push(new EqualMatcher(null));
		}

		public static function isFalse():void
		{
			_currentArguments.arguments.push(new EqualMatcher(false));
		}

		public static function isTrue():void
		{
			_currentArguments.arguments.push(new EqualMatcher(true));
		}

		public static function isAny():void
		{
			_currentArguments.arguments.push(new AnyMatcher());
		}
	}
}
