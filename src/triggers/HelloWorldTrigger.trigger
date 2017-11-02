trigger HelloWorldTrigger on Book__c (before insert) {
    Book__c[] books = Trigger.new; 
    MyHelloWorld my = new MyHelloWorld();
    my.applyDiscount(books);
}