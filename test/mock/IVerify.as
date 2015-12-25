package mock
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface IVerify
	{
		function that(methodCall:*, times:* = 1):IVerifyActions;
	}
}
