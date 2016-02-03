package com.epolyakov.mock
{
	import com.epolyakov.mock.matchers.ArgumentsMatcher;

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
				if ((_returns as Function).length == 0)
				{
					return (_returns as Function).call(invocation.object);
				}
				if ((_returns as Function).length != invocation.arguments.length)
				{
					throw new SetupError("Arguments mismatch: " +
							"expected " + invocation.toString() +
							"but got " + (_returns as Function).length);
				}
				return (_returns as Function).apply(invocation.object, invocation.arguments);
			}
			if (_returns !== undefined)
			{
				return _returns;
			}
			if (_throws is Function)
			{
				if ((_throws as Function).length == 0)
				{
					throw (_throws as Function).call(invocation.object);
				}
				if ((_throws as Function).length != invocation.arguments.length)
				{
					throw new SetupError("Arguments mismatch: " +
							"expected (" + invocation.toString() + ")" +
							"but got " + (_throws as Function).length + ".");
				}
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
			var invocation:Invocation = Mock.getCurrentInvocation();
			var argumentsMatcher:ArgumentsMatcher = Mock.getArgumentsMatcher();
			Mock.setupComplete();

			if (invocation == null)
			{
				throw new SetupError("No invocation to setup.");
			}
			if (argumentsMatcher == null)
			{
				argumentsMatcher = new ArgumentsMatcher();
			}
			argumentsMatcher.complete(invocation.arguments);

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
