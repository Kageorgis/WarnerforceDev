/**
 * Written by: Preeti Jha(CTS)
 * Description: This controller is used to display the error Report after request refresh is launch via wizard.
 * Project: CRRT (Phase 4-B) 
**/

public class WB_RedirectRequestRefresh_Controller {
    public list<User> userDetail ;
    public list<Request_Rights_error_log__c> rightsExcpetionDisplay{get;set;}
    public boolean RequestSubmited {get;set;}
    public string titleId{get;set;}
    public string titleName{get;set;}
    
    public WB_RedirectRequestRefresh_Controller(ApexPages.StandardSetController controller) {
        titleId = ApexPages.currentPage().getParameters().get('titleId');
        titleName = ApexPages.currentPage().getParameters().get('titleName');
        RequestSubmited= false;
        userDetail = new list<User>(); 
        userDetail =[SELECT id,ProfileId,Profile.Name,UserType,Territory__c,Rights_Batch_Id__c from User where id =: Userinfo.getUserId() ];
        
        rightsExcpetionDisplay= new  list<Request_Rights_error_log__c>();
        rightsExcpetionDisplay=[Select id, Name, Reason__c, MPM__c, Rights_Id__c,Status__c, Rights_Group__c, Channel__c, Rights_Start_1__c, Rights_End_1__c from Request_Rights_error_log__c limit 1000];
        system.debug('rightsExcpetionDisplay.size() '+rightsExcpetionDisplay.size());
        if(rightsExcpetionDisplay.size() == 0)
        { 
             RequestSubmited= true;
             system.debug('in...');
        }  
        
    }
    
    public void proceed(){
        try{
           RequestSubmited= true;
            Database.DeleteResult[] saveResult  = Database.delete(rightsExcpetionDisplay, false); 
           
            
        }catch(exception e){
            system.debug('An Exception Occured'+e);
        }
        /*PageReference PageRef = new Pagereference('/apex/WB_Grid');
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Rights__c');
        Pageref.getParameters().put('CF_QP_filterField','Batch_Id__c');
        Pageref.getParameters().put('CF_QP_filterValue',userDetail[0].Rights_Batch_Id__c);
        Pageref.setRedirect(false);
        return pageRef;*/
    }

}