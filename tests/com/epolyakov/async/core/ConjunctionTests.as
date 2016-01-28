package com.epolyakov.async.core
{
	import com.epolyakov.async.core.mocks.MockResult;
	import com.epolyakov.async.core.mocks.MockTask;
	import com.epolyakov.mock.It;
	import com.epolyakov.mock.Mock;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class ConjunctionTests
	{
		[Before]
		public function Before():void
		{
			Mock.clear();
		}

		[Test]
		public function constructor_ShouldSetTask():void
		{
			var task:MockTask = new MockTask();
			var conjunction:Conjunction = new Conjunction(task);

			assertEquals(1, conjunction.tasks.length);
			assertEquals(task, conjunction.tasks[0]);
			assertFalse(conjunction.active);
			assertNull(conjunction.result);
			Mock.verify().total(0);
		}

		[Test]
		public function add_ShouldAddTask():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.add(task1);
			conjunction.add(task2);

			assertEquals(3, conjunction.tasks.length);
			assertEquals(task, conjunction.tasks[0]);
			assertEquals(task1, conjunction.tasks[1]);
			assertEquals(task2, conjunction.tasks[2]);
			assertFalse(conjunction.active);
			assertNull(conjunction.result);
			Mock.verify().total(0);
		}

		[Test]
		public function add_ShouldNotAddTaskAgain():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.add(task);
			conjunction.add(task);
			conjunction.add(task1);
			conjunction.add(task1);

			assertEquals(2, conjunction.tasks.length);
			assertEquals(task, conjunction.tasks[0]);
			assertEquals(task1, conjunction.tasks[1]);
			assertFalse(conjunction.active);
			assertNull(conjunction.result);
			Mock.verify().total(0);
		}

		[Test]
		public function add_ShouldNotAddTaskWhenActive():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.await();
			conjunction.add(task1);

			assertEquals(1, conjunction.tasks.length);
			assertEquals(task, conjunction.tasks[0]);
		}

		[Test]
		public function await_ShouldSetActiveAndResult():void
		{
			var task:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.await({}, result);

			assertTrue(conjunction.active);
			assertEquals(result, conjunction.result);
		}

		[Test]
		public function await_ShouldStartAllTasks():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.add(task1);
			conjunction.add(task2);
			conjunction.await(args, result);

			Mock.verify().that(task.await(args, conjunction))
					.verify().that(task1.await(args, conjunction))
					.verify().that(task2.await(args, conjunction))
					.verify().total(3);
		}

		[Test]
		public function await_ShouldReturnIfEmpty():void
		{
			var task:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var conjunction:Conjunction = new Conjunction(task);
			conjunction.tasks.splice(0, 1);
			conjunction.await(args, result);

			Mock.verify().that(result.onReturn(args, conjunction))
					.verify().total(1);
		}

		[Test]
		public function await_ShouldReturnIfAllTaskAreComplete():void
		{
			var task:MockTask = new MockTask();
			var task1:MockTask = new MockTask();
			var task2:MockTask = new MockTask();
			var result:MockResult = new MockResult();
			var args:Object = {};
			var conjunction:Conjunction = new Conjunction(task);

			Mock.setup().that(task.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(10, this as ITask);
			});
			Mock.setup().that(task1.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(20, this as ITask);
			});
			Mock.setup().that(task2.await(args, conjunction)).returns(function (args:Object, result:IResult):void
			{
				result.onReturn(30, this as ITask);
			});

			conjunction.add(task1);
			conjunction.add(task2);
			conjunction.await(args, result);

			Mock.verify().that(result.onReturn(It.match(function (value:Object):Boolean
					{
						return value is Array && (value as Array).length == 3
								&& value[0] == 10 && value[1] == 20 && value[2] == 30;
					}), It.isEqual(conjunction)))
					.verify().total(4);
		}
	}
}
