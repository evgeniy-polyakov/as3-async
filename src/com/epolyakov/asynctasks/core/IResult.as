package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IResult
	{
		function Return(value:Object, target:IAsync):void;

		function Throw(error:Object, target:IAsync):void;
	}
}