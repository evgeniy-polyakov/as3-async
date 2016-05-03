package com.epolyakov.async
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface IAsyncDisjunction extends ITask
	{
		function or(task:Object):IAsyncDisjunction;
	}
}
