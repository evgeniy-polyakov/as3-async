package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsyncFactory extends IAsyncBaseFactory
	{
		function concurrent(task:Object):IAsyncFactory;

		function fail(task:Object):IAsyncBaseFactory;
	}
}