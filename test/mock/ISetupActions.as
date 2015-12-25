package mock
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface ISetupActions
	{
		function returns(value:*):void;

		function throws(value:*):void;
	}
}
