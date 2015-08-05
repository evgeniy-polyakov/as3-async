package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IResult
	{
		function onReturn(value:Object, target:IAsync):void;

		function onThrow(error:Object, target:IAsync):void;
	}
}