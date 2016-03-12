package com.epolyakov.async.core
{
	/**
	 * @author epolyakov
	 */
	public function asyncAll(task:Object, ...tasks):IAsyncConjunction
	{
		var conjunction:Conjunction = new Conjunction(task);
		for each (var t:Object in tasks)
		{
			conjunction.and(t);
		}
		return conjunction;
	}
}