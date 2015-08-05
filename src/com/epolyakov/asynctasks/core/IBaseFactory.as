package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IBaseFactory extends IAsync
	{
		function next(task:Object):IAsyncFactory;

		function ifThrows(value:Object):ICatchFactory;

		function ifReturns(value:Object):ICaseFactory;
	}
}