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

		public function Await(data:Object = null, result:IResult = null):void
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
					result.Throw(error, this);
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
				_task.Await(data, this);
			}
			else if (value === undefined && result)
			{
				result.Return(data, this);
			}
			else if (result)
			{
				result.Return(value, this);
			}
		}

		public function Break():void
		{
			if (_task)
			{
				var task:IAsync = _task;
				_task = null;
				task.Break();
			}
		}

		public function Return(value:Object, target:IAsync):void
		{
			if (target == _task)
			{
				_task = null;
				if (_result)
				{
					var result:IResult = _result;
					_result = null;
					result.Return(value, this);
				}
			}
		}

		public function Throw(error:Object, target:IAsync):void
		{
			if (target == _task)
			{
				_task = null;
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