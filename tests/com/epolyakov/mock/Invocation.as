package com.epolyakov.mock
{
	/**
	 * @author Evgeniy Polyakov
	 */
	internal class Invocation
	{
		private var _object:Object;
		private var _method:Function;
		private var _arguments:Array;

		public function Invocation(object:Object, method:Function, arguments:Array)
		{
			_object = object;
			_method = method;
			_arguments = arguments || [];
		}

		internal function get object():Object
		{
			return _object;
		}

		internal function get method():Function
		{
			return _method;
		}

		internal function get arguments():Array
		{
			return _arguments;
		}

		public function toString(arguments:Object = null):String
		{
			var s:String = _object != null ? Utils.objectToClassName(_object) + "." : "";
			s += Utils.functionToMethodName(_method, _object);
			s += "(" + (arguments ? arguments.toString() : Utils.arrayToString(_arguments)) + ")";
			return s;
		}
	}
}
