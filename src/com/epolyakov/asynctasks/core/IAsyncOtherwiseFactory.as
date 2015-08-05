package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsyncOtherwiseFactory extends IAsyncSequenceFactory
	{
		function otherwise(task:Object):IAsyncSequenceFactory;
	}
}