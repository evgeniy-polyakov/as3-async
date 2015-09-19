package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class AsyncFactory
	{
//		private var _task:IAsync;
//		private var _active:Boolean;
//		private var _result:IResult;
//
//		public function AsyncFactory(task:Object)
//		{
//			_task = getTask(task);
//		}

		protected static function getTask(value:Object):IAsync
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

		protected static function getCase(value:Object):Case
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

		protected static function getCatch(value:Object):Case
		{
			if (value == null)
			{
				return new CaseAny();
			}
			return getCase(value);
		}

//		internal function get task():IAsync
//		{
//			return _task;
//		}
//
//		public function next(task:Object):IAsyncFactory
//		{
//			if (!(_task is Sequence))
//			{
//				_task = new Sequence(_task);
//			}
//			Sequence(_task).add(getTask(task));
//			return this;
//		}
//
//		public function concurrent(task:Object):IAsyncFactory
//		{
//			if (!(_task is Concurrency))
//			{
//				_task = new Concurrency(_task);
//			}
//			Concurrency(_task).add(getTask(task));
//			return this;
//		}
//
//		public function ifThrows(value:Object = null):IAsyncThrowFactory
//		{
//			if (!(_task is Try))
//			{
//				_task = new Try(_task);
//			}
//			Try(_task).addCase(getCase(value, true));
//			return this;
//		}
//
//		public function ifReturns(value:Object):IAsyncReturnFactory
//		{
//			if (_task is Choice)
//			{
//				Choice(_task).addCase(getCase(value, false));
//			}
//			else
//			{
//				if (!(_task is Sequence))
//				{
//					_task = new Sequence(_task);
//				}
//				var task:Choice = new Choice();
//				task.addCase(getCase(value, false));
//				Sequence(_task).add(task);
//			}
//			return this;
//		}
//
//		public function then(task:Object):IAsyncOtherwiseFactory
//		{
//			if (_task is Try)
//			{
//				Try(_task).addTask(getTask(task));
//			}
//			else if (_task is Choice)
//			{
//				Choice(_task).addTask(getTask(task));
//			}
//			else
//			{
//				throw new IllegalOperationError("Invalid context for method Then.");
//			}
//			return this;
//		}
//
//		public function otherwise(task:Object):IAsyncSequenceFactory
//		{
//			if (_task is Try)
//			{
//				Try(_task).setDefault(getTask(task));
//			}
//			else if (_task is Choice)
//			{
//				Choice(_task).setDefault(getTask(task));
//			}
//			else
//			{
//				throw new IllegalOperationError("Invalid context for method Else.");
//			}
//			return this;
//		}
//
//		public function execute(data:Object = null, result:IResult = null):void
//		{
//			if (!_active)
//			{
//				if (_task)
//				{
//					_active = true;
//					_result = result;
//					_task.execute(data, this);
//				}
//				else if (result)
//				{
//					result.onReturn(data, this);
//				}
//			}
//		}
//
//		public function interrupt():void
//		{
//			if (_active)
//			{
//				_active = false;
//				_result = null;
//
//				var task:IAsync = _task;
//				_task = null;
//				task.interrupt();
//			}
//		}
//
//		public function onReturn(value:Object, target:IAsync):void
//		{
//			if (_active && target == _task)
//			{
//				_active = false;
//				_task = null;
//				if (_result)
//				{
//					var result:IResult = _result;
//					_result = null;
//					result.onReturn(value, this);
//				}
//			}
//		}
//
//		public function onThrow(error:Object, target:IAsync):void
//		{
//			if (_active && target == _task)
//			{
//				_active = false;
//				_task = null;
//				if (_result)
//				{
//					var result:IResult = _result;
//					_result = null;
//					result.onThrow(error, this);
//				}
//				else
//				{
//					throw error;
//				}
//			}
//		}
	}
}