package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Conjunction implements ITask, IResult
	{
		private var _tasks:Vector.<ITask>;
		private var _result:IResult;
		private var _active:Boolean;

		public function Conjunction(task:ITask)
		{
			_tasks = new <ITask>[task];
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
					_active = true;
					_result = result;
					var tasks:Vector.<ITask> = _tasks.slice();
					for (var i:int = 0, n:int = tasks.length; i < n; i++)
					{
						tasks[i].await(args, this);
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
				_active = false;
				_result = null;
				if (_tasks && _tasks.length > 0)
				{
					var tasks:Vector.<ITask> = _tasks.slice();
					_tasks = null;
					for (var i:int = 0, n:int = tasks.length; i < n; i++)
					{
						tasks[i].cancel();
					}
				}
			}
		}

		public function onReturn(value:Object, target:ITask):void
		{
			if (_active && _tasks && _tasks.length > 0)
			{
				var index:int = _tasks.indexOf(target);
				if (index >= 0)
				{
					_tasks.splice(index, 1);
					if (_tasks.length == 0)
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
		}

		public function onThrow(error:Object, target:ITask):void
		{
			if (_active && _tasks && _tasks.length > 0)
			{
				var index:int = _tasks.indexOf(target);
				if (index >= 0)
				{
					var tasks:Vector.<ITask> = _tasks.slice();
					_active = false;
					_tasks = null;
					for (var i:int = 0, n:int = tasks.length; i < n; i++)
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
			}
		}

		internal function add(task:ITask):void
		{
			if (!_active && _tasks && _tasks.indexOf(task) < 0)
			{
				_tasks.push(task);
			}
		}
	}
}