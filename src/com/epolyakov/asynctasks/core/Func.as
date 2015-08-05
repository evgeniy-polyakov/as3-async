package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Func implements IAsync, IResult
	{
		private var _func:Function;
		private var _task:IAsync;
		private var _result:IResult;

		public function Func(func:Function)
		{
			_func = func;
		}

		public function get func():Function
		{
			return _func;
		}

		public function execute(data:Object = null, result:IResult = null):void
		{
			var value:*;
			try
			{
				if (_func.length == 1)
				{
					value = _func(data);
				}
				else
				{
					value = _func();
				}
			}
			catch (error:Object)
			{
				if (result)
				{
					result.onThrow(error, this);
				}
				else
				{
					throw error;
				}
				return;
			}
			if (value is IAsync)
			{
				_task = value;
				_result = result;
				_task.execute(data, this);
			}
			else if (value === undefined && result)
			{
				result.onReturn(data, this);
			}
			else if (result)
			{
				result.onReturn(value, this);
			}
		}

		public function interrupt():void
		{
			if (_task)
			{
				var task:IAsync = _task;
				_task = null;
				task.interrupt();
			}
		}

		public function onReturn(value:Object, target:IAsync):void
		{
			if (target == _task)
			{
				_task = null;
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
			if (target == _task)
			{
				_task = null;
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