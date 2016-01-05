package com.epolyakov.async.tasks
{
	import com.epolyakov.async.core.mock.MockResult;

	import flash.events.Event;
	import flash.events.EventDispatcher;

	import mock.Mock;

	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class TimerTaskTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test(async, timeout=500)]
		public function await_ShouldWaitWithTheGivenDelay():void
		{
			var dispatcher:EventDispatcher = new EventDispatcher();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var task:TimerTask = new TimerTask(200);

			Mock.setup().that(result.onReturn(args, task)).returns(function ():void
			{
				dispatcher.dispatchEvent(new Event(Event.COMPLETE));
			});
			Mock.setup().that(result.onThrow(args, task)).returns(function ():void
			{
				dispatcher.dispatchEvent(new Event(Event.CANCEL));
			});

			task.await(args, result);

			Async.delayCall(this, function ():void
			{
				assertTrue(task.active);
				Mock.verify().total(0);
			}, 100);
			Async.handleEvent(this, dispatcher, Event.COMPLETE, function (...rest):void
			{
				assertFalse(task.active);
				Mock.verify().that(result.onReturn(args, task))
						.verify().total(1);
			}, 300);
			Async.failOnEvent(this, dispatcher, Event.CANCEL, 400);
		}

		[Test(async, timeout=500)]
		public function cancel_ShouldClearTimeout():void
		{
			var dispatcher:EventDispatcher = new EventDispatcher();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var task:TimerTask = new TimerTask(200);

			Mock.setup().that(result.onReturn(args, task)).returns(function ():void
			{
				dispatcher.dispatchEvent(new Event(Event.COMPLETE));
			});
			Mock.setup().that(result.onThrow(args, task)).returns(function ():void
			{
				dispatcher.dispatchEvent(new Event(Event.CANCEL));
			});

			task.await(args, result);

			Async.delayCall(this, function ():void
			{
				assertTrue(task.active);
				Mock.verify().total(0);

				task.cancel();

				assertFalse(task.active);
				Mock.verify().total(0);
			}, 100);
			Async.failOnEvent(this, dispatcher, Event.COMPLETE, 400);
			Async.failOnEvent(this, dispatcher, Event.CANCEL, 400);
		}

		[Test]
		public function await_zeroDelay_ShouldReturnImmediately():void
		{
			var result:MockResult = new MockResult();
			var args:Object = {};
			var task:TimerTask = new TimerTask(0);

			task.await(args, result);

			Mock.verify().that(result.onReturn(args, task))
					.verify().total(1);
		}

		[Test]
		public function await_negativeDelay_ShouldReturnImmediately():void
		{
			var result:MockResult = new MockResult();
			var args:Object = {};
			var task:TimerTask = new TimerTask(-1);

			task.await(args, result);

			Mock.verify().that(result.onReturn(args, task))
					.verify().total(1);
		}
	}
}
