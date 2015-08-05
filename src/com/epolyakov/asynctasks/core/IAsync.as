package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsync
	{
		function execute(data:Object = null, result:IResult = null):void;

		function interrupt():void;
	}
}