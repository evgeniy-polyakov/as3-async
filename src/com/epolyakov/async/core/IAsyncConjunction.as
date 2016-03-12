package com.epolyakov.async.core
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface IAsyncConjunction extends ITask
	{
		function and(task:Object):IAsyncConjunction;
	}
}
