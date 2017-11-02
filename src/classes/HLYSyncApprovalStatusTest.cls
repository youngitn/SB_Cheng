/**
* @author exia.huang
* @homepage http://salesforcexytools.com
*/
@isTest
private class HLYSyncApprovalStatusTest {

    /**
     * This is a test method for doPost
     */
    static testMethod void test_doPost() {


        Test.startTest();

        String action ='QUERY';
        String data_type ='APPROVAL';
        String begin_date ='2016-01-01';
        String end_date ='2017-10-21';
        String pagenum ='1';
        String pagesize ='10';
        String fetchall ='false';
        HLYSyncApprovalStatus.doPost(action , data_type , begin_date , end_date  , pagenum , pagesize , fetchall);
        pagenum='10';
        HLYSyncApprovalStatus.doPost(action , data_type , begin_date , end_date  , pagenum , pagesize , fetchall);

        Test.stopTest();
    }

}