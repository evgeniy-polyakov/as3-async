package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IThenFactory extends IBaseFactory
	{
		function otherwise(task:Object):IBaseFactory;
	}
}