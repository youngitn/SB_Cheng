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
public without sharing class ProcessRollBackTest implements Triggers.Handler
{
    public void handle()
    {

        // work whith Field Update name="update Per AP"
        // 上述action 目的是要在各關卡給不同標記
        // 讓流程每過一關就會更新某個欄位 以進入update trigger
        // 如果再trigger裡面能做關卡識別 就能做一些控制了...
        // 當然下面的 pi.Steps 也能找到關卡資訊 但不太直覺 要層層剝開.
        //-------reject------->
        Map<Id, Approval_Managed1__c> rejectedStatements = new Map<Id, Approval_Managed1__c> {};
        //<-------reject-------
        //获取教育訓練申請流程各节点配置
        System.debug('!!!!!inAMEducationTrainingHandler');
        Map<Decimal, Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EDUCATIONTRAININGREQUEST, 'Approval_Managed1__c');
        System.debug('!!!!!get rtid =' + rtId);
        System.debug('Trigger.isBefore && Trigger.isInsert=' + Trigger.isBefore + '&&' + Trigger.isInsert);



        if (Trigger.isBefore)
        {
            System.debug('In Trigger.isBefore');


            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new)
            {

                if (cam.RecordTypeId == rtId)
                {
                    System.debug('cam.CurrentProcess__c===>' + cam.CurrentProcess__c);
                    if (cam.Approval_Status__c == 'D' )
                    {
                        System.debug('AP00!');
                        //cam.addError('AP00!');
                    }
                }

            }

        }

        if (Trigger.isBefore && Trigger.isInsert)
        {
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new)
            {
                if (cam.RecordTypeId == rtId)
                {
                    System.debug('##################insert cam.Approval_Status__c=' + cam.Approval_Status__c);


                    System.debug('!!!!!in cam.RecordTypeId == rtId');
                    if (mapSpecify == null)
                    {
                        //這裡的step來源是[流程配置] 不是Approval Processes
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.EDUCATIONTRAININGREQUEST);
                    }
                    setApprovalUser(mapSpecify, cam);
                }
                if (!String.isBlank(cam.InternalEducationParticipants__c))
                {
                    Set<String> userIds = new Set<String>();
                    List<String> pList = cam.InternalEducationParticipants__c.split(',');
                    System.debug('pList---------->' + pList);
                    System.debug('pList0---------->' + pList[0]);
                    System.debug('pList1---------->' + pList[1]);
                    for(String p : pList)
                    {
                        //如果沒有SF ID 在進行以下select時 i 會是空的
                        try
                        {
                            System.debug('i--p.substringAfter-------->' + p.substringAfter('-'));
                            List<User> i = [SELECT Id FROM User WHERE Number__c = : p.substringAfter('-')];
                            System.debug('i---------->' + i);
                            userIds.add(i.get(0).Id);
                        }
                        catch (System.ListException e)
                        {

                            System.debug(e.getStackTraceString());
                            cam.addError('參訓人:' + p + ' 沒有SF ID.');

                        }


                    }
                    if(userIds.size() > 0)
                    {
                        Utils.ManualShareRecordToUsers(userIds, 'Approval_Managed1__c', String.valueOf(cam.get('Id')));
                    }
                }

            }
        }

        if (Trigger.isBefore && Trigger.isUpdate)
        {
            System.debug('##################');

            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new)
            {
                //-------reject------->
                //Approval_Managed1__c oldInv = System.Trigger.oldMap.get(cam.Id);
                //System.debug('##################oldInv.Approval_Status__c=' + oldInv.Approval_Status__c);
                System.debug('##################update cam.Approval_Status__c=' + cam.Approval_Status__c);
                List<Organizational__c> org = getCurrNodeEditableField(SapApprovalEnum.EDUCATIONTRAININGREQUEST, cam.CurrentProcess__c);
                System.debug('*********************************>' + org.get(0).Node_Edit_Fields__c);
                String[] s = org.get(0).Node_Edit_Fields__c.split(',');
                for (String ss : s )
                {
                    // dynamic DML
                    Object fldObj = cam.get(ss);

                    //必填欄位等於AP02則拋錯誤訊息
                    if(fldObj.equals('AP02'))
                    {
                                                    
                    	cam.addError('ERROR');

                    }
                    

                }



                if (/*oldInv.Approval_Status__c != 'Rejected' && */cam.Approval_Status__c == 'R')
                {
                    rejectedStatements.put(cam.Id, cam);
                }
                //<-------reject-------
                //-------approve------->
                //A='已核准'??? 所以這邊都是要丟進去update的值
                // if (cam.Approval_Status__c == 'S' )
                // {

                //     //do,when AP00 to 01
                //     if (/*oldInv.Approval_Status__c != 'Rejected' && */cam.CurrentProcess__c == 'AP01')
                //     {
                //         //AP01.put(cam.Id, cam);
                //         System.debug('AP01!');
                //         cam.addError('AP01!');
                //     }
                //     //do,when AP01 to 02
                //     if (/*oldInv.Approval_Status__c != 'Rejected' && */cam.CurrentProcess__c == 'AP02')
                //     {
                //         System.debug('AP02!');
                //         //AP02.put(cam.Id, cam);
                //         cam.addError('AP02!');
                //     }
                //     //do,when AP02 to 03
                //     if (/*oldInv.Approval_Status__c != 'Rejected' && */cam.CurrentProcess__c == 'AP03')
                //     {
                //         System.debug('AP03!');
                //         //AP03.put(cam.Id, cam);
                //         cam.addError('AP03!');
                //     }
                //     //do,when AP03 to 04
                //     if (/*oldInv.Approval_Status__c != 'Rejected' && */cam.CurrentProcess__c == 'AP04')
                //     {
                //         System.debug('AP04!');
                //         //AP04.put(cam.Id, cam);
                //         cam.addError('AP04!');
                //     }
                //     //do,when AP04 to 05
                //     if (/*oldInv.Approval_Status__c != 'Rejected' && */cam.CurrentProcess__c == 'AP05')
                //     {
                //         System.debug('AP05!');
                //         //AP05.put(cam.Id, cam);
                //         cam.addError('AP05!');
                //     }
                // }
                //<--------approve--------


                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c)
                {
                    if (mapSpecify == null)
                    {
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.EDUCATIONTRAININGREQUEST);
                    }
                    setApprovalUser(mapSpecify, cam);
                    cam.Is_Reset_Approvaler__c = false;
                }

            }
            //-------reject check Comments and give error------->
            if (!rejectedStatements.isEmpty())
            {
                // UPDATE 2/1/2014: Get the most recent approval process instance for the object.
                // If there are some approvals to be reviewed for approval, then
                // get the most recent process instance for each object.
                List<Id> processInstanceIds = new List<Id> {};

                for (Approval_Managed1__c invs : [SELECT (SELECT ID
                                                  FROM ProcessInstances
                                                  ORDER BY CreatedDate DESC
                                                  LIMIT 1)
                                                  FROM Approval_Managed1__c
                                                  WHERE ID IN :rejectedStatements.keySet()])
                {
                    processInstanceIds.add(invs.ProcessInstances[0].Id);
                }

                // Now that we have the most recent process instances, we can check
                // the most recent process steps for comments.
                for (ProcessInstance pi : [SELECT TargetObjectId,
                                           (SELECT Id, StepStatus, Comments
                                            FROM Steps
                                            ORDER BY CreatedDate DESC
                                            LIMIT 1 )
                                           FROM ProcessInstance
                                           WHERE Id IN :processInstanceIds
                                           ORDER BY CreatedDate DESC])
                {
                    if ((pi.Steps[0].Comments == null ||
                            pi.Steps[0].Comments.trim().length() == 0))
                    {
                        //way 1
                        // rejectedStatements.get(pi.TargetObjectId).addError(
                        //     '<script>document.getElementById("errorDesc").remove();alert("請輸入拒絕理由!");</script>',false);
                        //way 2
                        // rejectedStatements.get(pi.TargetObjectId).addError(
                        //     '<script>document.getElementById("bodyCell").innerHTML="<cnter><H1 >請輸入拒絕理由!</H1><br/><a>回上頁</a></center>";</script>',false);
                        rejectedStatements.get(pi.TargetObjectId).addError(
                            '請輸入拒絕理由', false);
                    }
                }
            }
            //<-------reject-------
        }
    }

    /**
     * [getCurrNodeEditableField description]
     * 取得
     * @param  formName            [description]
     * @param  targetFieldNameType [description]
     * @return                     [description]
     */
    public List<Organizational__c> getCurrNodeEditableField(String formName , String NowNode )
    {
        //get node data
        List<Organizational__c> configs = [SELECT Node_Edit_Fields__c
                                           FROM Organizational__c
                                           WHERE RecordType.DeveloperName = 'Node_Edit_Field'
                                                   AND Approval_Name__c = :formName
                                                           AND Node_API__c = :NowNode];
        return configs;
    }


    /**
     * [setApprovalUser description]
     * @param mapSpecify [description]
     * @param cam        [description]
     */
    public void setApprovalUser(Map<Decimal, Organizational__c> mapSpecify, Approval_Managed1__c cam)
    {
        //cam.Applicant__c 为与SALESFORCE帐号相关的申请人
        //cam.Employee__c  为界面上新增的员工字段，与SALESFORCE账号无关

        //申請人單位主管 mapSpecify.get(1)會抓[流程配置]第一關的資訊
        //丟到Utils.approvalSearchApprrovalerByRule(Organizational__c,contactID)後 會抓mapSpecify.get(1)的參數 ex.审批人规则=指定崗位 or 指定人員
        //指定崗位 or 指定人員 是用中文字判斷.
        //根據不同規則拿申請人(contactID)作條件查詢審批人.
        System.debug('申請人(contactID)~~~~~~~~~~~' + cam.Applicant__c);
        cam.Approval_User1__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1), cam.Applicant__c), 0);
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
