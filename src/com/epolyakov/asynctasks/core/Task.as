package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public class Task implements ITask
	{
		private var _data:Object;
		private var _target:ITask;
		private var _active:Boolean;
		private var _result:IResult;

		public function Task(target:ITask = null)
		{
			_target = target;
		}

		final public function get active():Boolean
		{
			return _active;
		}

		final public function get data():Object
		{
			return _data;
		}

		/**
		 * @inheritDoc
		 */
		final public function await(data:Object = null, result:IResult = null):void
		{
			if (!_active)
			{
				_active = true;
				_result = result;
				_data = data;
				if (_target == null)
				{
					onAwait();
				}
				else if (_target is IAsyncSequence)
				{
					(_target as IAsyncSequence).fork(onReturn, onThrow).await(data);
				}
				else
				{
					async(_target).fork(onReturn, onThrow).await(data);
				}
			}
		}

		/**
		 * @inheritDoc
		 */
		final public function cancel():void
		{
			if (_active)
			{
				_active = false;
				_result = null;
				_data = null;
				if (_target == null)
				{
					onCancel();
				}
				else
				{
					_target.cancel();
				}
			}
		}

		final protected function onReturn(value:Object):void
		{
			if (_active)
			{
				_active = false;
				_data = null;
				if (_result)
				{
					var result:IResult = _result;
					_result = null;
					result.onReturn(value, this);
				}
			}
		}

		final protected function onThrow(error:Object):void
		{
			if (_active)
			{
				_active = false;
				_data = null;
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

		protected function onAwait():void
		{
		}


		protected function onCancel():void
		{
		}
	}
}