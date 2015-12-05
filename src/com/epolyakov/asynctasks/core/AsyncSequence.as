package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class AsyncSequence implements IAsync, ICancelable, IResult
	{
		private var _tasks:Vector.<IAwaitable>;
		private var _cancelable:ICancelable;
		private var _result:IResult;
		private var _active:Boolean;

		public function AsyncSequence(task:Object)
		{
			_tasks = new <IAwaitable>[getTask(task)];
		}

		private static function getTask(value:Object):IAwaitable
		{
			if (value is IAwaitable)
			{
				return value as IAwaitable;
			}
			if (value is Function)
			{
				return new Func(value as Function);
			}
			return new Data(value);
		}

		internal function get tasks():Vector.<IAwaitable>
		{
			return _tasks;
		}

		public function await(data:Object = null, result:IResult = null):ICancelable
		{
			if (!_active)
			{
				if (_tasks && _tasks.length > 0)
				{
					_active = true;
					_result = result;
					if (_tasks[0] is Fork)
					{
						_tasks[0] = Fork(_tasks[0]).success;
					}
					var cancelable:ICancelable = _tasks[0].await(data, this);
					if (_active)
					{
						_cancelable = cancelable;
					}
				}
				else if (result)
				{
					result.onReturn(data, this);
				}
			}
			return this;
		}

		public function cancel():void
		{
			if (_active)
			{
				_active = false;
				_result = null;
				_tasks = null;

				var cancelable:ICancelable = _cancelable;
				_cancelable = null;
				cancelable.cancel();
			}
		}

		public function onReturn(value:Object, target:IAwaitable):void
		{
			if (_active && _tasks && _tasks.length > 0 && target == _tasks[0])
			{
				do {
					_tasks.shift();
				}
				while (_tasks.length > 0 && _tasks[0] is Fork && Fork(_tasks[0]).success == null);
				if (_tasks.length > 0)
				{
					if (_tasks[0] is Fork)
					{
						_tasks[0] = Fork(_tasks[0]).success;
					}
					var cancelable:ICancelable = _tasks[0].await(value, this);
					if (_active)
					{
						_cancelable = cancelable;
					}
				}
				else
				{
					_active = false;
					_cancelable = null;
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

		public function onThrow(error:Object, target:IAwaitable):void
		{
			if (_active && _tasks && _tasks.length > 0 && target == _tasks[0])
			{
				do {
					_tasks.shift();
				}
				while (_tasks.length > 0 && !(_tasks[0] is Fork));

				if (_tasks.length > 0)
				{
					_tasks[0] = Fork(_tasks[0]).failure;
					var cancelable:ICancelable = _tasks[0].await(error, this);
					if (_active)
					{
						_cancelable = cancelable;
					}
				}
				else
				{
					_active = false;
					_cancelable = null;
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

		public function then(task:Object):IAsync
		{
			if (!_active && _tasks)
			{
				_tasks.push(getTask(task));
			}
			return this;
		}

		public function and(task:Object):IAsyncConjunction
		{
			if (!_active && _tasks && _tasks.length > 0)
			{
				var n:int = _tasks.length - 1;
				if (!(_tasks[n] is Conjuction))
				{
					_tasks[n] = new Conjuction(_tasks[n]);
				}
				Conjuction(_tasks[n]).add(getTask(task));
			}
			return this;
		}

		public function or(task:Object):IAsyncDisjunction
		{
			if (!_active && _tasks && _tasks.length > 0)
			{
				var n:int = _tasks.length - 1;
				if (!(_tasks[n] is Disjuction))
				{
					_tasks[n] = new Disjuction(_tasks[n]);
				}
				Disjuction(_tasks[n]).add(getTask(task));
			}
			return this;
		}

		public function fork(success:Object, failure:Object):IAsyncSequence
		{
			if (!_active && _tasks)
			{
				_tasks.push(new Fork(getTask(success), getTask(failure)));
			}
			return this;
		}

		public function hook(failure:Object):IAsyncSequence
		{
			if (!_active && _tasks)
			{
				_tasks.push(new Fork(null, getTask(failure)));
			}
			return this;
		}
	}
}