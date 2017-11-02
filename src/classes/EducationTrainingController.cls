public class EducationTrainingController {
    //基本上{Get; Set;}要有
    public String s1 {Get; Set;}
    public String check {Get; Set;}
	public String msg {Get; Set;}     
    //目前只知道初值要在constructor給
    public EducationTrainingController(){
        s1 = 'OHOHOHO';
        check = 'no change';
        
    }
    
    //要給view呼叫的話,
    public String testz(){
        return 'OHOHOHO';
    }
    public void myMethod(){
        //Fetch the value of parameter you are sending from the page,
        check = Apexpages.currentPage().getParameters().get('paramValue');
        }
     public string getHello(String x) { 
        return x.substring(3);
    }
    @RemoteAction
	public static String getItemId(String objectName) { 
        return  objectName;
            }
    @RemoteAction
    public static String addBook(String bookName, Double bookPrice) { 
        Book__c book = new Book__c();
        
        try{
            book.Name = bookName;
            book.Price__c = bookPrice;
            insert book;
        }catch(exception e){
            apexpages.addmessages(e);
        }
        return 'add '+book.Name+'   book.Price='+book.Price__c;
    }
     public PageReference myActionInController()
    {
        msg = 'success!!';
        return null ;
    }
}