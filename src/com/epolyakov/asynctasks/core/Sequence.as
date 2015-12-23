package com.epolyakov.asynctasks.core
{
	import flash.events.ErrorEvent;

	/**
	 * @author epolyakov
	 */
	internal class Sequence implements IAsync, IResult
	{
		private static var _instances:Vector.<Sequence> = new <Sequence>[];

		private var _tasks:Vector.<ITask>;
		private var _result:IResult;
		private var _active:Boolean;

		public function Sequence(task:Object)
		{
			_tasks = new <ITask>[getTask(task)];
		}

		internal static function get instances():Vector.<Sequence>
		{
			return _instances;
		}

		private static function addInstance(instance:Sequence):void
		{
			if (_instances.indexOf(instance) < 0)
			{
				_instances.push(instance);
			}
		}

		private static function removeInstance(instance:Sequence):void
		{
			var index:int = _instances.indexOf(instance);
			if (index >= 0)
			{
				_instances.splice(index, 1);
			}
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
				if (_tasks && _tasks.length > 0)
				{
					addInstance(this);
					_active = true;
					_result = result;
					if (_tasks[0] is Fork)
					{
						_tasks[0] = Fork(_tasks[0]).success;
					}
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
				removeInstance(this);
				_active = false;
				_result = null;

				var task:ITask = _tasks[0];
				_tasks = null;
				task.cancel();
			}
		}

		public function onReturn(value:Object, target:ITask):void
		{
			if (_active && _tasks && _tasks.length > 0 && target == _tasks[0])
			{
				do
				{
					_tasks.shift();
				}
				while (_tasks.length > 0 && _tasks[0] is Fork && Fork(_tasks[0]).success == null);

				if (_tasks.length > 0)
				{
					if (_tasks[0] is Fork)
					{
						_tasks[0] = Fork(_tasks[0]).success;
					}
					_tasks[0].await(value, this);
				}
				else
				{
					removeInstance(this);
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

		public function onThrow(error:Object, target:ITask):void
		{
			if (_active && _tasks && _tasks.length > 0 && target == _tasks[0])
			{
				do
				{
					_tasks.shift();
				}
				while (_tasks.length > 0 && !(_tasks[0] is Fork));

				if (_tasks.length > 0)
				{
					_tasks[0] = Fork(_tasks[0]).failure;
					_tasks[0].await(error, this);
				}
				else
				{
					removeInstance(this);
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
				if (!(_tasks[n] is Conjunction))
				{
					_tasks[n] = new Conjunction(_tasks[n]);
				}
				Conjunction(_tasks[n]).add(getTask(task));
			}
			return this;
		}

		public function or(task:Object):IAsyncDisjunction
		{
			if (!_active && _tasks && _tasks.length > 0)
			{
				var n:int = _tasks.length - 1;
				if (!(_tasks[n] is Disjunction))
				{
					_tasks[n] = new Disjunction(_tasks[n]);
				}
				Disjunction(_tasks[n]).add(getTask(task));
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