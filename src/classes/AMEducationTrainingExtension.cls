public class AMEducationTrainingExtension
{

    public Approval_Managed1__c am  {Get; Set;}
    public Contact contact {get; set;}
    public String ApplicantEmpid  {get; set;}

    //public List<Contact > contactList {get; set;}
    //public String  contactName{Get; Set;}
    //參訓人員
    public List<participant> participants {get; set;}

    public AMEducationTrainingExtension(ApexPages.StandardController con)
    {

        am = new Approval_Managed1__c();

        am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EDUCATIONTRAININGREQUEST, 'Approval_Managed1__c');

        am.Approval_Name__c = SapApprovalEnum.EDUCATIONTRAININGREQUEST;

        if (con.getId() != null)
        {
            am = (Approval_Managed1__c)con.getRecord();
        }

        participants = new List<participant>();
        contact = new Contact();

    }


    public PageReference save()
    {

        String ps = '';
        Integer i = participants.size();
        //天數不能為0
        if (am.Days__c == null || am.Days__c.equals('0'))
        {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'custom label message:Days can\'t be 0'));
            return null;
        }




        Upsert am;
        if (i > 0)
        {
            //建立一event type=日循環
            Event e = new Event(RecurrenceType = 'RecursDaily'); //如果API文件上面類型是屬性 則要在建構式給它
            e.Subject = am.EducationTrainingName__c;
            datetime startTime = am.Start_Time__c;//只抓時間
            e.OwnerId = Utils.getUserIdByContactID(am.Applicant__c);
            e.ActivityDateTime = startTime;//只抓時間
            e.StartDateTime = startTime;//只抓時間
            e.EndDateTime = am.End_Time__c;//只抓時間

            //e.WhoId = am.Applicant__c;//非必要
            e.WhatId = am.Id;//關聯單Id
            e.IsAllDayEvent = false; //是否全天
            e.IsRecurrence = true; //循環
            e.RecurrenceStartDateTime = startTime; //循環開始時間 同開始時間

            //天數要減1 addDays(1) 會變成兩天
            e.RecurrenceEndDateOnly = startTime.adddays(Integer.valueOf(am.Days__c) - 1).date(); //循環結束日期
            e.RecurrenceInterval = 1; //循環頻率

            insert e;


            for (participant p : participants)
            {
                i--;

                System.debug(p);
                //增加邀請人
                EventRelation er = new EventRelation();
                System.debug(e.Id);
                er.EventId = e.Id;
                //getUserByEmployeeCode(p.empid);
                er.RelationId =  Utils.getUserByEmployeeCode(p.empid);//用SF_User__r.id作為邀請人才是真邀請
                insert er;
                ps += p.name + '-' + p.empid;
                if (i > 0)
                {

                    ps += ',';
                }

            }
            if(!String.isBlank(am.Meeting_Rooms__c))
            {
                EventRelation res = new EventRelation();
                res.EventId = e.Id;
                res.RelationId = Id.valueOf(am.Meeting_Rooms__c);
                res.Status = 'Accepted';//設為邀請人已接受 因為是資源 所以必須設為接受
                insert res;
            }
            am.InternalEducationParticipants__c = ps;
        }
        System.debug('In save extention ');
        return new PageReference('/' + am.Id);


    }


    public PageReference Cancel()
    {
        return null;
    }

    public PageReference addParticipant()
    {

        //contactList.add(New Contact());
        participant p = new participant();
        participants.add(p);
        return null;
    }

    public PageReference deleteRow()
    {
        //get rowId
        Integer rowId = integer.valueof(Apexpages.currentPage().getParameters().get('rowId')) - 1;

        //contactList.remove(rowId);
        participants.remove(rowId);
        return null;
    }


    public  PageReference putValue()
    {

        String inputType = Apexpages.currentPage().getParameters().get('inputType');
        String inputValue  = Apexpages.currentPage().getParameters().get('inputValue');
        Integer rowId = integer.valueof(Apexpages.currentPage().getParameters().get('rowId')) - 1;
        if (inputType.equals('empid') && !String.isBlank(inputValue))
        {
            participants.get(rowId).empid = inputValue;
            List<Contact> cont = [SELECT Name, Dept_Number__r.Name FROM CONTACT WHERE number__c = :inputValue];
            if(cont.size() < 1 )
            {
                participants.get(rowId).name = '查無此人';

            }
            else
            {
                participants.get(rowId).name = cont.get(0).name;
                participants.get(rowId).dep = cont.get(0).Dept_Number__r.Name;
            }

        }
        else
        {
            participants.get(rowId).name = inputValue;
        }

        return null;
    }

    public class participant
    {
        public String name {get; set;}
        public String empid {get; set;}
        public String dep {get; set;}
        public void participant(String name, String empid, String dep)
        {
            this.name = name;
            this.empid = empid;
            this.dep = dep;
        }
    }

    public void getContactNameByEmpid()
    {
        String empid = Apexpages.currentPage().getParameters().get('empid');
        ApplicantEmpid = [SELECT Name FROM CONTACT WHERE number__c = :empid].get(0).Name;

    }
    public void getContactEmpidByName()
    {
        String name = Apexpages.currentPage().getParameters().get('name');
        ApplicantEmpid = [SELECT number__c FROM CONTACT WHERE name = :name].get(0).number__c;

    }

    public void getContactDepNameByEmpid()
    {
        String empid = Apexpages.currentPage().getParameters().get('empid');
        ApplicantEmpid = [SELECT Dept_Number__r.Name FROM CONTACT WHERE number__c = :empid].get(0).Dept_Number__r.Name;
    }

}