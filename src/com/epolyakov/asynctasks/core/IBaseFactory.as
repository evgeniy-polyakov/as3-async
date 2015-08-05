package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	public interface IBaseFactory extends IAsync
	{
		function Next(task:Object):IAsyncFactory;

		function Catch(value:Object):ICatchFactory;

		function Case(value:Object):ICaseFactory;
	}
}