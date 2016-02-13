package com.epolyakov.async.core
{
	/**
	 * @author epolyakov
	 */
	internal class Func implements ITask, IResult
	{
		private var _func:Function;
		private var _task:ITask;
		private var _result:IResult;

		public function Func(func:Function)
		{
			_func = func;
		}

		internal function get func():Function
		{
			return _func;
		}

		internal function get task():ITask
		{
			return _task;
		}

		internal function get result():IResult
		{
			return _result;
		}

		public function await(args:Object = null, result:IResult = null):void
		{
			var value:*;
			try
			{
				if (_func.length == 1)
				{
					value = _func(args);
				}
				else
				{
					value = _func();
				}
			}
			catch (error:*)
			{
				if (result)
				{
					result.onThrow(error, this);
				}
				return;
			}
			if (value is ITask)
			{
				_task = value;
				_result = result;
				_task.await(args, this);
			}
			else if (value === undefined && result)
			{
				result.onReturn(args, this);
			}
			else if (result)
			{
				result.onReturn(value, this);
			}
		}

		public function cancel():void
		{
			if (_task)
			{
				var task:ITask = _task;
				_result = null;
				_task = null;
				task.cancel();
			}
		}

		public function onReturn(value:Object, target:ITask = null):void
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

		public function onThrow(error:Object, target:ITask = null):void
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