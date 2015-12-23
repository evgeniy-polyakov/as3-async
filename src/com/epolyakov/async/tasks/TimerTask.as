package com.epolyakov.async.tasks
{
	import com.epolyakov.async.core.Task;

	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * @author Evgeniy S. Polyakov
	 */
	public class TimerTask extends Task
	{
		private var _timeoutId:uint;
		private var _delay:int;

		public function TimerTask(delay:int = 0)
		{
			_delay = delay;
		}

		override protected function onAwait():void
		{
			if (_delay > 0)
			{
				_timeoutId = setTimeout(onTimeout, _delay)
			}
			else
			{
				onReturn(data);
			}
		}

		override protected function onCancel():void
		{
			clearTimeout(_timeoutId);
		}

		private function onTimeout():void
		{
			clearTimeout(_timeoutId);
			onReturn(data);
		}
	}
}