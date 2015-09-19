package com.epolyakov.asynctasks.core
{
	/**
	 * @author epolyakov
	 */
	internal class CaseAny extends Case
	{
		override public function accept(value:Object):Boolean
		{
			return true;
		}
	}
}