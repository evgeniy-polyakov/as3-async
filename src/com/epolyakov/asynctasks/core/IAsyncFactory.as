package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsyncFactory extends IBaseFactory
	{
		function Concurrent(task:Object):IAsyncFactory;
	}
}