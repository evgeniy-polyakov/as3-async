package com.epolyakov.async.tasks
{
	import com.epolyakov.async.core.Task;

	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * @author Evgeniy S. Polyakov
	 */
	public class TimeoutTask extends Task
	{
		private var _timeoutId:uint;
		private var _milliseconds:int;

		public function TimeoutTask(milliseconds:int = 0)
		{
			_milliseconds = milliseconds;
		}

		override protected function onAwait():void
		{
			if (_milliseconds > 0)
			{
				_timeoutId = setTimeout(onTimeout, _milliseconds)
			}
			else
			{
				onReturn(args);
			}
		}

		override protected function onCancel():void
		{
			clearTimeout(_timeoutId);
		}

		private function onTimeout():void
		{
			clearTimeout(_timeoutId);
			onReturn(args);
		}
	}
}