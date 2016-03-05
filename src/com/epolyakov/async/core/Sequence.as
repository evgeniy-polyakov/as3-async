package com.epolyakov.async.core
{
	import flash.events.ErrorEvent;

	/**
	 * @author epolyakov
	 */
	internal class Sequence extends Launcher implements IAsync, IReliable
	{
		private static const SEQUENCE:int = 0;
		private static const CONJUNCTION:int = 1;
		private static const DISJUNCTION:int = 2;

		private var _type:int = SEQUENCE;
		private var _tasks:Vector.<ITask>;
		private var _result:IResult;
		private var _active:Boolean;
		private var _activating:Boolean;
		private var _out:Array;

		public function Sequence(task:Object)
		{
			_tasks = new <ITask>[];
			if (task != null)
			{
				_tasks.push(toTask(task));
			}
		}

		private static function toTask(value:Object):ITask
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
					if (!(result is Sequence))
					{
						Cache.add(this);
					}
					_active = true;
					_result = result;
					if (_type == SEQUENCE)
					{
						launch(_tasks[0], args);
					}
					else
					{
						if (_type == CONJUNCTION)
						{
							_out = [];
						}
						_activating = true;
						var tasks:Vector.<ITask> = _tasks.slice();
						for (var i:int = 0, n:int = tasks.length; i < n; i++)
						{
							if (_active)
							{
								launch(tasks[i], args);
							}
						}
						_activating = false;
					}
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
				_active = false;
				_result = null;
				_out = null;

				var n:int = _tasks.length;
				if (n > 0)
				{
					if (_type == SEQUENCE)
					{
						var task:ITask = _tasks[0];
						_tasks.splice(0, n);
						task.cancel();
					}
					else
					{
						var tasks:Vector.<ITask> = _tasks.slice();
						_tasks.splice(0, n);
						for (var i:int = 0; i < n; i++)
						{
							tasks[i].cancel();
						}
					}
				}
			}
		}

		override public function onReturn(value:Object, target:ITask = null):void
		{
			if (_active && _tasks.length > 0)
			{
				var complete:Boolean = false;
				switch (_type)
				{
					case SEQUENCE:
						if (target == _tasks[0])
						{
							super.onReturn(value, target);

							_tasks.shift();
							if (_tasks.length > 0)
							{
								launch(_tasks[0], value);
							}
							else
							{
								complete = true;
							}
						}
						break;
					case CONJUNCTION:
						var index:int = _tasks.indexOf(target);
						if (index >= 0)
						{
							super.onReturn(value, target);

							_tasks.splice(index, 1);
							_out.push(value);
							complete = _tasks.length == 0;
						}
						break;
					case DISJUNCTION:
						var index:int = _tasks.indexOf(target);
						if (index >= 0)
						{
							super.onReturn(value, target);

							var tasks:Vector.<ITask> = _tasks.slice();
							_tasks.splice(0, _tasks.length);
							for (var i:int = 0, n:int = _activating ? index : tasks.length; i < n; i++)
							{
								if (i != index)
								{
									tasks[i].cancel();
								}
							}
							complete = true;
						}
						break;
				}
				if (complete)
				{
					Cache.remove(this);
					_active = false;
					if (_result)
					{
						var result:IResult = _result;
						var out:Array = _out;
						_result = null;
						_out = null;
						result.onReturn(_type == CONJUNCTION ? out : value, this);
					}
				}
			}
		}

		override public function onThrow(error:Object, target:ITask = null):void
		{
			if (_active && _tasks.length > 0 && target == _tasks[0])
			{
				switch (_type) {
					case SEQUENCE:
						super.onThrow(error, target);
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
							_active = false;

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
						break;
					case CONJUNCTION:
						super.onThrow(error, target);

						var index:int = _tasks.indexOf(target);
						if (index >= 0)
						{
							_active = false;
							_out = null;
							var tasks:Vector.<ITask> = _tasks.slice();
							_tasks.splice(0, _tasks.length);
							for (var i:int = 0, n:int = _activating ? index : tasks.length; i < n; i++)
							{
								if (i != index)
								{
									tasks[i].cancel();
								}
							}
							if (_result)
							{
								var async:IResult = _result;
								_result = null;
								async.onThrow(error, this);
							}
							else
							{
								throw error;
							}
						}
						break;
					case DISJUNCTION:
						super.onThrow(error, target);

						var index:int = _tasks.indexOf(target);
						if (index >= 0)
						{
							_active = false;
							var tasks:Vector.<ITask> = _tasks.slice();
							_tasks.splice(0, _tasks.length);
							for (var i:int = 0, n:int = _activating ? index : tasks.length; i < n; i++)
							{
								if (i != index)
								{
									tasks[i].cancel();
								}
							}
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
						break;
				}

			}
		}

		public function then(task:Object, errorHandler:Object = null):IAsync
		{
			if (!_active)
			{
				if (task != null && errorHandler == null)
				{
					_tasks.push(toTask(task));
				}
				else if (task != null && errorHandler != null)
				{
					_tasks.push(new Fork(toTask(task), toTask(errorHandler)));
				}
				else if (errorHandler != null)
				{
					_tasks.push(new Fork(null, toTask(errorHandler)));
				}
			}
			return this;
		}

		public function and(task:Object):IAsyncConjunction
		{
			if (!_active && task != null)
			{
				var last:int = _tasks.length - 1;
				if (last < 0)
				{
					_tasks.push(toTask(task));
				}
				else
				{
					if (!(_tasks[last] is Conjunction))
					{
						_tasks[last] = new Conjunction(_tasks[last]);
					}
					Conjunction(_tasks[last]).add(toTask(task));
				}
			}
			return this;
		}

		public function or(task:Object):IAsyncDisjunction
		{
			if (!_active && task != null)
			{
				var last:int = _tasks.length - 1;
				if (last < 0)
				{
					_tasks.push(toTask(task));
				}
				else
				{
					if (!(_tasks[last] is Disjunction))
					{
						_tasks[last] = new Disjunction(_tasks[last]);
					}
					Disjunction(_tasks[last]).add(toTask(task));
				}
			}
			return this;
		}

		public function hook(errorHandler:Object):IAsyncSequence
		{
			if (!_active && errorHandler != null)
			{
				_tasks.push(new Fork(null, toTask(errorHandler)));
			}
			return this;
		}
	}
}