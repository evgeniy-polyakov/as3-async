package com.epolyakov.async.core
{
	import flash.events.ErrorEvent;

	/**
	 * @author epolyakov
	 */
	internal class Sequence implements IAsync, IResult
	{
		private var _tasks:Vector.<ITask>;
		private var _result:IResult;
		private var _active:Boolean;
		private var _args:Object;

		public function Sequence(task:Object)
		{
			_tasks = new <ITask>[getTask(task)];
		}

		private static function getTask(value:Object):ITask
		{
			if (value is ITask)
			{
				return value as ITask;
			}
			if (value is Function)
			{
				return new Func(value as Function);
			}
			if (value is Error || value is ErrorEvent)
			{
				return new Throw(value);
			}
			return new Return(value);
		}

		internal function get tasks():Vector.<ITask>
		{
			return _tasks;
		}

		internal function get result():IResult
		{
			return _result;
		}

		internal function get active():Boolean
		{
			return _active;
		}

		public function await(args:Object = null, result:IResult = null):void
		{
			if (!_active)
			{
				if (_tasks.length > 0)
				{
					Cache.add(this);
					_args = args;
					_active = true;
					_result = result;
					_tasks[0].await(args, this);
				}
				else if (result)
				{
					result.onReturn(args, this);
				}
			}
		}

		public function cancel():void
		{
			if (_active)
			{
				Cache.remove(this);
				_args = null;
				_active = false;
				_result = null;

				if (_tasks.length > 0)
				{
					var task:ITask = _tasks[0];
					_tasks.splice(0, _tasks.length);
					task.cancel();
				}
			}
		}

		public function onReturn(value:Object, target:ITask = null):void
		{
			if (_active && _tasks.length > 0 && target == _tasks[0])
			{
				if (value is ITask)
				{
					_tasks[0] = value as ITask;
					_tasks[0].await(_args, this);
				}
				else
				{
					_tasks.shift();
					if (_tasks.length > 0)
					{
						_args = value;
						_tasks[0].await(value, this);
					}
					else
					{
						Cache.remove(this);
						_args = null;
						_active = false;
						_tasks.splice(0, _tasks.length);

						if (_result)
						{
							var result:IResult = _result;
							_result = null;
							result.onReturn(value, this);
						}
					}
				}
			}
		}

		public function onThrow(error:Object, target:ITask = null):void
		{
			if (_active && _tasks.length > 0 && target == _tasks[0])
			{
				do
				{
					_tasks.shift();
				}
				while (_tasks.length > 0 && !(_tasks[0] is Fork));

				if (_tasks.length > 0)
				{
					Fork(_tasks[0]).await2(error, this);
				}
				else
				{
					Cache.remove(this);
					_args = null;
					_active = false;
					_tasks.splice(0, _tasks.length);

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
			if (!_active)
			{
				_tasks.push(getTask(task));
			}
			return this;
		}

		public function and(task:Object):IAsyncConjunction
		{
			if (!_active && _tasks.length > 0)
			{
				var last:int = _tasks.length - 1;
				if (!(_tasks[last] is Conjunction))
				{
					_tasks[last] = new Conjunction(_tasks[last]);
				}
				Conjunction(_tasks[last]).add(getTask(task));
			}
			return this;
		}

		public function or(task:Object):IAsyncDisjunction
		{
			if (!_active && _tasks.length > 0)
			{
				var last:int = _tasks.length - 1;
				if (!(_tasks[last] is Disjunction))
				{
					_tasks[last] = new Disjunction(_tasks[last]);
				}
				Disjunction(_tasks[last]).add(getTask(task));
			}
			return this;
		}

		public function fork(success:Object, failure:Object):IAsyncSequence
		{
			if (!_active)
			{
				_tasks.push(new Fork(getTask(success), getTask(failure)));
			}
			return this;
		}

		public function hook(failure:Object):IAsyncSequence
		{
			if (!_active)
			{
				_tasks.push(new Fork(null, getTask(failure)));
			}
			return this;
		}
	}
}