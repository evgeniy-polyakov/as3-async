package com.epolyakov.asynctasks.core
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface IAsyncDisjunction extends IAsyncSequence
	{
		function or(task:Object):IAsyncDisjunction;
	}
}
