package com.epolyakov.async.tasks.mocks
{
	import com.epolyakov.async.IResult;
	import com.epolyakov.async.ITask;
	import com.epolyakov.async.Task;

	import flash.utils.setTimeout;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class SampleITaskImplementation implements ITask
	{
		private var _time:int;
		private var _arg:Object;
		private var _out:Object;

		public function SampleITaskImplementation(time:int, arg:Object, out:Object)
		{
			_time = time;
			_arg = arg;
			_out = out;
		}

		public function await(args:Object = null, result:IResult = null):void
		{
			var t:Task = new Task(this);
			setTimeout(args == _arg ? t.onReturn : t.onThrow, _time, _out);
			t.await(args);
		}

		public function cancel():void
		{
		}
	}
}
