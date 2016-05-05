package com.epolyakov.async.tasks.mocks
{
	import com.epolyakov.async.Task;

	import flash.utils.setTimeout;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class SampleTaskExtension extends Task
	{
		private var _time:int;
		private var _arg:Object;
		private var _out:Object;

		public function SampleTaskExtension(time:int, arg:Object, out:Object)
		{
			_time = time;
			_arg = arg;
			_out = out;
		}

		override protected function onAwait():void
		{
			setTimeout(args == _arg ? onReturn : onThrow, _time, _out);
		}
	}
}
