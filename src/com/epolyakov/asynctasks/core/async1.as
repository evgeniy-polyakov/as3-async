package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public function async1(task:Object):IAsyncFactory
	{
		return new AsyncFactory(task);
	}
}