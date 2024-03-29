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
        
        Map<Decimal, Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EDUCATIONTRAININGREQUEST, 'Approval_Managed1__c');
       



        if (Trigger.isBefore)
        {
          

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
           

            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new)
            {
                //-------reject------->
                //Approval_Managed1__c oldInv = System.Trigger.oldMap.get(cam.Id);
                //System.debug('##################oldInv.Approval_Status__c=' + oldInv.Approval_Status__c);
                // 這裡已經是取得'本關卡'的必填(目前用可編輯欄位模擬)欄位了
                List<Organizational__c> org = getCurrNodeEditableField(SapApprovalEnum.EDUCATIONTRAININGREQUEST, cam.CurrentProcess__c);
                //如果有必填欄位 目前是抓可編輯欄位
                if (org.size() > 0)
                {
                    
                    String[] s = org.get(0).Node_Edit_Fields__c.split(',');
                    String errorMessage = '';
                    //必填欄位(目前用可編輯欄位模擬)抓取與判斷完成
                    for (String ss : s )
                    {
                        // dynamic DML
                        // 取欄位標籤用
                        Map<String, Schema.SObjectField> myFields = Schema.getGlobalDescribe().get( 'Approval_Managed1__c' ).getDescribe().fields.getMap();

                        object o = cam.get(ss);
                        //如果必填欄位(目前用可編輯欄位模擬)是空值 就在這裡判斷
                        //是空的話加入errorMessage
                        //目前這邊將AP02字串 當空值 如果必填欄位(目前用可編輯欄位模擬)中value有AP02的就加入錯誤訊息
                        //同時取得該欄位label做為訊息顯示
                        if(o == null || o.equals('') || o.equals('AP01'))
                        {

                            errorMessage += '<li style=\'background-color:red;color:white;font-size:150%\'>' + myFields.get(ss).getDescribe().getLabel() + '</li>';
                            // cam.addError(
                            // '<script>document.getElementById("bodyCell").innerHTML="<cnter><ul><li>請輸入拒絕理由!</li></ul><br/><a onclick=\'history.back()\'>回上頁</a></center>";</script>', false);

                        }



                    }
                    //必填未填即拋出訊息
                    if (!errorMessage.trim().equals(''))
                    {
                        cam.addError(
                            '<script>document.getElementById("bodyCell").innerHTML="以下必填欄位(目前用可編輯欄位模擬)不可空白:<ul>' + errorMessage + '</ul><br/><a onclick=\'history.back()\'>回上頁</a>"</script>', false);
                    }


                }

                if (/*oldInv.Approval_Status__c != 'Rejected' && */cam.Approval_Status__c == 'A')
                {
                    System.debug('SUCCESS');
                    /*********************** 當審批完成再創建事件會有會議室booking的時效問題************************/
                    //建立一event type=日循環
                    // Event e = new Event(RecurrenceType = 'RecursDaily'); //如果API文件上面類型是屬性 則要在建構式給它
                    // e.Subject = cam.EducationTrainingName__c+'_核准後';
                    // datetime startTime = cam.Start_Time__c;//只抓時間
                    // e.OwnerId = Utils.getUserIdByContactID(cam.Applicant__c);
                    // e.ActivityDateTime = startTime;//只抓時間
                    // e.StartDateTime = startTime;//只抓時間
                    // e.EndDateTime = cam.End_Time__c;//只抓時間

                    // //e.WhoId = am.Applicant__c;//非必要
                    // e.WhatId = cam.Id;//關聯單Id
                    // e.IsAllDayEvent = false; //是否全天
                    // e.IsRecurrence = true; //循環
                    // e.RecurrenceStartDateTime = startTime; //循環開始時間 同開始時間

                    // //天數要減1 addDays(1) 會變成兩天
                    // e.RecurrenceEndDateOnly = startTime.adddays(Integer.valueOf(cam.Days__c) - 1).date(); //循環結束日期
                    // e.RecurrenceInterval = 1; //循環頻率

                    // insert e;
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
                        rejectedStatements.get(pi.TargetObjectId).addError(
                            '<script>document.getElementById("bodyCell").innerHTML="<cnter><H1 >請輸入拒絕理由!</H1><br/><a>回上頁</a></center>";</script>', false);
                        // rejectedStatements.get(pi.TargetObjectId).addError(
                        //     '請輸入拒絕理由', false);
                    }
                }
            }
            //<-------reject-------
        }
    }

    /**
     * [getCurrNodeEditableField 取的目前關卡的可編輯欄位名稱]
     * @param  formName            [SapApprovalEnum.流程名稱]
     * @param  NowNode			   [目前流程關卡欄位]
     * @return List<Organizational__c> [description]
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
