package com.epolyakov.async.core
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public class Cache
	{
		private static var _instances:Vector.<ITask> = new <ITask>[];

		internal static function get instances():Vector.<ITask>
		{
			return _instances;
		}

		internal static function add(instance:ITask):void
		{
			if (_instances.indexOf(instance) < 0)
			{
				_instances.push(instance);
			}
		}

		internal static function remove(instance:ITask):void
		{
			var index:int = _instances.indexOf(instance);
			if (index >= 0)
			{
				_instances.splice(index, 1);
			}
		}

		public static function clear():void
		{
			var n:int = _instances.length;
			if (n > 0)
			{
				_instances.splice(0, n);
			}
		}

		public static function get length():int
		{
			return _instances.length;
		}
	}
}
