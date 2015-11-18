package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsyncFactory extends IAsyncBaseFactory
	{
		function and(task:Object, ...tasks):IAsyncFactory;
	}
}