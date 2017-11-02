/**********************************************************************
 名    称：教育訓練申請流程
 目    的：指定流程關卡簽核人
 作    者：Young
 创建日期：2017-10-24
 修 改 人：
 修改日期：
 修改原因：
 备    注：

            节点1   申請人單位主管             Related User: *审批用户1：Approval_User1__c
            节点2   人力資源課承辦人（梁惠雯）   Related User: *审批用户2：Approval_User2__c
            节点3   人力資源課（高慧珠）        Related User: *审批用户3：Approval_User3__c
            节点4   管理部（高慧珠）              Related User: *审批用户4：Approval_User4__c
            节点5   總經理核示（李柏樺）        Related User: *审批用户5：Approval_User5__c
 **********************************************************************/
public without sharing class AMEducationTrainingHandler implements Triggers.Handler {
    public void handle() {
        //获取教育訓練申請流程各节点配置
        System.debug('!!!!!inAMEducationTrainingHandler');
        Map<Decimal, Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EDUCATIONTRAININGREQUEST, 'Approval_Managed1__c');
        System.debug('!!!!!get rtid ='+rtId);
        System.debug('Trigger.isBefore && Trigger.isInsert='+Trigger.isBefore+ '&&'+ Trigger.isInsert);
        
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    System.debug('!!!!!in cam.RecordTypeId == rtId');
                    if (mapSpecify == null) {
                        //這裡的step來源是[流程配置] 不是Approval Processes
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.EDUCATIONTRAININGREQUEST);
                    }
                    setApprovalUser(mapSpecify, cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if (mapSpecify == null) {
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.EDUCATIONTRAININGREQUEST);
                    }
                    setApprovalUser(mapSpecify, cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }
    public void setApprovalUser(Map<Decimal, Organizational__c> mapSpecify, Approval_Managed1__c cam) {
        //cam.Applicant__c 为与SALESFORCE帐号相关的申请人
        //cam.Employee__c  为界面上新增的员工字段，与SALESFORCE账号无关

        //申請人單位主管 mapSpecify.get(1)會抓[流程配置]第一關的資訊
        //丟到Utils.approvalSearchApprrovalerByRule(Organizational__c,contactID)後 會抓mapSpecify.get(1)的參數 ex.审批人规则=指定崗位 or 指定人員
        //指定崗位 or 指定人員 是用中文字判斷.
        //根據不同規則拿申請人(contactID)作條件查詢審批人.
        System.debug('申請人(contactID)~~~~~~~~~~~' + cam.Applicant__c);
        cam.Approval_User1__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        //Id myid = Id.valueOf('00528000006o8EJAAY');
       // cam.Approval_User1__c     = myid;
        //人力資源課承辦人
        cam.Approval_User2__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2), null), 0);

        //人力資源課
        cam.Approval_User3__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3), null), 0);

        //管理部
        cam.Approval_User4__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4), null), 0);

        //總經理核示
        cam.Approval_User5__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5), null), 0);
        System.debug(cam.Approval_User1__c + ' ' + cam.Approval_User2__c + ' ' + cam.Approval_User3__c + ' ' + cam.Approval_User4__c + ' ' + cam.Approval_User5__c);
        //cam.Applicant__c 为与SALESFORCE帐号相关的申请人
        //cam.Employee__c  为界面上新增的员工字段，与SALESFORCE账号无关
        //指定申请人部门主管，一阶主管，上级主管
        //cam.Approval_User2__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.指定申请人字段),0);

        //指定作业人
        //cam.Approval_User2__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.指定作业人字段),0);

        //其他审批人规则
        //cam.Approval_User4__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0);
    }
}