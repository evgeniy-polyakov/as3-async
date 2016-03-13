package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mocks.MockTask;

	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class IReliableTests
	{
		[Test]
		public function IReliable_Implementations():void
		{
			assertTrue(new Conjunction(new MockTask()) is IReliable);
			assertTrue(new Disjunction(new MockTask()) is IReliable);
			assertTrue(new Fork(new MockTask(), new MockTask()) is IReliable);
			assertTrue(new Func(function ():void {}) is IReliable);
			assertFalse(new Result() is IReliable);
			assertTrue(new Return({}) is IReliable);
			assertTrue(new Sequence(new MockTask()) is IReliable);
			assertFalse(new Task() is IReliable);
			assertTrue(new Throw({}) is IReliable);
		}
	}
}
