package com.epolyakov.async.core
{
	/**
	 * @author epolyakov
	 */
	internal class Disjunction extends Launcher implements IAsyncDisjunction, IReliable
	{
		private var _tasks:Vector.<ITask>;
		private var _result:IResult;
		private var _active:Boolean;
		private var _activating:Boolean;
		private var _args:Object;

		public function Disjunction(task:Object)
		{
			_tasks = new <ITask>[];
			if (task != null)
			{
				_tasks.push(toTask(task));
			}
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
					if (!(result is IReliable))
					{
						Cache.add(this);
					}
					_active = true;
					_result = result;
					_args = args;

					_activating = true;
					var tasks:Vector.<ITask> = _tasks.slice();
					for (var i:int = 0, n:int = tasks.length; i < n; i++)
					{
						// Check active because any of tasks can return or throw.
						if (_active)
						{
							launch(tasks[i], args);
						}
					}
					_activating = false;
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
				_args = null;

				if (_tasks.length > 0)
				{
					var tasks:Vector.<ITask> = _tasks.slice();
					_tasks.splice(0, _tasks.length);
					for (var i:int = 0, n:int = tasks.length; i < n; i++)
					{
						tasks[i].cancel();
					}
				}
			}
		}

		override public function onReturn(value:Object, target:ITask = null):void
		{
			if (_active && _tasks.length > 0)
			{
				super.onReturn(value, target);

				var index:int = _tasks.indexOf(target);
				if (index >= 0)
				{
					Cache.remove(this);
					_active = false;
					_args = null;

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
						result.onReturn(value, this);
					}
				}
			}
		}

		override public function onThrow(error:Object, target:ITask = null):void
		{
			if (_active && _tasks.length > 0)
			{
				super.onThrow(error, target);

				var index:int = _tasks.indexOf(target);
				if (index >= 0)
				{
					Cache.remove(this);
					_active = false;
					_args = null;

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
			}
		}

		public function or(task:Object):IAsyncDisjunction
		{
			if (task != null)
			{
				var t:ITask = toTask(task);
				if (_tasks.indexOf(t) < 0)
				{
					_tasks.push(t);
				}
				if (_active)
				{
					launch(t, _args);
				}
			}
			return this;
		}
	}
}