public class AMEducationTrainingController {

    public Approval_Managed1__c am  {Get; Set;}
     public Contact contact {get; set;}

    //public List<Contact > contactList {get; set;}
    //public String  contactName{Get; Set;}
    //參訓人員
    public List<participant> participants {get; set;}

    public AMEducationTrainingController(ApexPages.StandardController con) {

        am = new Approval_Managed1__c();

        am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EDUCATIONTRAININGREQUEST, 'Approval_Managed1__c');

        am.Approval_Name__c = SapApprovalEnum.EDUCATIONTRAININGREQUEST;

        if (con.getId() != null) {
            am = (Approval_Managed1__c)con.getRecord();
        }

        //contactList = New List<Contact>();
        participants = new List<participant>();
        contact = new Contact();

    }


    public PageReference save() { 

        String ps = '';
        Integer i = participants.size();
        
        if (i > 0){
            for (participant p : participants) {
                i--;

                System.debug(p);
                List<Contact> cl = [SELECT id, name FROM Contact WHERE number__c = :p.empid];
                System.debug(cl);
                System.debug(cl.get(0).id);
                Event ev = new Event
                (
                    whoId = cl.get(0).id,
                    StartDateTime = Datetime.valueOf(am.EducationTrainingTime__c),
                    EndDateTime = Datetime.valueOf(am.EducationTrainingTime__c).addHours(Integer.valueOf(am.EducationTrainingHours__c)),//看這裡~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ActivityDateTime = Datetime.valueOf(am.EducationTrainingTime__c),
                    Subject = SapApprovalEnum.EDUCATIONTRAININGREQUEST + ' Event',
                    Description =  'It s EDUCATIONTRAININGREQUEST'
                );
                insert ev;
                ps += p.name +'-'+ p.empid;
                if (i > 0){

                    ps+=',';
                }

            }

            am.InternalEducationParticipants__c = ps;
        }
        
        

        Upsert am;
        System.debug('In save extention ');
        return new PageReference('/' + am.Id);


    }

    public PageReference Cancel() {
        return null;
    }

    public PageReference addBook() {

        //contactList.add(New Contact());
        participant p = new participant();
        participants.add(p);
        return null;
    }

    public PageReference deleteRow() {
        //get rowId
        Integer rowId = integer.valueof(Apexpages.currentPage().getParameters().get('rowId')) - 1;

        //contactList.remove(rowId);
        participants.remove(rowId);
        return null;
    }


    public  PageReference putValue() {

        String inputType = Apexpages.currentPage().getParameters().get('inputType');
        String inputValue  = Apexpages.currentPage().getParameters().get('inputValue');
        Integer rowId = integer.valueof(Apexpages.currentPage().getParameters().get('rowId')) - 1;
        if (inputType.equals('empid') && !String.isBlank(inputValue)){
            participants.get(rowId).empid = inputValue;
            List<Contact> cont = [SELECT Name FROM CONTACT WHERE number__c=:inputValue];
            if(cont.size() < 1 ){
               participants.get(rowId).name = '查無此人';

            }else{
                participants.get(rowId).name = cont.get(0).name;
            }
            
        }else{
            participants.get(rowId).name = inputValue;
        }   

        return null;
    }

    public class participant {
        public String name {get; set;}
        public String empid {get; set;}
        public void participant(String name,String empid) {
            this.name = name;
            this.empid = empid;
        }
    }

}