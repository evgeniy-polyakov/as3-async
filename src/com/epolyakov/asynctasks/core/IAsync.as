package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsync
	{
		function Await(data:Object = null, result:IResult = null):void;

		function Break():void;
	}
}