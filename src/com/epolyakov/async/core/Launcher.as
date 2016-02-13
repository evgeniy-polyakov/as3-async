package com.epolyakov.async.core
{
	/**
	 * @author Evgeniy Polyakov
	 */
	internal class Launcher implements IResult
	{
		private var _callback:Boolean;

		internal function launch(task:ITask, args:Object):void
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
	}
}
