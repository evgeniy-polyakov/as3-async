package com.epolyakov.async.core
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