package com.epolyakov.async.core
{
	/**
	 * @author epolyakov
	 */
	public function async(task:Object):IAsync
	{
		return new Sequence(task);
	}
}