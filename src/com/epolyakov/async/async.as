package com.epolyakov.async
{
	/**
	 * @author epolyakov
	 */
	public function async(task:Object):IAsync
	{
		return new Sequence(task);
	}
}