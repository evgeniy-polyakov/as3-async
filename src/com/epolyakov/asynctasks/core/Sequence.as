package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Sequence extends AsyncFactory implements IAsync, IResult, IAsyncFactory
	{
		private var _tasks:Vector.<IAsync>;
		private var _active:Boolean;
		private var _result:IResult;

		public function Sequence(task:IAsync)
		{
			_tasks = new <IAsync>[task];
		}

		internal function get tasks():Vector.<IAsync>
		{
			return _tasks;
		}

		public function execute(data:Object = null, result:IResult = null):void
		{
			if (!_active)
			{
				if (_tasks && _tasks.length > 0)
				{
					_active = true;
					_result = result;
					_tasks[0].execute(data, this);
				}
				else if (result)
				{
					result.onReturn(data, this);
				}
			}
		}

		public function interrupt():void
		{
			if (_active)
			{
				_active = false;
				_result = null;
				if (_tasks && _tasks.length > 0)
				{
					var task:IAsync = _tasks[0];
					_tasks = null;
					task.interrupt();
				}
			}
		}

		public function onReturn(value:Object, target:IAsync):void
		{
			if (_active && _tasks && _tasks.length > 0 && target == _tasks[0])
			{
				_tasks.shift();
				if (_tasks.length > 0)
				{
					_tasks[0].execute(value, this);
				}
				else
				{
					_active = false;
					_tasks = null;
					if (_result)
					{
						var result:IResult = _result;
						_result = null;
						result.onReturn(value, this);
					}
				}
			}
		}

		public function onThrow(error:Object, target:IAsync):void
		{
			if (_active && _tasks && _tasks.length > 0 && target == _tasks[0])
			{
				_active = false;
				_tasks = null;
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

		public function next(task:Object):IAsyncFactory
		{
			if (!_active && _tasks)
			{
				_tasks.push(getTask(task));
			}
			return this;
		}

		public function concurrent(task:Object):IAsyncFactory
		{
			if (!_active && _tasks && _tasks.length > 0)
			{
				var n:int = _tasks.length - 1;
				if (!(_tasks[n] is Concurrency))
				{
					_tasks[n] = new Concurrency(_tasks[n]);
				}
				Concurrency(_tasks[n]).add(getTask(task));
			}
			return this;
		}

		public function ifThrows(value:Object = null):IAsyncThrowFactory
		{
			return null;
		}

		public function ifReturns(value:Object):IAsyncReturnFactory
		{
			return null;
		}
	}
}