package com.epolyakov.asynctasks.core
{
	/**
	 * @author Evgeniy Polyakov
	 */
	internal class Null implements IAsync
	{
		public function execute(data:Object = null, result:IResult = null):void
		{
			if (result)
			{
				result.onReturn(data, this);
			}
		}

		public function interrupt():void
		{
		}
	}
}
