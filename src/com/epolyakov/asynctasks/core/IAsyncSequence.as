package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsyncSequence extends IAwaitable
	{
		function then(task:Object):IAsync;

		function hook(task:Object):IAsyncSequence;

		function fork(successTask:Object, failureTask:Object):IAsyncSequence;
	}
}