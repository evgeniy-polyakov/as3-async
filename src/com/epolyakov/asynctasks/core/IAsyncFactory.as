package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsyncFactory extends IAsyncSequenceFactory
	{
		function concurrent(task:Object):IAsyncFactory;
	}
}