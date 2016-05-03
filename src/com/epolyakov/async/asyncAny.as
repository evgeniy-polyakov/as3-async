package com.epolyakov.async
{
	/**
	 * @author epolyakov
	 */
	public function asyncAny(task:Object, ...tasks):IAsyncDisjunction
	{
		var disjunction:Disjunction = new Disjunction(task);
		for each (var t:Object in tasks)
		{
			disjunction.or(t);
		}
		return disjunction;
	}
}