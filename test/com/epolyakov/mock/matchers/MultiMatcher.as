package com.epolyakov.mock.matchers
{
	/**
	 * @author Evgeniy Polyakov
	 */
	internal class MultiMatcher
	{
		private var _name:String;
		protected var _values:Array;

		public function MultiMatcher(name:String, value:*, values:Array)
		{
			_name = name;
			if (values != null)
			{
				values.unshift(value);
				_values = values;
			}
			else
			{
				_values = [value];
			}
		}

		public function toString():String
		{
			return _name + "(" + _values.map(function (v:*, ...rest):String
					{
						return v == null ? "null" : v.toString();
					}) + ")";
		}
	}
}
