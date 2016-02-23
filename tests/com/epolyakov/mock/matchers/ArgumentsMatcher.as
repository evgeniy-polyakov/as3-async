package com.epolyakov.mock.matchers
{
	import com.epolyakov.mock.IMatcher;
	import com.epolyakov.mock.SetupError;
	import com.epolyakov.mock.Utils;

	/**
	 * @author Evgeniy Polyakov
	 */
	public class ArgumentsMatcher implements IMatcher
	{
		private var _matchers:Vector.<IMatcher> = new <IMatcher>[];

		public function add(matcher:IMatcher):void
		{
			_matchers.push(matcher);
		}

		public function complete(arguments:Array):void
		{
			var matchers:Vector.<IMatcher> = new Vector.<IMatcher>(arguments.length);
			var defaultArgumentsLength:int = 0;
			for (var i:int = 0, j:int = 0; i < arguments.length; i++)
			{
				var arg:* = arguments[i];
				// Default values for all possible types
				if (arg === undefined
						|| arg === null
						|| (arg is int && arg === 0)
						|| (arg is Number && isNaN(arg))
						|| (arg is Boolean && arg === false))
				{
					defaultArgumentsLength++;
					if (_matchers.length > j)
					{
						matchers[i] = _matchers[j];
						j++;
					}
					else
					{
						matchers[i] = new IsEqualMatcher(arg);
					}
				}
				else
				{
					matchers[i] = new IsEqualMatcher(arg);
				}
			}
			if (_matchers.length > 0 && defaultArgumentsLength != _matchers.length)
			{
				throw new SetupError("Arguments mismatch: " +
						"expected (" + _matchers.join(",") + ") " +
						"but got (" + Utils.arrayToString(arguments) + ").");
			}
			_matchers = matchers;
		}

		public function match(value:*):Boolean
		{
			if (value is Array && (value as Array).length == _matchers.length)
			{
				for (var i:int = 0, n:int = _matchers.length; i < n; i++)
				{
					if (!_matchers[i].match(value[i]))
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
			return _matchers.join(",");
		}
	}
}
