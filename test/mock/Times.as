package mock
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public class Times
	{
		private static var _never:Times = new Times(0, 0);
		private static var _once:Times = new Times(1, 1);
		private static var _twice:Times = new Times(2, 2);
		private static var _thrice:Times = new Times(3, 3);

		public static function get never():Times
		{
			return _never;
		}

		public static function get once():Times
		{
			return _once;
		}

		public static function get twice():Times
		{
			return _twice;
		}

		public static function get thrice():Times
		{
			return _thrice;
		}

		public static function exactly(value:int):Times
		{
			return new Times(value, value);
		}

		public static function atLeast(value:int):Times
		{
			return new Times(value, int.MAX_VALUE);
		}

		public static function atMost(value:int):Times
		{
			return new Times(0, value);
		}

		public static function moreThan(value:int):Times
		{
			return new Times(value + 1, int.MAX_VALUE);
		}

		public static function lessThan(value:int):Times
		{
			return new Times(0, value - 1);
		}

		private var _min:int;
		private var _max:int;

		public function Times(min:int, max:int)
		{
			_min = min;
			_max = max;
		}

		internal function match(value:int):Boolean
		{
			return value >= _min && value <= _max;
		}

		public function toString():String
		{
			if (_min <= 0 && _max <= 0 || _min > _max)
			{
				return "never";
			}
			if (_min == _max)
			{
				return times(_min);
			}
			if (_min <= 0)
			{
				return "at most " + times(_max);
			}
			if (_max == int.MAX_VALUE)
			{
				return "at least " + times(_min);
			}
			return "from " + _min + " to " + _max + " times";
		}

		private static function times(value:int):String
		{
			return value <= 0 ? "never" : value == 1 ? "once" : value + " times";
		}
	}
}
