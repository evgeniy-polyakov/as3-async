package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsyncReturnFactory
	{
		function ifReturns(value:Object):IAsyncReturnFactory;

		function then(task:Object):IAsyncOtherwiseFactory;
	}
}