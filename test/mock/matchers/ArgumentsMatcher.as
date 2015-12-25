package mock.matchers
{
	import mock.IMatcher;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class ArgumentsMatcher implements IMatcher
	{
		private var _arguments:Vector.<IMatcher> = new <IMatcher>[];

		public function get arguments():Vector.<IMatcher>
		{
			return _arguments;
		}

		public function match(value:*):Boolean
		{
			if (value is Array && (value as Array).length == _arguments.length)
			{
				for (var i:int = 0, n:int = _arguments.length; i < n; i++)
				{
					if (!_arguments[i].match(value[i]))
					{
						return false;
					}
				}
				return true;
			}
			return false;
		}

		public function toString():String
		{
			return _arguments.join(",");
		}
	}
}
