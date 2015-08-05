package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsyncThrowFactory
	{
		function ifThrows(value:Object):IAsyncThrowFactory;

		function then(task:Object):IAsyncOtherwiseFactory;
	}
}