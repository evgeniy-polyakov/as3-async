package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface ICatchFactory
	{
		function ifThrows(value:Object):ICatchFactory;

		function then(task:Object):IThenFactory;
	}
}