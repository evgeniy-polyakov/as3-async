package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class AsyncFactory implements IAsync, IResult, IAsyncFactory
	{
		private static var _null:Null = new Null();

		private var _tasks:Vector.<IAsync>;
		private var _active:Boolean;
		private var _result:IResult;

		public function AsyncFactory(task:Object)
		{
			_tasks = new <IAsync>[getTask(task)];
		}

		private static function getTask(value:Object):IAsync
		{
			if (value is IAsync)
			{
				return value as IAsync;
			}
			if (value is Function)
			{
				return new Func(value as Function);
			}
			if (value == null)
			{
				return _null;
			}
			return new Data(value);
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
					if (_tasks[0] is Pair) {
						_tasks[0] = Pair(_tasks[0]).success;
					}
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
				do {
					_tasks.shift();
				}
				while (_tasks.length > 0 && !(_tasks[0] is Pair));

				if (_tasks.length > 0)
				{
					_tasks[0] = Pair(_tasks[0]).failure;
					_tasks[0].execute(error, this);
				}
				else
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
		}

		public function then(successTask:Object, failureTask:Object = null):IAsyncFactory
		{
			if (!_active && _tasks)
			{
				if (failureTask == null)
				{
					_tasks.push(getTask(successTask));
				}
				else
				{
					_tasks.push(new Pair(getTask(successTask), getTask(failureTask)));
				}
			}
			return this;
		}

		public function and(task:Object, ...tasks):IAsyncFactory
		{
			if (!_active && _tasks && _tasks.length > 0)
			{
				var n:int = _tasks.length - 1;
				if (!(_tasks[n] is Concurrency))
				{
					_tasks[n] = new Concurrency(_tasks[n]);
				}
				Concurrency(_tasks[n]).add(getTask(task));
				for each (var t:Object in tasks)
				{
					Concurrency(_tasks[n]).add(getTask(t));
				}
			}
			return this;
		}

		public function fix(failureTask:Object):IAsyncBaseFactory
		{
			return then(null, failureTask);
		}
	}
}