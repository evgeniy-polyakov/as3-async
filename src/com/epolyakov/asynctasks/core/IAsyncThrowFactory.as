package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IAsyncThrowFactory
	{
		function ifThrows(value:Object = null):IAsyncThrowFactory;

		function then(task:Object):IAsyncOtherwiseFactory;
	}
}