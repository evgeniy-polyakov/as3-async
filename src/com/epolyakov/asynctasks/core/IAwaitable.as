package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAwaitable
	{
		function await(data:Object = null, result:IResult = null):ICancelable;
	}
}