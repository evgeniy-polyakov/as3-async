package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public class Task implements IAsync
	{
		private var _data:Object;
		private var _target:IAsync;
		private var _active:Boolean;
		private var _result:IResult;

		public function Task(target:IAsync = null)
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
		final public function Await(data:Object = null, result:IResult = null):void
		{
			if (!_active)
			{
				_active = true;
				_result = result;
				_data = data;
				if (_target == null)
				{
					execute();
				}
			}
		}

		/**
		 * @inheritDoc
		 */
		final public function Break():void
		{
			if (_active)
			{
				_active = false;
				_result = null;
				_data = null;
				if (_target == null)
				{
					interrupt();
				}
			}
		}

		final public function Return(value:Object):void
		{
			if (_active)
			{
				_active = false;
				if (_result)
				{
					var result:IResult = _result;
					_result = null;
					_data = null;
					result.Return(value, _target != null ? _target : this);
				}
			}
		}

		final public function Throw(error:Object):void
		{
			if (_active)
			{
				_active = false;
				if (_result)
				{
					var result:IResult = _result;
					_result = null;
					_data = null;
					result.Throw(error, _target != null ? _target : this);
				}
				else
				{
					throw error;
				}
			}
		}

		protected function execute():void
		{
		}


		protected function interrupt():void
		{
		}
	}
}