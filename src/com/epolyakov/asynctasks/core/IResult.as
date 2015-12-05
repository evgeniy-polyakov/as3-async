package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IResult
	{
		function onReturn(value:Object, target:ITask):void;

		function onThrow(error:Object, target:ITask):void;
	}
}