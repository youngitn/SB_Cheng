// **************************************************************************************************
//  * Name: LoginExtension
//  * Object:
//  * Purpose: 登录的后台Extension
//  * Requirement:
//  * Author: luoxin
//  * Create Date: 2017-3-24
//  * Modify History:
// *****************************************************************************************************
global without sharing class SiteSignInExtension {
    public static Boolean isRunTestMode = false;
    public String userName {Get; Set;}
    public String passWord {Get; Set;}

    public String language {Get; Set;}
    public String typeCV {Get; Set;}
    public String URL_Vendor {Get; Set;}
    public String URL_Customer {Get; Set;}

    public Integer lKey {Get; Set;}
    // public List<Account> accList {Get; Set;}
    public SiteSignInExtension() {
        Map<String,String> args = Apexpages.currentPage().getParameters();
        if(args.containsKey('language')){
            language = Apexpages.currentPage().getParameters().get('language');
        }else{
            language = 'zh_CN';
        }
        if(args.containsKey('typeCV')){
            typeCV = Apexpages.currentPage().getParameters().get('typeCV');
        }else{
            typeCV = 'customer';
        }
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        URL_Customer = ssc.URL_Customer__c;
        // URL_Customer = 'apex';
    }

    //更换ApexPage的语言设置
    public void changeLan() {
        System.debug(LoggingLevel.INFO, '*** language: ' + language);
    }

    //刷新页面更换语言
    public void refresh() {

    }
/*
    //登录方法 NO
    public PageReference login() {
        Map<String,String> args = Apexpages.currentPage().getParameters();
        if(args.containsKey('language')){
            language = Apexpages.currentPage().getParameters().get('language');
        }else{
            language = 'zh_CN';
        }
        if(args.containsKey('typeCV')){
            typeCV = Apexpages.currentPage().getParameters().get('typeCV');
        }else{
            typeCV = 'customer';
        }

        System.debug('*** 选择语言：' + language);
        System.debug('*** 门户网站类型：' + typeCV);

        try {
            // 打印快捷 dbi
            //判断用户名和密码是否为空
            if (userName == '' || passWord == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Alertmessage));
                return null;
            } else {
                        System.debug('*** 门户网站类型：' + typeCV); 
                        String rtName = 'Vendor';
                        if(typeCV == 'customer'){
                            rtName = 'Customer';
                        }

                //检查客户门户是否开通


                       
                //查询客户中是否存在该用户名和密码的客户，
                accList = [SELECT SAPID__c,AccountNumber,Customer_Number__c,customer_password__c
                           FROM Account
                           WHERE (SAPID__c = :userName OR AccountNumber =:userName OR Customer_Number__c =:userName) 
                           AND customer_password__c = :passWord 
                           AND RecordType.DeveloperName =: rtName];
                //不为空表示用户名和密码正确
                if (!accList.isEmpty()) {
                     System.debug('*** 用户信息：' + JSON.serializePretty(accList[0]));
                    // 将用户名加密,存入Cookie
                    // Blob cipherText=Blob.valueOf(userName);
                    // String encodedCipherText = EncodingUtil.base64Encode(cipherText);
                    Cookie un = new Cookie('apex__un', userName, null, 7200, false);
                    System.debug(LoggingLevel.INFO, '*** un.getValue(): ' + un.getValue());
                    Cookie pw = new Cookie('apex__pw', passWord, null, 7200, false);
                    ApexPages.currentPage().setCookies(new Cookie[] {un,pw});
                    PageReference page = null;
                    if(typeCV == 'customer'){
                        page = new PageReference(URL_Customer + '/sitemain');
                    }else if(typeCV == 'vendor'){
                        page = new PageReference(URL_Customer + '/SiteMainVendor');
                    }
                    page.setCookies(new Cookie[] {un,pw});
                    page.getParameters().put('language', language);
                    page.setRedirect(true);
                    return page;
                }
                //为空提示错误信息，用户名或密码错误！
                else {
                    System.debug('*** 用户名或密码错误');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ErrorMessage1));
                    return null;
                }
            }
        } catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    */
    @RemoteAction
    global static Boolean signin(String username, String password,String rtName) {
        System.debug('*** 用户名：' + username);
        System.debug('*** 密码：' + password);
        System.debug('*** 类型：' + rtName);
       
        //查询客户门户权限开通
        if (rtName == 'Customer') {
            String strjosn = '{"approval":"CUSTOMERPORTAL","account_id":"'+username+'"}';
            String str = '';
            if (!isRunTestMode) {
                 str =  Utils.postToSAP(strjosn);
            }
            if (str == 'false') {
                return false;
            }
        }
       
       
        List<Account> accList = [
                SELECT SAPID__c, customer_password__c 
                FROM Account 
                WHERE (SAPID__c = :userName OR Vendor_Number__c = :userName OR Customer_Number__c = :userName) 
                AND customer_password__c = :passWord
                AND RecordType.DeveloperName = :rtName];
        if(accList.size() > 0){
            return true;
        }else{
            return false;
        }
    }


}