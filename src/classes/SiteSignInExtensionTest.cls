/**
* @author exia.huang
* @homepage http://salesforcexytools.com
*/
@isTest
private class SiteSignInExtensionTest {

    /**
     * This is a test method for changeLan
     */
    static testMethod void test_changeLan() {

        // PageReference pageRef = Page.undefined;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');
   
        Test.startTest();
        System_Setting__c ss = new System_Setting__c();
        ss.Name = 'Setting';
        ss.URL_Customer__c = 'testURL';
        INSERT ss;
         SiteSignInExtension obj = new SiteSignInExtension();
         obj.userName = 'testName';
         obj.passWord = 'testPass';
         obj.language = 'zh_CN';
         obj.lKey = 1;

         obj.URL_Vendor = 'testURL';
         obj.changeLan();

        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for refresh
     */
    static testMethod void test_refresh() {

        // PageReference pageRef = Page.undefined;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

          // SiteSignInExtension obj = new SiteSignInExtension();
          // obj.refresh();

        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for login
     */
    static testMethod void test_signin() {

        // PageReference pageRef = Page.undefined;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();
         // String str1 = '0002000008';
         // String str2 = '123';
         // String str3 = 'Customer';
        Account account = new Account();
        account.Name = '0002000008';
        account.SAPID__c = '0002000008';
        account.Customer_Password__c = '123';
        RecordType ss = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND DeveloperName = 'Customer'];
        account.RecordTypeId = ss.Id;
        INSERT account;
        SiteSignInExtension.isRunTestMode = true;
         //SiteSignInExtension obj = new SiteSignInExtension();
        SiteSignInExtension.signin('0002000008', '123', 'Customer');
 
        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }

}