public class ApexParam1Controller{
  public String vfParam{get; set;}
  public ApexParam1Controller(ApexPages.StandardSetController controller){
    
  }
  public PageReference doActionSupport(){
    // Do Something...
    System.debug('vfParam : ' + vfParam);
    return null;
  }
}