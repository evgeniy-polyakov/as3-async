package com.epolyakov.async.core
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface IAsyncDisjunction extends IAsyncSequence
	{
		function or(task:Object):IAsyncDisjunction;
	}
}
