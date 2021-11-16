public with sharing class WB_SplitRP_Redirect_Controller{
    public list<Release_Plan_Exceptions__c> RPException_listold {get; set;}
    public list<Release_Plan_Exceptions__c> RPException_listnew {get; set;}
    public list<Release_Plan_Exceptions__c> RPException_listnew2 {get; set;}
    public list<Release_Plan_Exceptions__c> final_list = new list<Release_Plan_Exceptions__c>();
    public list<User> userDetail = new list<User>();
    public boolean newRPDisplay{get;set;}
    public boolean oldRPDisplay{get;set;}
    public boolean newExcepRPDisplay{get;set;}
    
    public WB_SplitRP_Redirect_Controller(ApexPages.StandardController  controller){
        newRPDisplay=true;
        oldRPDisplay=true;
        newExcepRPDisplay=true;
        RPException_listold = new list<Release_Plan_Exceptions__c>();
        RPException_listnew = new list<Release_Plan_Exceptions__c>();
        
        userDetail =[   SELECT id,Name  from User where id =: Userinfo.getUserId() ];
        
        RPException_listold = [SELECT Name,Avails_End__c,Avails_Start__c,Channel__c,Country__c,Format__c,Language__c,
                               Language_Type__c,Old_RP_Records__c,Reason__c,Release_End_Date__c,Release_Plan_Id__c,
                                Release_Start_Date__c,Status__c,Title__c,User_Detail__c from Release_Plan_Exceptions__c
                                where User_Detail__c =:userDetail[0].id and Old_RP_Records__c = true];
                                
        RPException_listnew = [SELECT Name,Avails_End__c,Avails_Start__c,Channel__c,Country__c,Format__c,Language__c,
                               Language_Type__c,Old_RP_Records__c,Reason__c,Release_End_Date__c,Release_Plan_Id__c,
                                Release_Start_Date__c,Status__c,Title__c,User_Detail__c from Release_Plan_Exceptions__c
                                where User_Detail__c =:userDetail[0].id and Old_RP_Records__c= false and Exception_with_ExistingRecord__c =false];
                                
        RPException_listnew2 = [SELECT Name,Avails_End__c,Avails_Start__c,Channel__c,Country__c,Format__c,Language__c,
                               Language_Type__c,Old_RP_Records__c,Reason__c,Release_End_Date__c,Release_Plan_Id__c,
                                Release_Start_Date__c,Status__c,Title__c,User_Detail__c from Release_Plan_Exceptions__c
                                where User_Detail__c =:userDetail[0].id and Old_RP_Records__c= false and Exception_with_ExistingRecord__c =true];
                                
        final_list.addAll(RPException_listold );
        final_list.addAll(RPException_listnew );
        final_list.addAll(RPException_listnew2 );
        if(RPException_listnew.size()==0){
                newRPDisplay=false;
        }
        if(RPException_listold.size()==0){
                oldRPDisplay=false;             
        }
        if(RPException_listnew2.size()==0){
                newExcepRPDisplay=false;             
        }
        system.debug('@@RPException_listold '+RPException_listold +'size'+RPException_listold.size());
        system.debug('@@RPException_listnew '+RPException_listnew +'size'+RPException_listnew.size());
        system.debug('@@RPException_listnew2 '+RPException_listnew2 +'size'+RPException_listnew2.size());
        system.debug(final_list.size());                                                                                               
    
    }
    public pageReference okbutton(){
    
    try{
        if(final_list != null && final_list.size() > 0){          
            Database.Deleteresult[] deleteResult  = Database.delete(final_list, false);
            system.debug('@@@Deleteresult[0].isSuccess()'+deleteResult);
            system.debug('@@@isSuccess()'+deleteResult.size());
              if (Deleteresult[0].isSuccess()){
                Pagereference PageRef = new Pagereference(System.Label.My_Latest_Wizard_Run_Release_Plan);                 
                 system.debug('@@PageRef'+PageRef);
                 return PageRef;
              }     
        }else{
            final_list.clear();
            Pagereference PageRef = new Pagereference(System.Label.My_Latest_Wizard_Run_Release_Plan);                 
             system.debug('@@PageRef'+PageRef);
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