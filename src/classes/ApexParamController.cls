public class ApexParamController{
    public String vfParam{get; set;}
    public ApexParamController(){
        
    }
    public PageReference doActionFunction(){
        // Do Something...
        System.debug('vfParam : ' + vfParam);
        return null;
    }
}