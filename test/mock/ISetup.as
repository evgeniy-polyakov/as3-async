package mock
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public interface ISetup
	{
		function that(methodCall:*):ISetupActions;
	}
}
