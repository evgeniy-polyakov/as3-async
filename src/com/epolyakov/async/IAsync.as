package com.epolyakov.async
{
	/**
	 * @author epolyakov
	 */
	public interface IAsync extends ITask
	{
		function then(task:Object, onError:Object = null):IAsync;

		function except(task:Object):IAsync;
	}
}