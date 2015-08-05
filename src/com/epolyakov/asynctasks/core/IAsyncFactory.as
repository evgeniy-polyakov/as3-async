package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsyncFactory extends IBaseFactory
	{
		function concurrent(task:Object):IAsyncFactory;
	}
}