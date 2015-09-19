package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class Catch extends Choice
	{
		public function Catch(c:Case)
		{
			super(c);
		}

		override protected function handleNoCases(data:Object, result:IResult):void
		{
			result.onThrow(data, this);
		}
	}
}