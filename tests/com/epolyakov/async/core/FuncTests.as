package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mocks.MockResult;
	import com.epolyakov.mock.Mock;

	import flash.errors.IOError;

	import org.flexunit.asserts.assertEquals;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class FuncTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test]
		public function constructor_ShouldSetTasks():void
		{
			var func:Function = function ():void
			{
				Mock.invoke(null, func);
			};
			var task:Func = new Func(func);

			assertEquals(func, task.func);
			Mock.verify().total(0);
		}

		[Test]
		public function await_ShouldCallFunc0Args():void
		{
			var out:Object = {};
			var func:Function = function ():Object
			{
				Mock.invoke(null, func);
				return out;
			};
			var task:Func = new Func(func);
			var result:MockResult = new MockResult();

			task.await({}, result);

			Mock.verify().that(func())
					.verify().that(result.onReturn(out, task))
					.verify().total(2);
		}

		[Test]
		public function await_ShouldCallFunc1Arg():void
		{
			var out:Object = {};
			var args:Object = {};
			var func:Function = function (obj:Object):Object
			{
				Mock.invoke(null, func, obj);
				return out;
			};
			var task:Func = new Func(func);
			var result:MockResult = new MockResult();

			task.await(args, result);

			Mock.verify().that(func(args))
					.verify().that(result.onReturn(out, task))
					.verify().total(2);
		}

		[Test(expects="ArgumentError")]
		public function await_ShouldThrowIfMoreThan1Args():void
		{
			var out:Object = {};
			var args:Object = {};
			var func:Function = function (obj:Object, obj2:Object):Object
			{
				return out;
			};
			var task:Func = new Func(func);
			var result:MockResult = new MockResult();

			task.await(args, result);
		}

		[Test(expects="flash.errors.IOError")]
		public function await_ShouldThrowIfFuncThrows():void
		{
			var args:Object = {};
			var func:Function = function (obj:Object):Object
			{
				throw new IOError();
			};
			var task:Func = new Func(func);
			var result:MockResult = new MockResult();

			task.await(args, result);
		}
	}
}
