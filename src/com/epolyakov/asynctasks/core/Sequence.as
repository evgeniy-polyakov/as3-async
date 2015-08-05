package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Sequence implements IAsync, IResult
	{
		private var _tasks:Vector.<IAsync>;
		private var _active:Boolean;
		private var _result:IResult;

		public function Sequence(task:IAsync)
		{
			_tasks = new <IAsync>[task];
		}

		public function get tasks():Vector.<IAsync>
		{
			return _tasks;
		}

		public function add(task:IAsync):void
		{
			if (!_active && _tasks)
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
					_tasks[0].Await(data, this);
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
					var task:IAsync = _tasks[0];
					_tasks = null;
					task.Break();
				}
			}
		}

		public function Return(value:Object, target:IAsync):void
		{
			if (_active && _tasks && _tasks.length > 0 && target == _tasks[0])
			{
				_tasks.shift();
				if (_tasks.length > 0)
				{
					_tasks[0].Await(value, this);
				}
				else
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
			if (_active && _tasks && _tasks.length > 0 && target == _tasks[0])
			{
				_active = false;
				_tasks = null;
				if (_result)
				{
					var result:IResult = _result;
					_result = null;
					result.Throw(error, this);
				}
				else
				{
					throw error;
				}
			}
		}
	}
}