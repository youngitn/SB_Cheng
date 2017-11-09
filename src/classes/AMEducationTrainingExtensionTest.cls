@isTest(SeeAllData=true)
private class AMEducationTrainingExtensionTest
{

    static void test_method_one()
    {
        // Implement test code
        
    }

    static testMethod void testSave()
    {
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = :SapApprovalEnum.EDUCATIONTRAININGREQUEST];
        Contact con = new Contact(LastName = '测试人员', number__c = '123');

        insert con;
        Contact con2 = new Contact(LastName = 'bbb', number__c = '333');
        insert con2;

        Contact con3 = new Contact(LastName = 'aaa', number__c = '30210378');
        insert con3;

        Approval_Managed1__c am = new Approval_Managed1__c();
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        am.EducationTrainingTime__c = Datetime.now();
        am.EducationTrainingHours__c = '8';
        AMEducationTrainingExtension.Participant px = new AMEducationTrainingExtension.Participant();
        AMEducationTrainingExtension extension = new AMEducationTrainingExtension(new ApexPages.StandardController(am));
        //click add Participant
        extension.addParticipant();

        //get value from VF
        PageReference pageRef = Page.AMEducationTraining;
        pageRef.getParameters().put('inputType', 'empid');
        pageRef.getParameters().put('inputValue', '30210378');
        pageRef.getParameters().put('rowId', '1');
        Test.setCurrentPage(pageRef);
        extension.PutValue();

        extension.deleteRow();
        extension.addParticipant();
        pageRef.getParameters().put('inputType', 'empid');
        pageRef.getParameters().put('inputValue', '311111');
        pageRef.getParameters().put('rowId', '1');
        Test.setCurrentPage(pageRef);
        extension.PutValue();
        extension.deleteRow();

        extension.addParticipant();
        pageRef.getParameters().put('inputType', 'name');
        pageRef.getParameters().put('inputValue', '30210378');
        pageRef.getParameters().put('rowId', '1');
        Test.setCurrentPage(pageRef);
        extension.PutValue();

        PageReference page = extension.save();
        System.debug(LoggingLevel.INFO, '*** page: ' + page);
        System.assertEquals('/' + am.Id, page.getUrl());
        am.ExternalEducationTrainingFee__c = '20';
        update am;
        Test.stopTest();

    }
    static testMethod void testCancel()
    {
        Test.startTest();
        Approval_Managed1__c am = new Approval_Managed1__c();
        AMEducationTrainingExtension extension = new AMEducationTrainingExtension(new ApexPages.StandardController(am));

        extension.cancel();
        Test.stopTest();
    }




}