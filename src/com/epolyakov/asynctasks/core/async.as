package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public function async(task:Object):IAsyncFactory
	{
		return new AsyncFactory(task);
	}
}