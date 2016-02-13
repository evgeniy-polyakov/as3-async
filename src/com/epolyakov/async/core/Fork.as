package com.epolyakov.async.core
{
	/**
	 * @author epolyakov
	 */
	internal class Fork extends Launcher implements ITask, IReliable
	{
		private var _state:int;
		private var _result:IResult;
		private var _task1:ITask;
		private var _task2:ITask;

		public function Fork(task1:ITask, task2:ITask)
		{
			_task1 = task1;
			_task2 = task2;
		}

		internal function get task1():ITask
		{
			return _task1;
		}

		internal function get task2():ITask
		{
			return _task2;
		}

		public function get state():int
		{
			return _state;
		}

		public function get result():IResult
		{
			return _result;
		}

		public function await(args:Object = null, result:IResult = null):void
		{
			if (_state == 0)
			{
				if (_task1)
				{
					_state = 1;
					_result = result;
					launch(_task1, args);
				}
				else if (result)
				{
					result.onReturn(args, this);
				}
			}
		}

		public function await2(args:Object = null, result:IResult = null):void
		{
			if (_state == 0)
			{
				if (_task2)
				{
					_state = 2;
					_result = result;
					launch(_task2, args);
				}
				else if (result)
				{
					result.onThrow(args, this);
				}
				else
				{
					throw args;
				}
			}
		}

		public function cancel():void
		{
			var task:ITask;
			if (_state == 1)
			{
				_state = 0;
				_result = null;
				_task2 = null;
				if (_task1)
				{
					task = _task1;
					_task1 = null;
					task.cancel();
				}
			}
			else if (_state == 2)
			{
				_state = 0;
				_result = null;
				_task1 = null;
				if (_task2)
				{
					task = _task2;
					_task2 = null;
					task.cancel();
				}
			}
		}

		override public function onReturn(value:Object, target:ITask = null):void
		{
			if ((_state == 1 && target == _task1) || (_state == 2 && target == _task2))
			{
				super.onReturn(value, target);

				_state = 0;
				_task1 = null;
				_task2 = null;
				if (_result)
				{
					var result:IResult = _result;
					_result = null;
					result.onReturn(value, this);
				}
			}
		}

		override public function onThrow(error:Object, target:ITask = null):void
		{
			if ((_state == 1 && target == _task1) || (_state == 2 && target == _task2))
			{
				super.onThrow(error, target);
				
				_state = 0;
				_task1 = null;
				_task2 = null;
				if (_result)
				{
					var result:IResult = _result;
					_result = null;
					result.onThrow(error, this);
				}
				else
				{
					throw error;
				}
			}
		}
	}
}