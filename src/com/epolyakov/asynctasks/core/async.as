package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public function async(task:Object):IAsync
	{
		return new Sequence(task);
	}
}