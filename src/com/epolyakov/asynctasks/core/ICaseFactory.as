package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface ICaseFactory
	{
		function ifReturns(value:Object):ICaseFactory;

		function then(task:Object):IThenFactory;
	}
}