package com.epolyakov.mock
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface IVerify
	{
		function that(mock:*, times:* = 1):IVerifyActions;

		function total(times:*):void;
	}
}
