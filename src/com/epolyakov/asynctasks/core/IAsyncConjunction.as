package com.epolyakov.asynctasks.core
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface IAsyncConjunction extends IAsyncSequence
	{
		function and(task:Object):IAsyncConjunction;
	}
}
