package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsyncBaseFactory extends IAsync
	{
		function then(successTask:Object, failureTask:Object = null):IAsyncFactory;
	}
}