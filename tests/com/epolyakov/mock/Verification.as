package com.epolyakov.mock
{
	import com.epolyakov.mock.matchers.ArgumentsMatcher;
	import com.epolyakov.mock.matchers.IsEqualMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	internal class Verification implements IVerify, IVerifyActions
	{
		private var _startInvocationIndex:int;
		private var _lastMatchedInvocationIndex:int;

		public function Verification(index:int = 0)
		{
			_startInvocationIndex = index;
			_lastMatchedInvocationIndex = index - 1;
		}

		public function that(mock:*, times:* = 1):IVerifyActions
		{
			var invocation:Invocation = Mock.getCurrentInvocation();
			var argumentsMatcher:ArgumentsMatcher = Mock.getArgumentsMatcher();
			Mock.verifyComplete();

			if (invocation == null)
			{
				if (mock != null && !(mock is Function) && !(mock is Array) && !(mock is String) && !(mock is Number) && !(mock is Boolean))
				{
					invocation = new Invocation(mock, null, []);
				}
				else
				{
					throw new SetupError("No invocation or mock object to verify.");
				}
			}
			if (argumentsMatcher == null)
			{
				argumentsMatcher = new ArgumentsMatcher();
			}
			if (argumentsMatcher.arguments.length > 0)
			{
				if (argumentsMatcher.arguments.length != invocation.arguments.length)
				{
					throw new SetupError("Arguments mismatch: " +
							"expected (" + argumentsMatcher + ")" +
							"but got (" + invocation.arguments + ").");
				}
			}
			else
			{
				for each (var arg:* in invocation.arguments)
				{
					argumentsMatcher.arguments.push(new IsEqualMatcher(arg));
				}
			}

			var invocationsMatched:int = 0;
			var invocations:Vector.<Invocation> = Mock.getInvocations();
			for (var i:int = _startInvocationIndex, n:int = invocations.length; i < n; i++)
			{
				if (invocation.object == invocations[i].object &&
						(invocation.method == null || invocation.method == invocations[i].method) &&
						(invocation.method == null || argumentsMatcher.match(invocations[i].arguments)))
				{
					invocationsMatched++;
					_lastMatchedInvocationIndex = i;
				}
			}
			var timesObj:Times = times is Times ? times : Times.exactly(times);
			if (!timesObj.match(invocationsMatched))
			{
				throw new VerificationError("Expected " + invocation.toString(argumentsMatcher) +
						" invoked " + timesObj + " but got " + Times.exactly(invocationsMatched) +
						(_startInvocationIndex > 0 ? " starting from index " + _startInvocationIndex : "") + "." +
						"\nPerformed invocations: " + (invocations.length > 0 ? "\n" + invocations.join(",\n") : "none") + ".");
			}
			return this;
		}

		public function total(times:*):void
		{
			Mock.verifyComplete();

			var timesObj:Times = times is Times ? times : Times.exactly(times);
			var invocations:Vector.<Invocation> = Mock.getInvocations();
			if (!timesObj.match(invocations.length))
			{
				throw new VerificationError("Expected mocked methods invoked " + timesObj + " but got " + Times.exactly(invocations.length) + "." +
						"\nPerformed invocations: " + (invocations.length > 0 ? "\n" + invocations.join(",\n") : "none") + ".");
			}
		}

		public function verify():IVerify
		{
			var verification:Verification = Mock.verify() as Verification;
			verification._startInvocationIndex = _lastMatchedInvocationIndex + 1;
			return verification;
		}
	}
}
