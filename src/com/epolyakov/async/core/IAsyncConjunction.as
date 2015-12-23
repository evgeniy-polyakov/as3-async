package com.epolyakov.async.core
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface IAsyncConjunction extends IAsyncSequence
	{
		function and(task:Object):IAsyncConjunction;
	}
}
