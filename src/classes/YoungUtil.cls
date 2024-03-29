public with sharing class YoungUtil
{
    /**
     * [whenRejectValidateProcessCommentNotNull description]
     * 當簽核者拒絕該表單,則必須輸入拒絕理由,否則給予錯誤訊息.
     * @param rejectedStatements [description]
     */
    public static void whenRejectValidateProcessCommentNotNull(Map<Id, object> rejectedStatements, String message)
    {
        //UPDATE 2/1/2014: Get the most recent approval process instance for the object.
        // If there are some approvals to be reviewed for approval, then
        // get the most recent process instance for each object.
        List<Id> processInstanceIds = new List<Id> {};


        List<Object> a = [SELECT (SELECT ID FROM ProcessInstances
                                  ORDER BY CreatedDate DESC
                                  LIMIT 1)
                          FROM Approval_Managed1__c
                          WHERE ID IN :rejectedStatements.keySet()];

        for (Object invs : a)
        {

            processInstanceIds.add(((Approval_Managed1__c)invs).ProcessInstances[0].Id);
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
                addErrorByObjType(rejectedStatements.get(pi.TargetObjectId), message);
            }
        }
    }

    public static void aaa()
    {

    }
    /**
     * [addErrorByObjType description]
     *
     * @param o       [description]
     * @param message [description]
     */
    public static void addErrorByObjType(Object o, String message)
    {
        // need to find out if o is a string or an integer
        List<Id> processInstanceIds = new List<Id> {};
        String type = getType(o); // ?
        if(type.equals('Approval_Managed1__c'))
        {
            ((Approval_Managed1__c)o).addError(message);

        }
        else
        {
            // do something else ....
        }
    }

    public static Id getIdByObjType(Object o)
    {
        String type = getType(o);
        if(type.equals('Approval_Managed1__c'))
        {
            return ((Approval_Managed1__c)o).id;
        }

        return ((Approval_Managed1__c)o).id;
    }



    public static string getType(Object o)
    {
        if(o == null) return '';            // we can't say much about null with our current techniques
        if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName() + '';
        if(o instanceof Boolean)            return 'Boolean';
        if(o instanceof Id)                 return 'Id';
        if(o instanceof String)             return 'String';
        if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof String)             return 'String';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Decimal';  // we can't distinguish between decimal and double
        if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
        if(o instanceof List<object>)       return 'List';
        return 'Object';                    // actually we can't detect maps and sets and maps
    }

    public static string createEvent()
    {
        Contact c = [Select id, SF_User__r.id from Contact where name = '陳 麗娟'].get(0);
        Contact c1 = [Select id, SF_User__r.id from Contact where name = '梁 惠雯'].get(0);
        Contact c2 = [Select id, SF_User__r.id from Contact where name = '高 慧珠'].get(0);

        //邀關聯的表單ID
        Approval_Managed1__c am = [Select id from Approval_Managed1__c where id = 'a07N000000IdYdi'].get(0);
        Event e = new Event();
        e.Subject = '6666';
        datetime a = datetime.now();
        e.OwnerId = c.SF_User__r.id;
        e.ActivityDateTime = a;
        e.StartDateTime = a;
        e.EndDateTime = a.adddays(5);
        e.WhoId = c.Id;
        e.WhatId = am.Id;

        insert e;

        EventRelation er = new EventRelation();
        System.debug(e.Id);
        er.EventId = e.Id;
        er.RelationId =  c1.SF_User__r.id;//用SF_User__r.id作為邀請人才是真邀請
        insert er;

        EventRelation er1 = new EventRelation();
        er1.EventId = e.Id;
        er1.RelationId = c2.SF_User__r.id;//用SF_User__r.id作為邀請人才是真邀請
        insert er1;

        EventRelation er2 = new EventRelation();
        er2.EventId = e.Id;
        er2.RelationId = '02328000003LL4r';
        er2.Status = 'Accepted';//設為邀請人已接受 因為是資源 所以必須設為接受
        insert er2;

        update e;



        return 'success';
    }

}