public class AddFieldsController 
{
    Account acc{get;set;}
 public AddFieldsController(ApexPages.StandardController stdCtrl)
 {
     
      if (!Test.isRunningTest())
     {
         stdCtrl.addFields(new List<String>{'Name'});
     }
     acc=(Account) stdCtrl.getRecord();
     acc.name = '7788';
     acc.BillingCity = '3333';
     System.debug(acc);
 }
}