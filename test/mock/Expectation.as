package mock
{
	import mock.matchers.ArgumentsMatcher;
	import mock.matchers.EqualMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	internal class Expectation implements ISetup, ISetupActions
	{
		private var _object:Object;
		private var _method:Function;
		private var _argumentsMatcher:ArgumentsMatcher;
		private var _returns:* = undefined;
		private var _throws:* = undefined;

		internal function match(invocation:Invocation):Boolean
		{
			return _object == invocation.object &&
					_method == invocation.method &&
					_argumentsMatcher.match(invocation.arguments);
		}

		internal function execute(invocation:Invocation):*
		{
			if (_returns is Function)
			{
				return (_returns as Function).apply(invocation.object, invocation.arguments);
			}
			if (_returns !== undefined)
			{
				return _returns;
			}
			if (_throws is Function)
			{
				throw (_throws as Function).apply(invocation.object, invocation.arguments);
			}
			if (_throws !== undefined)
			{
				throw _throws;
			}
			return undefined;
		}

		public function that(methodCall:*):ISetupActions
		{
			var invocation:Invocation = It.getCurrentInvocation();
			var argumentsMatcher:ArgumentsMatcher = It.getArgumentsMatcher();
			It.setupComplete();

			if (invocation == null)
			{
				throw new MockError("No invocation to setup.");
			}
			if (argumentsMatcher == null)
			{
				argumentsMatcher = new ArgumentsMatcher();
			}
			if (argumentsMatcher.arguments.length > 0)
			{
				if (argumentsMatcher.arguments.length != invocation.arguments.length)
				{
					throw new MockError("Arguments mismatch.");
				}
			}
			else
			{
				for each (var arg:* in invocation.arguments)
				{
					argumentsMatcher.arguments.push(new EqualMatcher(arg));
				}
			}

			_object = invocation.object;
			_method = invocation.method;
			_argumentsMatcher = argumentsMatcher;

			return this;
		}

		public function returns(value:*):void
		{
			_returns = value;
		}

		public function throws(value:*):void
		{
			_throws = value;
		}
	}
}
