package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Switch implements IAsync, IResult
	{
		private var _cases:Vector.<Case>;
		private var _default:IAsync;
		private var _active:Boolean;
		private var _result:IResult;

		public function Switch()
		{
			_cases = new <Case>[];
		}

		public function addCase(value:Case):void
		{
			if (!_active && _cases)
			{
				_cases.push(value);
			}
		}

		public function addTask(task:IAsync):void
		{
			if (!_active && _cases && _cases.length > 0)
			{
				_cases[_cases.length - 1].task = task;
			}
		}

		public function setDefault(task:IAsync):void
		{
			if (!_active)
			{
				_default = task;
			}
		}

		public function execute(data:Object = null, result:IResult = null):void
		{
			if (!_active)
			{
				for each (var c:Case in _cases)
				{
					if (c.accept(data) && c.task)
					{
						_default = c.task;
						break;
					}
				}
				_cases = null;

				if (_default)
				{
					_active = true;
					_result = result;
					_default.execute(data, this);
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
				_cases = null;
				if (_default)
				{
					var task:IAsync = _default;
					_default = null;
					task.interrupt();
				}
			}
		}

		public function onReturn(value:Object, target:IAsync):void
		{
			if (_active && target == _default)
			{
				_active = false;
				_cases = null;
				_default = null;
				if (_result)
				{
					var result:IResult = _result;
					_result = null;
					result.onReturn(value, this);
				}
			}
		}

		public function onThrow(error:Object, target:IAsync):void
		{
			if (_active && target == _default)
			{
				_active = false;
				_cases = null;
				_default = null;
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