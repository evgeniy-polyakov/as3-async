package mock
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface IVerify
	{
		function that(methodCall:*, times:Times = null):IVerifyActions;
	}
}
