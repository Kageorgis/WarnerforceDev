public with sharing class WB_RedirectCommercialAvail_Controller {
    public list<User> userDetail ;
    public list<Release_Plan_Exceptions__c> rpExcpetionDisplay{get;set;}
    
    public WB_RedirectCommercialAvail_Controller(ApexPages.StandardSetController controller) {
        userDetail = new list<User>(); 
        userDetail =[SELECT id,ProfileId,Profile.Name,UserType,Territory__c,CA_Batch_Id__c,RP_Batch_Id__c  from User where id =: Userinfo.getUserId() ];
        
        rpExcpetionDisplay= new  list<Release_Plan_Exceptions__c>();
        rpExcpetionDisplay=[Select id, name,Title__c,Country__c,Language__c,Channel__c,Format__c,Avails_Start__c,
                            Avails_End__c,Release_Start_Date__c,Release_End_Date__c,Status__c,Reason__c
                            from Release_Plan_Exceptions__c 
                            where 
                            User_Detail__c=:userDetail[0].Id];
    }
    
    public pageReference proceed(){
        try{
            
            Database.DeleteResult[] saveResult  = Database.delete(rpExcpetionDisplay, false); 
            
        }catch(exception e){
            system.debug('An Exception Occured'+e);
        }
        //pageReference pageRef= new Pagereference(System.label.Re_direct_Commercal_Avail_Wizard);
        // as per crrt phase 2 requirement
        PageReference PageRef = new Pagereference('/apex/WB_Grid');
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Commercial_Avail__c');
        Pageref.getParameters().put('CF_QP_filterField','Batch_Id__c');
        Pageref.getParameters().put('CF_QP_filterValue',userDetail[0].RP_Batch_Id__c);
        Pageref.setRedirect(false);
        return pageRef;
    }
}