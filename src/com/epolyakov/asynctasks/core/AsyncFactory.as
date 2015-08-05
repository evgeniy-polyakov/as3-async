package com.epolyakov.asynctasks.core
{
	import flash.errors.IllegalOperationError;

	/**
	 * @author epolyakov
	 */
	internal class AsyncFactory implements IAsyncFactory, ICatchFactory, ICaseFactory, IThenFactory, IResult
	{
		private var _task:IAsync;
		private var _active:Boolean;
		private var _result:IResult;

		public function AsyncFactory(task:Object)
		{
			_task = getTask(task);
		}

		private static function getTask(value:Object):IAsync
		{
			if (value is IAsync)
			{
				return value as IAsync;
			}
			if (value is Function)
			{
				return new Func(value as Function);
			}
			return new Data(value);
		}

		private static function getCase(value:Object):Case
		{
			if (value is Class)
			{
				return new CaseClass(value as Class);
			}
			if (value is Function)
			{
				return new CaseFunc(value as Function);
			}
			return new CaseEqual(value);
		}

		internal function get task():IAsync
		{
			return _task;
		}

		public function Next(task:Object):IAsyncFactory
		{
			if (!(_task is Sequence))
			{
				_task = new Sequence(_task);
			}
			Sequence(_task).add(getTask(task));
			return this;
		}

		public function Concurrent(task:Object):IAsyncFactory
		{
			if (!(_task is Concurrence))
			{
				_task = new Concurrence(_task);
			}
			Concurrence(_task).add(getTask(task));
			return this;
		}

		public function Catch(value:Object):ICatchFactory
		{
			if (!(_task is Try))
			{
				_task = new Try(_task);
			}
			Try(_task).addCase(getCase(value));
			return this;
		}

		public function Case(value:Object):ICaseFactory
		{
			if (_task is Switch)
			{
				Switch(_task).addCase(getCase(value));
			}
			else
			{
				if (!(_task is Sequence))
				{
					_task = new Sequence(_task);
				}
				var task:Switch = new Switch();
				task.addCase(getCase(value));
				Sequence(_task).add(task);
			}
			return this;
		}

		public function Then(task:Object):IThenFactory
		{
			if (_task is Try)
			{
				Try(_task).addTask(getTask(task));
			}
			else if (_task is Switch)
			{
				Switch(_task).addTask(getTask(task));
			}
			else
			{
				throw new IllegalOperationError("Invalid context for method Then.");
			}
			return this;
		}

		public function Else(task:Object):IBaseFactory
		{
			if (_task is Try)
			{
				Try(_task).setDefault(getTask(task));
			}
			else if (_task is Switch)
			{
				Switch(_task).setDefault(getTask(task));
			}
			else
			{
				throw new IllegalOperationError("Invalid context for method Else.");
			}
			return this;
		}

		public function Await(data:Object = null, result:IResult = null):void
		{
			if (!_active)
			{
				if (_task)
				{
					_active = true;
					_result = result;
					_task.Await(data, this);
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

				var task:IAsync = _task;
				_task = null;
				task.Break();
			}
		}

		public function Return(value:Object, target:IAsync):void
		{
			if (_active && target == _task)
			{
				_active = false;
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
			if (_active && target == _task)
			{
				_active = false;
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