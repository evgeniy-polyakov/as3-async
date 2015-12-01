package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IResult
	{
		function onReturn(value:Object, target:IAwaitable):void;

		function onThrow(error:Object, target:IAwaitable):void;
	}
}