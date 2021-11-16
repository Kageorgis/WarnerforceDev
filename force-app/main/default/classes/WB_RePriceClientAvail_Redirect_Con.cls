public with sharing class WB_RePriceClientAvail_Redirect_Con{

public list<Client_Avail_Exception__c> clientAvailException_listold {get; set;}
public list<Client_Avail_Exception__c> clientAvailException_listnew {get; set;}
public list<Client_Avail_Exception__c> final_list = new list<Client_Avail_Exception__c>();
public Boolean showMessage{get; set;}
public list<User> userDetail = new list<User>();

    public WB_RePriceClientAvail_Redirect_Con(ApexPages.StandardController  controller){
    showMessage = ApexPages.currentPage().getParameters().get('sm').equals('true');
    clientAvailException_listold = new list<Client_Avail_Exception__c>();
    clientAvailException_listnew = new list<Client_Avail_Exception__c>();
    
    userDetail =[   SELECT id,Name  from User where id =: Userinfo.getUserId() ];
    
    clientAvailException_listold = [SELECT Name,User_Detail__c,Client_Avail_ID__c,Title__c,Account__c,Country__c,Language__c,Channel__c,
                                Format__c,ClientAvail_Start_Date__c,ClientAvail_End_Date__c,Status__c,Price_Tier__c,SR_Price__c,
                                WS_Price__c,Episode_Price__c,SR_Per_Episode__c,Old_Price_Records__c from Client_Avail_Exception__c 
                                where User_Detail__c =:userDetail[0].id and Old_Price_Records__c =: true];
                                
    clientAvailException_listnew = [SELECT Name,User_Detail__c,Client_Avail_ID__c,Title__c,Account__c,Country__c,Language__c,Channel__c,
                                Format__c,ClientAvail_Start_Date__c,ClientAvail_End_Date__c,Status__c,Price_Tier__c,SR_Price__c,
                                WS_Price__c,Episode_Price__c,SR_Per_Episode__c,Old_Price_Records__c from Client_Avail_Exception__c 
                                where User_Detail__c =:userDetail[0].id and Old_Price_Records__c =: false];
                                
    final_list.addAll(clientAvailException_listold);
    final_list.addAll(clientAvailException_listnew);
    
    }
    
    public pageReference okbutton(){

     try{
        if(final_list != null && final_list.size() > 0){          
            Database.Deleteresult[] deleteResult  = Database.delete(final_list, false);
            
              if (Deleteresult[0].isSuccess()){
                Pagereference PageRef = new Pagereference(System.Label.Redirect_to_All_Client_avail);                 
                 return PageRef;
              }     
        }

    } 
    catch(Exception e) 
    {
    }
    return null;        
    }//end of okbutton function

}