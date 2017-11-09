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
         

         List<Object> a =[SELECT (SELECT ID FROM ProcessInstances
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

    public static void aaa(){

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


}