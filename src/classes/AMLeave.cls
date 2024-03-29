public with sharing class AMLeave {
    public Approval_Managed__c am {get; set;}

    public Id amId {get; set;}
    public List<Approval_Managed_Item__c> list1 {get; set;}

    public List<Approval_Managed_Item__c> preDeletelist1 {get; set;}

    public Map<String,Approval_Managed_Item__c> mapVoucher{get;set;}

    public Integer list1Row {get; set;}
    public Boolean isDeletedStatus{GET;SET;}
    //明细记录类型ID
    private Id recTypeDetailId = null;


    public AMLeave(ApexPages.StandardController con) {
        displayQueryResult = 'none';

        recTypeDetailId = HarryUtils.getRecordTypeIdByDevNameAndObjName('LeaveDetails','Approval_Managed_Item__c');
        System.debug(LoggingLevel.INFO, '*** recTypeDetailId1: ' + recTypeDetailId);
        list1Row = 0;
        amId = con.getId();
        System.debug(LoggingLevel.INFO, '*** con.getId: ' + con.getId());
        System.debug(LoggingLevel.INFO, '*** amId: ' + amId);
        mapVoucher = new Map<String,Approval_Managed_Item__c>();
        
        if (isInsert()) {
            am = new Approval_Managed__c();
            am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.LEAVE, 'Approval_Managed__c');

            list1 = new List<Approval_Managed_Item__c>();

            preDeletelist1 = new List<Approval_Managed_Item__c>();

            return;
        }

        //获取到当前记录信息，目标获取后跳转到自定义PAGE里面有这条数据
        String sql = Utils.getApprovalSQL(SapApprovalEnum.LEAVE, true);
        sql = sql + ' WHERE Id = \'' + amId + '\'';
        am = Database.query(sql);

        list1 = [SELECT RecordTypeId,LeaveManage__c,Leave_type__c,Leave_reason__c,Start_date__c,End_date__c,Start_time__c,End_time__c,Time_number__c FROM Approval_Managed_Item__c 
                  WHERE LeaveManage__c = :amid AND RecordType.DeveloperName = 'LeaveDetails'];

        preDeletelist1 = new List<Approval_Managed_Item__c>();
        if (am.Name != null) {
            displayQueryResult = null;
        }
    }

    public PageReference save() {
        if (String.isNotBlank(am.Employee__c) ) {
            List<Contact> lstCon = [SELECT Name, Number__c FROM Contact WHERE Id = :am.Employee__c AND RecordType.DeveloperName = 'Staff'];
            if (lstCon.size()>0) {
                am.Employee_Code__c = lstCon[0].Number__c;
                am.Employee_Name__c = lstCon[0].Name;
            }
        }else{
                am.Employee_Code__c = null;
                am.Employee_Name__c = null;
                am.Employee__c = null;
        }
        try {

            upsert am;
            DELETE preDeletelist1;
            am.Sum_Vacation__c = 0;
            System.debug('*** listRowInfo: ' + list1 + '');
            //更新详细记录
            if (list1.size()>0) {

                for (Approval_Managed_Item__c ami : list1) {

                    if (ami.Start_date__c > ami.End_date__c) {
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING,'开始日期不能大于结束日期'));    
                        return null;
                    }

                    ami.RecordTypeId = recTypeDetailId;
                    ami.LeaveManage__c = am.Id;

                    am.Sum_Vacation__c += Decimal.valueOf(ami.time_number__c);
                    /*
                    Integer hour1 = Integer.valueOf(ami.Start_Time__c.substring(0,2));
                    Decimal minute1 = Integer.valueOf(ami.Start_Time__c.substring(2,4));
                    Integer hour2 = Integer.valueOf(ami.End_Time__c.substring(0,2));
                    Decimal minute2 = Integer.valueOf(ami.End_Time__c.substring(2,4));
                    System.debug(LoggingLevel.INFO, '*** minute1: ' + minute1);
                    System.debug(LoggingLevel.INFO, '*** minute2: ' + minute2);
                    System.debug(LoggingLevel.INFO, '*** hour1: ' + hour1);
                    System.debug(LoggingLevel.INFO, '*** hour2: ' + hour2);
                    Decimal sum_hour = (minute2 - minute1) / 60 + hour2 - hour1;
                    sum_hour += ami.Start_date__c.daysBetween(ami.End_date__c) * 8;
                    ami.time_number__c = String.valueOf( sum_hour );
                    System.debug(LoggingLevel.INFO, '*** sum_hour: ' + sum_hour);
                    am.Sum_Vacation__c = am.Sum_Vacation__c + sum_hour;
                    /*
                    Integer hour = Integer.valueOf(ami.Start_Time__c.substring(0,2));
                    Integer minute = Integer.valueOf(ami.Start_Time__c.substring(2,4));
                    Integer second = Integer.valueOf(ami.Start_Time__c.substring(4,6));

                    Time t1 = Time.newInstance(hour,minute,second, 0);
                    System.debug(LoggingLevel.INFO, '*** t1: ' + t1);
                    hour = Integer.valueOf(ami.End_Time__c.substring(0,2));
                    minute = Integer.valueOf(ami.End_Time__c.substring(2,4));
                    second = Integer.valueOf(ami.End_Time__c.substring(4,6));
                    Time t2 = Time.newInstance(hour,minute,second, 0);
                    System.debug(LoggingLevel.INFO, '*** t2: ' + t2);
                    Datetime dt1 = Datetime.newInstance(ami.Start_date__c, t1);
                    Datetime dt2 = Datetime.newInstance(ami.End_date__c, t2);

                    Decimal sum_hour = Decimal.valueOf( dt2.getTime() - dt1.getTime() ) / 3600000;

                    ami.time_number__c = String.valueOf( sum_hour );
                    System.debug(LoggingLevel.INFO, '*** sum_hour: ' + sum_hour);
                    am.Sum_Vacation__c = am.Sum_Vacation__c + sum_hour;
                    System.debug(LoggingLevel.INFO, '*** am.Sum_Vacation__c: ' + am.Sum_Vacation__c);
                    /*
                    am.Sum_Vacation__c = am.Sum_Vacation__c + sum_hour;
                    System.debug(LoggingLevel.INFO, '*** am.Sum_Vacation__c: ' + am.Sum_Vacation__c);
                    ami.RecordTypeId = recTypeDetailId;
                    System.debug(LoggingLevel.INFO, '*** ami.RecordTypeId: ' + ami.RecordTypeId);
                    */
                }
            }
            upsert list1;
            upsert am;
        }
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/' + am.Id);

    } 


    public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }
    
    public PageReference newlist1() {
        Approval_Managed_Item__c ami = new Approval_Managed_Item__c();
        ami.RecordTypeId = recTypeDetailId;
        list1.add(ami);
        return null;
    }

    public PageReference deletelist1() {
        if (list1[list1Row].Id != null) {
            preDeletelist1.add(list1[list1Row]);
        }
        list1.remove(list1Row);
        return null;
    }

    public String displayQueryResult {get; set;}

    public Boolean isInsert() {
        return amId == null;
    }

    public PageReference queryVacation() {
        System.debug(LoggingLevel.INFO, '*** 进入查询: '+am);
        if (String.isBlank(am.Employee__c)) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING,'请输入员工名称'));    
            return null;
        }
        Contact con = [SELECT Name, Number__c FROM Contact WHERE Id = :am.Employee__c AND RecordType.DeveloperName = 'Staff'LIMIT 1];
        try{
            String str1 = SapQueryArgCreate.createVacationQuery(con.Number__c);
            
            System.debug(str1);
            String str2 = Utils.postToSAP(str1);
            SapWebServiceReturnArgs args = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            System.debug(LoggingLevel.INFO, '*** args: ' + args);
            Approval_Managed__c amget = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content[0].main), Approval_Managed__c.class);
            am.Employee_Code__c = amget.Employee_Code__c;
            am.Annual_leave__c  = amget.Annual_leave__c;
            am.Adjustable_vacation__c  = amget.Adjustable_vacation__c;
        }catch(Exception ex){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage() + '\n' + ex.getStackTraceString()));    
        }
        displayQueryResult = null;
        return null;
    }

}