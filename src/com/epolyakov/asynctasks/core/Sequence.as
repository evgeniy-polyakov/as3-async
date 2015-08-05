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
	}
}