package com.epolyakov.async.core
{
	import flash.events.ErrorEvent;

	/**
	 * @author Evgeniy Polyakov
	 */
	internal class Launcher implements IResult
	{
		private var _callback:Boolean;

		internal final function launch(task:ITask, args:Object):void
		{
			if (task is IReliable)
			{
				task.await(args, this);
			}
			else
			{
				_callback = false;
				try
				{
					task.await(args, this);
				}
				catch (error:*)
				{
					if (_callback)
					{
						throw error;
					}
					else
					{
						onThrow(error, task);
					}
				}
			}
		}

		public function onReturn(value:Object, target:ITask = null):void
		{
			_callback = true;
		}

		public function onThrow(error:Object, target:ITask = null):void
		{
			_callback = true;
		}

		internal final function toTask(value:Object):ITask
		{
			if (value is ITask)
			{
				return value as ITask;
			}
			if (value is Function)
			{
				return new Func(value as Function);
			}
			if (value is Error || value is ErrorEvent)
			{
				return new Throw(value);
			}
			return new Return(value);
		}
	}
}
