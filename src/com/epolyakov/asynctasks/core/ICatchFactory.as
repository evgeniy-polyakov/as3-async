package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface ICatchFactory
	{
		function Catch(value:Object):ICatchFactory;

		function Then(task:Object):IThenFactory;
	}
}