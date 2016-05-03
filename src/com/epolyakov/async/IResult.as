package com.epolyakov.async
{
	/**
	 * @author epolyakov
	 */
	public interface IResult
	{
		function onReturn(value:Object, target:ITask = null):void;

		function onThrow(error:Object, target:ITask = null):void;
	}
}