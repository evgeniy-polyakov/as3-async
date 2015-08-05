package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Try implements IAsync, IResult
	{
		private static const IDLE:int = -1;
		private static const TRY:int = 0;
		private static const CATCH:int = 1;
		private static const DEFAULT:int = 2;

		private var _tryTask:IAsync;
		private var _default:IAsync;
		private var _cases:Vector.<Case>;
		private var _state:int = IDLE;
		private var _result:IResult;

		public function Try(tryTask:IAsync)
		{
			_tryTask = tryTask;
			_cases = new <Case>[];
		}

		public function addCase(value:Case):void
		{
			if (_state == IDLE && _cases)
			{
				_cases.push(value);
			}
		}

		public function addTask(task:IAsync):void
		{
			if (_state == IDLE && _cases && _cases.length > 0)
			{
				_cases[_cases.length - 1].task = task;
			}
		}

		public function setDefault(task:IAsync):void
		{
			if (_state == IDLE)
			{
				_default = task;
			}
		}

		public function execute(data:Object = null, result:IResult = null):void
		{
			if (_state == IDLE)
			{
				if (_tryTask)
				{
					_state = TRY;
					_result = result;
					_tryTask.execute(data, this);
				}
				else if (result)
				{
					result.onReturn(data, this);
				}
			}
		}

		public function interrupt():void
		{
			if (_state >= TRY && _state <= DEFAULT)
			{
				var task:IAsync;
				if (_state == TRY)
				{
					task = _tryTask;
				}
				else if (_state == CATCH || _state == DEFAULT)
				{
					task = _default;
				}
				_state = IDLE;
				_tryTask = null;
				_default = null;
				_cases = null;
				_result = null;
				if (task)
				{
					task.interrupt();
				}
			}
		}

		public function onReturn(value:Object, target:IAsync):void
		{
			var complete:Boolean = false;
			if (_state == TRY && target == _tryTask)
			{
				_cases = null;
				_tryTask = null;
				if (_default)
				{
					_state = DEFAULT;
					_default.execute(value, this);
				}
				else
				{
					_state = IDLE;
					complete = true;
				}
			}
			else if ((_state == CATCH || _state == DEFAULT) && target == _default)
			{
				_state = IDLE;
				_cases = null;
				_tryTask = null;
				_default = null;
				complete = true;
			}
			if (complete && _result)
			{
				var result:IResult = _result;
				_result = null;
				result.onReturn(value, this);
			}
		}

		public function onThrow(error:Object, target:IAsync):void
		{
			var complete:Boolean = false;
			if (_state == TRY && target == _tryTask)
			{
				_tryTask = null;
				_default = null;
				for each (var c:Case in _cases)
				{
					if (c.accept(error) && c.task)
					{
						_default = c.task;
					}
				}
				_cases = null;
				if (_default)
				{
					_state = CATCH;
					_default.execute(error, this);
				}
				else
				{
					_state = IDLE;
					complete = true;
				}
			}
			else if ((_state == CATCH || _state == DEFAULT) && target == _default)
			{
				_state = IDLE;
				_cases = null;
				_tryTask = null;
				_default = null;
				complete = true;
			}
			if (complete && _result)
			{
				var result:IResult = _result;
				_result = null;
				result.onThrow(error, this);
			}
		}
	}
}