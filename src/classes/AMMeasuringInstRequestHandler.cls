/**********************************************************************
 名    称：内部联络申请流程
 目    的：设置内部联络申请流程各节点审批人
 作    者：
 创建日期：
 修 改 人：张旭
 修改日期：2017/07/12
 修改原因：添加昆山各节点审核人（节点三至节点七）
 备    注：昆山&台湾共同使用该流程
 
 
 **********************************************************************/
public without sharing class AMMeasuringInstRequestHandler implements Triggers.Handler {
    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.MEASURINGINSTREQUEST,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.MEASURINGINSTREQUEST);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }


        
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.MEASURINGINSTREQUEST);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }

            public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){
            	//节点一: 申请人
        		//cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),null),0);
            	//节点二：申请人部门主管
        		cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        		//节点三: 计量人员刘红燕
        		cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
        		//节点四: 采购  
        		cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
        		//节点五: 仓库
        		cam.Approval_User5__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0);
        		//节点六: 计量人员刘红燕进行标号等作业
        		cam.Approval_User6__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
            }

          
    
}