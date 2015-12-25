package mock
{
	import flash.utils.describeType;

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
			_arguments = arguments;
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
			var s:String = _object != null ? getObjectName() + "." : "";
			s += getMethodName();
			s += "(";
			s += (arguments || _arguments).toString();
			s += ")";
			return s;
		}

		private function getObjectName():String
		{
			if (_object != null)
			{
				var qName:String = describeType(_object).@name.toXMLString();
				var index:int = qName.indexOf("::");
				if (index >= 0)
				{
					return qName.substring(index + 2);
				}
				return qName;
			}
			return String(_method);
		}

		private function getMethodName():String
		{
			if (_object != null)
			{
				var xml:XML = describeType(_object);
				for each (var name:String in xml..method.@name)
				{
					if (_object[name] == _method)
					{
						return name;
					}
				}
			}
			if (_method != null)
			{
				var qName:String = describeType(_method).@name.toXMLString();
				var s:XML = describeType(_method);
				var index:int = qName.indexOf("::");
				if (index >= 0)
				{
					return qName.substring(index + 2);
				}
				return qName;
			}
			return "null";
		}
	}
}
