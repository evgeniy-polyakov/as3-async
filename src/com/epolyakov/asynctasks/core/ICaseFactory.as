package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface ICaseFactory
	{
		function Case(value:Object):ICaseFactory;

		function Then(task:Object):IThenFactory;
	}
}