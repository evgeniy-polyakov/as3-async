package com.epolyakov.mock
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface IMatcher
	{
		function match(value:*):Boolean;
	}
}
