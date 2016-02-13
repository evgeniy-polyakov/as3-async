package com.epolyakov.async.core
{
	/**
	 * @author epolyakov
	 */
	public class Task extends Launcher implements ITask
	{
		private var _args:Object;
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

		final public function get args():Object
		{
			return _args;
		}

		final public function await(args:Object = null, result:IResult = null):void
		{
			if (!_active)
			{
				_active = true;
				_result = result;
				_args = args;
				if (_target == null)
				{
					try
					{
						onAwait();
					}
					catch (error:*)
					{
						onThrow(error);
					}
				}
				else
				{
					launch(_target, args);
				}
			}
		}

		final public function cancel():void
		{
			if (_active)
			{
				_active = false;
				_result = null;
				_args = null;
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

		final override public function onReturn(value:Object, target:ITask = null):void
		{
			if (_active)
			{
				super.onReturn(value, target);

				_active = false;
				_args = null;
				if (_result)
				{
					var result:IResult = _result;
					_result = null;
					result.onReturn(value, target || this);
				}
			}
		}

		final override public function onThrow(error:Object, target:ITask = null):void
		{
			if (_active)
			{
				super.onThrow(error, target);

				_active = false;
				_args = null;
				if (_result)
				{
					var result:IResult = _result;
					_result = null;
					result.onThrow(error, target || this);
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