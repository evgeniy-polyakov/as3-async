package mock
{
	/**
	 * @author Evgeniy Polyakov
	 */
	public function invoke(object:Object, method:Function, ...args):*
	{
		return It.invoke(object, method, args);
	}
}
