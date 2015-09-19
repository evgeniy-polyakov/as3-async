package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsyncSequenceFactory extends IAsync
	{
		function next(task:Object):IAsyncFactory;

		function ifThrows(value:Object = null):IAsyncThrowFactory;

		function ifReturns(value:Object):IAsyncReturnFactory;
	}
}