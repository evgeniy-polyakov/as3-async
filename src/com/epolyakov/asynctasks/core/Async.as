package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public function Async(task:Object):IAsyncFactory
	{
		return new AsyncFactory(task);
	}
}