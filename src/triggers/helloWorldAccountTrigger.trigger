trigger helloWorldAccountTrigger on Account (before insert) {
    MyHelloWorldIde.addHelloWorld(Trigger.new);
}