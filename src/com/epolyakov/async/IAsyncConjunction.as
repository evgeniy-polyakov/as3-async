package com.epolyakov.async
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface IAsyncConjunction extends ITask
	{
		function and(task:Object):IAsyncConjunction;
	}
}
