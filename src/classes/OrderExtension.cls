// **************************************************************************************************
//  * Name: OrderExtension
//  * Object:
//  * Purpose: 获取订单信息的Extension
//  * Requirement:
//  * Author: luoxin
//  * Create Date: 2017-3-24
//  * Modify History:
// *****************************************************************************************************

global without sharing class OrderExtension {

    public String language {get; set;}

    public OrderExtension() {

    }

    @RemoteAction
    global static Object queryCustomerOrder(String customerCode, String orderStatus, String orderCode, String createdDate, String deliveryDate) {
        String str1 = SapQueryArgCreate.createSapCustomerOrderQueryArgs(customerCode, orderStatus, orderCode, HarryUtils.str2Date(createdDate), HarryUtils.str2Date(deliveryDate));
        System.debug(str1);
        String str2 = '';
        if (Test.isRunningTest()) {
            str2 = '{"status": "1",  "orders": [{"customer_contract_no__c": "1100071832", "order_code__c": "2100057336", "order_date__c": "2015-12-30", "order_status__c": "进行中", "total_amount__c": "4688.20 ", "currency__c": "CNY", "delivery_address__c": "合肥经济开发区繁华大道 199号 生命科技园内合肥博尔生物科技有限公司  王兵  13965055604",  "project_name__c": ""}]}';
        } else {
            str2 = Utils.postToSAP(str1);
        }
        return JSON.deserializeUntyped(str2);
    }
    @RemoteAction
    global static Object queryOderDetail(String orderId) {
        String str1 = SapQueryArgCreate.createSapOrderDetailQueryArgs(orderId);
        System.debug(str1);
        String str2 = '';
        if (Test.isRunningTest()) {
            str2 = '{"status": "1",  "orders": [{"customer_contract_no__c": "1100071832", "order_code__c": "2100057336", "order_date__c": "2015-12-30", "order_status__c": "进行中", "total_amount__c": "4688.20 ", "currency__c": "CNY", "delivery_address__c": "合肥经济开发区繁华大道 199号 生命科技园内合肥博尔生物科技有限公司  王兵  13965055604",   "orderitem": [{"order_code__c": "2100057336", "order_item_no__c": "000010", "material_number__c": "A5580001HG0000504T",  "description__c": "BPE无缝管12.7x1.65 6.1M 316L SF1固溶", "ordercount__c": "12.200 ", "has_delivery_quantity__c": "12.200 ", "not_delivery_quantity__c": "0.000 ", "stock_quantity__c": "2781.950 ", "unit__c": "M", "forecast_quantity__c": "0.000 ",  "logistics": [{"order_item_no__c": "000010", "logistic_company__c": "货运—百世",  "receive_address__c": "合肥经济开发区繁华大道 199号 生命科技园内合肥博尔生物科技有限公司  王兵  13965055604", "delivery_date__c": "2016-1-3"}]}, {"order_code__c": "2100057336", "order_item_no__c": "000020", "material_number__c": "A5514004HG0000504F",  "description__c": "BPE 14AMP-AWF接头 1/2\\" 44.45L 316L SF1", "ordercount__c": "30.000 ", "has_delivery_quantity__c": "30.000 ", "not_delivery_quantity__c": "0.000 ", "stock_quantity__c": "1120.000 ", "unit__c": "ST", "forecast_quantity__c": "0.000 ",  "logistics": [{"order_item_no__c": "000020", "logistic_company__c": "货运—百世",  "receive_address__c": "合肥经济开发区繁华大道 199号 生命科技园内合肥博尔生物科技有限公司  王兵  13965055604", "delivery_date__c": "2016-1-3"}]}, {"order_code__c": "2100057336", "order_item_no__c": "000030", "material_number__c": "A1513016CC0000251C",  "description__c": "13MHH 重型卡箍 1/2\\"-3/4\\" 304", "ordercount__c": "20.000 ", "has_delivery_quantity__c": "20.000 ", "not_delivery_quantity__c": "0.000 ", "stock_quantity__c": "2209.000 ", "unit__c": "ST", "forecast_quantity__c": "0.000 ",  "logistics": [{"order_item_no__c": "000030", "logistic_company__c": "货运—百世",  "receive_address__c": "合肥经济开发区繁华大道 199号 生命科技园内合肥博尔生物科技有限公司  王兵  13965055604", "delivery_date__c": "2016-1-3"}]}, {"order_code__c": "2100057336", "order_item_no__c": "000040", "material_number__c": "C1515001EP000050BL",  "description__c": "CLAMP GASKET 1/2\\" EPDM 黑色", "ordercount__c": "20.000 ", "has_delivery_quantity__c": "20.000 ", "not_delivery_quantity__c": "0.000 ", "stock_quantity__c": "2608.000 ", "unit__c": "ST", "forecast_quantity__c": "0.000 ",  "logistics": [{"order_item_no__c": "000040", "logistic_company__c": "货运—百世",  "receive_address__c": "合肥经济开发区繁华大道 199号 生命科技园内合肥博尔生物科技有限公司  王兵  13965055604", "delivery_date__c": "2016-1-3"}]}, {"order_code__c": "2100057336", "order_item_no__c": "000050", "material_number__c": "A1538100EP0001004R",  "description__c": "3A 视镜 25.4*1.6T 316LEPDM", "ordercount__c": "2.000 ", "has_delivery_quantity__c": "2.000 ", "not_delivery_quantity__c": "0.000 ", "stock_quantity__c": "10.000 ", "unit__c": "ST", "forecast_quantity__c": "0.000 ",  "logistics": [{"order_item_no__c": "000050", "logistic_company__c": "货运—百世",  "receive_address__c": "合肥经济开发区繁华大道 199号 生命科技园内合肥博尔生物科技有限公司  王兵  13965055604", "delivery_date__c": "2016-1-3"}]}], "invoiceinfo": [{"order_code__c": "2100057336", "order_item_no__c": "000010", "invoice_no__c": "8100067359", "total_amount__c": "          1629.69", "invoice_date__c": "2016-03-25"}, {"order_code__c": "2100057336", "order_item_no__c": "000020", "invoice_no__c": "8100067359", "total_amount__c": "          1591.17", "invoice_date__c": "2016-03-25"}, {"order_code__c": "2100057336", "order_item_no__c": "000030", "invoice_no__c": "8100067359", "total_amount__c": "           333.95", "invoice_date__c": "2016-03-25"}, {"order_code__c": "2100057336", "order_item_no__c": "000040", "invoice_no__c": "8100067359", "total_amount__c": "            58.86", "invoice_date__c": "2016-03-25"}, {"order_code__c": "2100057336", "order_item_no__c": "000050", "invoice_no__c": "8100067359", "total_amount__c": "          1074.53", "invoice_date__c": "2016-03-25"}, {"order_code__c": "2100057336", "order_item_no__c": "000050", "invoice_no__c": "9100339554", "total_amount__c": "          1074.53", "invoice_date__c": "2016-03-25"}, {"order_code__c": "2100057336", "order_item_no__c": "000040", "invoice_no__c": "9100339555", "total_amount__c": "            58.86", "invoice_date__c": "2016-03-25"}, {"order_code__c": "2100057336", "order_item_no__c": "000030", "invoice_no__c": "9100339553", "total_amount__c": "           333.95", "invoice_date__c": "2016-03-25"}, {"order_code__c": "2100057336", "order_item_no__c": "000020", "invoice_no__c": "9100339554", "total_amount__c": "          1591.17", "invoice_date__c": "2016-03-25"}, {"order_code__c": "2100057336", "order_item_no__c": "000010", "invoice_no__c": "9100339556", "total_amount__c": "          1629.69", "invoice_date__c": "2016-03-25"}, {"order_code__c": "2100057336", "order_item_no__c": "000050", "invoice_no__c": "9100323493", "total_amount__c": "          1074.53", "invoice_date__c": "2016-01-03"}, {"order_code__c": "2100057336", "order_item_no__c": "000040", "invoice_no__c": "9100323494", "total_amount__c": "            58.86", "invoice_date__c": "2016-01-03"}, {"order_code__c": "2100057336", "order_item_no__c": "000030", "invoice_no__c": "9100323492", "total_amount__c": "           333.95", "invoice_date__c": "2016-01-03"}, {"order_code__c": "2100057336", "order_item_no__c": "000020", "invoice_no__c": "9100323493", "total_amount__c": "          1591.17", "invoice_date__c": "2016-01-03"}, {"order_code__c": "2100057336", "order_item_no__c": "000010", "invoice_no__c": "9100323495", "total_amount__c": "          1629.69", "invoice_date__c": "2016-01-03"}]}]}';
        } else {
            str2 = Utils.postToSAP(str1);
        }
        return JSON.deserializeUntyped(str2);
    }
    @RemoteAction
    global static Object querySelfOrder(String usernameCode){
        String username = EncodingUtil.base64Decode(usernameCode).toString();
        System.debug(LoggingLevel.INFO, '*** username: ' + username);
        String str1 = SapQueryArgCreate.createSapCustomerContractMaterialArgs('0001009030');
        // String str1 = SapQueryArgCreate.createSapCustomerContractMaterialArgs(username);
        String str2 = Utils.postToSAP(str1);
        return JSON.deserializeUntyped(str2);
        // SapCustomerContractMaterial materials = (SapCustomerContractMaterial)JSON.deserialize(str2,SapCustomerContractMaterial.class);
    }
    @RemoteAction
    global static Object queryBill(String customercode, Boolean hasBeenInvoiced, Boolean notInvoiced, Boolean prepayment) {
        String str1 = SapQueryArgCreate.createSapCustomerBillingQueryArgs(customercode,hasBeenInvoiced,notInvoiced,prepayment);
        System.debug(LoggingLevel.INFO, '*** str1: ' + str1);
        String str2  = Utils.postToSAP(str1);
        return JSON.deserializeUntyped(str2);
    }
}