package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IThenFactory extends IBaseFactory
	{
		function Else(task:Object):IBaseFactory;
	}
}