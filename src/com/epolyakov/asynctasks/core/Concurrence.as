package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Concurrence implements IAsync, IResult
	{
		private var _tasks:Vector.<IAsync>;
		private var _active:Boolean;
		private var _result:IResult;

		public function Concurrence(task:IAsync)
		{
			_tasks = new <IAsync>[task];
		}

		public function get tasks():Vector.<IAsync>
		{
			return _tasks;
		}

		public function add(task:IAsync):void
		{
			if (!_active && _tasks && _tasks.indexOf(task) < 0)
			{
				_tasks.push(task);
			}
		}

		public function Await(data:Object = null, result:IResult = null):void
		{
			if (!_active)
			{
				if (_tasks && _tasks.length > 0)
				{
					_active = true;
					_result = result;
					var tasks:Vector.<IAsync> = _tasks.slice();
					for (var i:int = 0, n:int = tasks.length; i < n; i++)
					{
						tasks[i].Await(data, this);
					}
				}
				else if (result)
				{
					result.Return(data, this);
				}
			}
		}

		public function Break():void
		{
			if (_active)
			{
				_active = false;
				_result = null;
				if (_tasks && _tasks.length > 0)
				{
					var tasks:Vector.<IAsync> = _tasks.slice();
					_tasks = null;
					for (var i:int = 0, n:int = tasks.length; i < n; i++)
					{
						tasks[i].Break();
					}
				}
			}
		}

		public function Return(value:Object, target:IAsync):void
		{
			if (_active && _tasks && _tasks.length > 0)
			{
				var index:int = _tasks.indexOf(target);
				if (index >= 0)
				{
					_tasks.slice(index, 1);
				}
				if (_tasks.length == 0)
				{
					_active = false;
					_tasks = null;
					if (_result)
					{
						var result:IResult = _result;
						_result = null;
						result.Return(value, this);
					}
				}
			}
		}

		public function Throw(error:Object, target:IAsync):void
		{
			if (_active && _tasks && _tasks.length > 0 && _tasks.indexOf(target) >= 0)
			{
				_active = false;
				_tasks = null;
				if (_result)
				{
					var async:IResult = _result;
					_result = null;
					async.Throw(error, this);
				}
				else
				{
					throw error;
				}
			}
		}
	}
}