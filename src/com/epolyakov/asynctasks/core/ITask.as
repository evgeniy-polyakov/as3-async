package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface ITask
	{
		function await(args:Object = null, result:IResult = null):void;

		function cancel():void;
	}
}