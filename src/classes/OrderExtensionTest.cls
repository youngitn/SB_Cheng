/**
* @author exia.huang
* @homepage http://salesforcexytools.com
*/
@isTest(SeeAllData=true)
private class OrderExtensionTest {

    /**
     * This is a test method for queryCustomerOrder
     */
    static testMethod void test_queryCustomerOrder() {

        Test.startTest();

        String customerCode = '2100057336';
        String orderStatus = '';
        String orderCode = '';
        String createdDate = '';
        String deliveryDate = '';
        Object result_queryCustomerOrder = OrderExtension.queryCustomerOrder(customerCode , orderStatus , orderCode , createdDate , deliveryDate);

        Test.stopTest();

    }


    /**
     * This is a test method for queryOderDetail
     */
    static testMethod void test_queryOderDetail() {

        // PageReference pageRef = Page.MyOrderPage;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('id', '2100057336');

        Test.startTest();

        String orderId = '2100057336';
        Object result_queryOderDetail = OrderExtension.queryOderDetail(orderId);

        Test.stopTest();

    }

}