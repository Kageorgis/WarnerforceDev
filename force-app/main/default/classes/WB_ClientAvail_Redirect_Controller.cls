public with sharing class WB_ClientAvail_Redirect_Controller{

 public list<Client_Avail_Exception__c> clientAvailException_list {get; set;}
 public list<User> userDetail = new list<User>();
 public boolean flagNotZeroReleasePlan {get; set;}
 public boolean flagZeroReleasePlan {get; set;}
 public integer recordCount{get;set;}
 
 public WB_ClientAvail_Redirect_Controller(ApexPages.StandardController  controller){
    
    clientAvailException_list = new list<Client_Avail_Exception__c>();
    flagNotZeroReleasePlan = false;
    flagZeroReleasePlan = false;
    //Logged in user details
    userDetail =[   SELECT id,Name  from User where id =: Userinfo.getUserId() ];
    
    //client avail exception list   
    clientAvailException_list =[SELECT Name,Avail_End__c,Avail_Start__c,Channel__c,Content_Type__c,Country__c,Format__c,Language__c,
                                Language_Type__c,Reason__c,Release_Plan_Number__c,Status__c,Title__c,User_Detail__c,Account__c
                                from Client_Avail_Exception__c where User_Detail__c =:userDetail[0].id];
    
    recordCount= clientAvailException_list.size();
    
    //set flag value for rendering the block
    if(clientAvailException_list.size()!=0){
        flagNotZeroReleasePlan = true;
        flagZeroReleasePlan = false;
    }
    else {
        flagNotZeroReleasePlan = false;
        flagZeroReleasePlan = true;
    }
    
 }
    public pageReference okbutton(){
    
    try{
        if(clientAvailException_list != null && clientAvailException_list.size() > 0){          
            Database.Deleteresult[] deleteResult  = Database.delete(clientAvailException_list, false);
            
              if (Deleteresult[0].isSuccess()){
                Pagereference PageRef = new Pagereference(System.Label.My_Latest_Wizard_Run);                 
                
                 return PageRef;
              }     
        }
        else{
            Pagereference PageRef = new Pagereference(System.Label.My_Latest_Wizard_Run);                 
           
            return PageRef;
        
        }

    } 
    catch(Exception e) 
    {
        System.debug('The following exception has occurred: ' + e.getMessage());
    }
    return null;        
    }//end of okbutton function
}