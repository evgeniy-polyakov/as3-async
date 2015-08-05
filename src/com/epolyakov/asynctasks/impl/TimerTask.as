package com.epolyakov.asynctasks.impl
{
	import com.epolyakov.asynctasks.core.Task;

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

		override protected function execute():void
		{
			if (_delay > 0)
			{
				_timeoutId = setTimeout(onTimeout, _delay)
			}
			else
			{
				Return(data);
			}
		}

		override protected function interrupt():void
		{
			clearTimeout(_timeoutId);
		}

		private function onTimeout():void
		{
			clearTimeout(_timeoutId);
			Return(data);
		}
	}
}