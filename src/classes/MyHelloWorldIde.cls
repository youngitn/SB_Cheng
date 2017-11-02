public class MyHelloWorldIde {
    public static void addHelloWorld(Account[] accs){
	for (Account a:accs){
		if (a.Description != 'Hello World')
		a.Description = 'Hello World';
		System.debug(a.Description);
		}
	}
}