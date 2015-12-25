package mock
{
	import mock.matchers.ArgumentsMatcher;
	import mock.matchers.EqualMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	internal class Verification implements IVerify, IVerifyActions
	{
		private var _startInvocationIndex:int;
		private var _lastMatchedInvocationIndex:int;

		public function Verification(index:int = 0)
		{
			_startInvocationIndex = _lastMatchedInvocationIndex = index;
		}

		public function that(methodCall:*, times:Times = null):IVerifyActions
		{
			var invocation:Invocation = It.getCurrentInvocation();
			var argumentsMatcher:ArgumentsMatcher = It.getArgumentsMatcher();
			It.verifyComplete();

			if (invocation == null)
			{
				throw new MockError("No invocation to verify.");
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

			var invocationsMatched:int = 0;
			var invocations:Vector.<Invocation> = It.getInvocations();
			for (var i:int = _startInvocationIndex, n:int = invocations.length; i < n; i++)
			{
				if (invocation.object == invocations[i].object &&
						invocation.method == invocations[i].method &&
						argumentsMatcher.match(invocations[i].arguments))
				{
					invocationsMatched++;
					_lastMatchedInvocationIndex = i;
				}
			}
			if (times == null)
			{
				times = Times.once;
			}
			if (!times.match(invocationsMatched))
			{
				throw new MockError("Expected " + invocation.toString(argumentsMatcher) +
						" invoked " + times.toString() + " but got " + Times.exactly(invocationsMatched).toString() +
						(_startInvocationIndex > 0 ? " starting from " + _startInvocationIndex : "") + "." +
						"\nPerformed invocations:\n" + invocations.join(",\n") + ".");
			}
			return this;
		}

		public function verify():IVerify
		{
			var verification:Verification = It.verify() as Verification;
			verification._startInvocationIndex = _lastMatchedInvocationIndex + 1;
			return verification;
		}
	}
}