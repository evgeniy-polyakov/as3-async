package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Switch extends Choice
	{
		public function Switch(c:Case)
		{
			super(c);
		}

		override protected function handleNoCases(data:Object, result:IResult):void
		{
			result.onReturn(data, this);
		}
	}
}