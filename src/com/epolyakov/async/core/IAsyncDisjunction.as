package com.epolyakov.async.core
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface IAsyncDisjunction extends ITask
	{
		function or(task:Object):IAsyncDisjunction;
	}
}
