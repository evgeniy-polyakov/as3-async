package mock
{
	import mock.matchers.ArgumentsMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class Mock
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

		public static function clear():void
		{
			_expectations = new <Expectation>[];
			_invocations = new <Invocation>[];
			_isInSetupMode = false;
			_isInVerifyMode = false;
			_currentInvocation = null;
			_currentArguments = new ArgumentsMatcher();
		}

		public static function setup():ISetup
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
	}
}
