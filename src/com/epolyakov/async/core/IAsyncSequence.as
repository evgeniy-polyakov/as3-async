package com.epolyakov.async.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsyncSequence extends ITask
	{
		function then(task:Object, errorHandler:Object = null):IAsync;

		function hook(errorHandler:Object):IAsyncSequence;
	}
}