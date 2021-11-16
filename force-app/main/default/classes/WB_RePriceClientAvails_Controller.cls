/*******************************************************************************************************************************************
* File Name     :   WB_RePriceClientAvails_Controller
* Description   :    
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     1 Oct.2015       CTS                  CH01: 1. Prevent the record split id Locat data or local data price code not available for client avail.
                                                2. 
* 2.0     4 Feb 2016       CTS                  ER-256 and ER-417 : Increase threshold of Re Price Wizard
********************************************************************************************************************************************/

global with sharing class WB_RePriceClientAvails_Controller{
    public Client_Avail__c obj;
    public string availids;
    public list<Client_Avail__c> selectedClientAvail_list{get;set;}
    public list<Schema.FieldSetMember> selectedClientAvail_list2 {get; set;}
    public Date datename;
    public list<Client_Avail_Exception__c> clientAvailException_listold;
    public list<Client_Avail_Exception__c> clientAvailException_listnew;
    public list<Client_Avail_Exception__c> clientAvailException_listfinal;
    //public list<User> userDetail = new list<User>(); Mahesh - replaced use of this variable by Userinfo.getUserId()
    public date previousEndDate;
    public boolean price_datechk {get; set;}
    public boolean showMessageParam=false;
    
    public String param{get;set;}     // Added for page redirect
    public string rpIdRedir{get;set;} // Added for page redirect
    public boolean stdPage{get;set;}  // Added for page redirect
    public String Message{get; set;}  // CH01: add information message on section if any client avails are prevented to split.
    list<string> clientIds;//256
    public boolean clientAvailScroller {get;set;}
    public boolean hidePageBlocks{get; set;}
    public boolean isSeasonReprice=false;
    
    public WB_RePriceClientAvails_Controller(ApexPages.StandardSetController controller) {

        this.obj =(Client_Avail__c )controller.getRecord();
        hidePageBlocks = false;
        
        price_datechk = false;
        availids = ApexPages.currentPage().getParameters().get('ID');
        clientIds = new list<string>();
        if(availids != null){
            clientIds = availids.split(',');
        }
        
        /* ER-256 : Start */
        String UniqueId = ApexPages.currentPage().getParameters().get('UNIQUEID');
        system.debug('UNIQUEID ====> ' + UniqueId);
        if(UniqueId != null && UniqueId != ''){
            List<Client_Avail_Id_Store__c> CAIDStoreList = [
                select Id, ID_Store__c
                  from Client_Avail_Id_Store__c
                 where Key__c = :UniqueId limit 1
            ];
            system.debug('CAIDStoreList ====> ' + CAIDStoreList.size() + CAIDStoreList[0].ID_Store__c);
            if(CAIDStoreList != null && CAIDStoreList.size() > 0){
                clientIds = CAIDStoreList[0].ID_Store__c.split(',');
            }
        }
        /* ER-256 : End */
        
        system.debug('clientIds ====: ' + clientIds);
        
        clientAvailScroller = (clientIds.size() > 10) ? true : false;
        
        selectedClientAvail_list2 = Schema.SObjectType.Client_Avail__c.fieldSets.getMap().get('RePriceClientAvailsController').getFields();
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : selectedClientAvail_list2){
            query += f.getFieldPath()+ ', ';
        }
        
        query += 'Id, Change_Context__c,Title_Content_Type__c FROM Client_Avail__c where Id IN:clientIds';
        selectedClientAvail_list = Database.query(query);
        for(Client_Avail__c ca : selectedClientAvail_list)
        {
            if(ca.Title_Content_Type__c == 'Season')
                isSeasonReprice=true;
        }
       // logic for redirect
        stdPage = false;
        param = ApexPages.currentPage().getParameters().get('param');
        
        if(param=='std'){
            stdPage=true;
            rpIdRedir = clientIds [0];
        }
    }
    
    public void deleteClientAvailRec(){
        //Code for custom setting : first delete the existing record then :record insertion 
        integer clientExceptionCount = [SELECT count() FROM Client_Avail_Exception__c];
        
        if(clientExceptionCount > 0){
            List<Client_Avail_Exception__c> existing = [SELECT Id From Client_Avail_Exception__c where User_Detail__c =:Userinfo.getUserId()];
            delete existing;
        }
    }
    
    public pagereference updateprice(){
        //Calculate Threshold
        //Call batch
        //Origional Method
        if(obj.Effective_Price_Date__c != null){
            system.debug('======== clientIds.size() : ' + clientIds.size());
            if(clientIds.size() > Integer.valueOf(Label.CA_Reprice_Threshold) || isSeasonReprice){
                system.debug('======== Calling Batch ========');
                hidePageBlocks = true;
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.INFO,label.Repricing_Client_Avail_Batch_Process));
                WB_Batch_RePriceClientAvails objWB_Batch_RePriceClientAvails = new WB_Batch_RePriceClientAvails(obj, clientIds, Userinfo.getUserId());
                if(!Test.isRunningTest())
                    database.executeBatch(objWB_Batch_RePriceClientAvails, 15);
            }else{
                system.debug('======== Regular Execution ========');
                WB_RePriceClientAvails_Handler objRePriceClientAvails_Handler = new WB_RePriceClientAvails_Handler();
                map<string, List<String>> messageMap = objRePriceClientAvails_Handler.updateprice(obj, clientIds, Userinfo.getUserId(),false);
                
                if(messageMap != null && messageMap.size() > 0){
                    if(messageMap.containsKey('pageMessages') && messageMap.get('pageMessages').size() > 0  && messageMap.get('pageMessages')[0].contains('/apex/')){
                        if(messageMap.get('pageMessages')[0].contains('/apex/')){
                            return new Pagereference(messageMap.get('pageMessages')[0]);
                        }else{
                            for(String message : messageMap.get('pageMessages')){
                                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,message));
                            }
                        }
                    }else{
                        for(String message : messageMap.get('pageMessages')){
                            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,message));
                        }
                    }
                }
                /*if(messageList != null && messageList.size() > 0){
                    if(messageList[0].contains('/apex/')){
                        return new Pagereference(messageList[0]);
                    }else{
                        for(String message : messageList){
                            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,message));
                        }
                    }
                }*/
            }
        }else{
            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Enter_effective_date_on_reprice_wizard));
        }
        return null;
    }
    
    public pageReference Bulkcancel(){
        // pageReference PageRef= new Pagereference(System.Label.Redirect_to_All_Client_avail);
        // return PageRef;
        pageReference PageRef= new Pagereference('');
        if(param=='std'){
            PageRef = new Pagereference('/'+rpIdRedir);
        }
        else
            PageRef = new Pagereference(System.Label.Redirect_to_All_Client_avail);
        return PageRef;
    }
}