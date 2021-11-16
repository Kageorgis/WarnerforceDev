public with sharing class CRM_CreditNoteHandler {
    public static void updateDealProduct(List<Credit_Note__c> lstNewCreditNotes,Map<Id,Credit_Note__c> mapOldCreditNotes){
        
        set<Id> setCnIds = new set<Id>();
        List<Credit_Note_Item__c> lstCreditNoteItems = new List<Credit_Note_Item__c>();
        
        for(Credit_Note__c cn : lstNewCreditNotes){
            if(
                (cn.Status__c == CRM_AppConstants.CREDIT_NOTE_STATUS_READY_TO_PAY || 
                   (
                        (cn.Status__c == CRM_AppConstants.CREDIT_NOTE_STATUS_FAILED || cn.Status__c == CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED) && 
                        mapOldCreditNotes.get(cn.Id).Status__c == CRM_AppConstants.CREDIT_NOTE_STATUS_READY_TO_PAY &&
                        mapOldCreditNotes.get(cn.Id).Status__c != CRM_AppConstants.CREDIT_NOTE_STATUS_AWAITING_APPROVAL && 
                        CRM_AppConstants.GERMANY_SALES_ORGS.contains(cn.Account_Sales_Organization__c)
                    )
                ) && 
                cn.Status__c != mapOldCreditNotes.get(cn.Id).Status__c
            ){
                setCnIds.add(cn.Id);
            }
        }
        
        if(!setCnIds.isEmpty()){
            integer count = 0;
            List<Credit_Note_Item__c> lstCNI = [SELECT Id,Deal__c,Deal_Product_Id__c,Amount__c,Customer_Reference_Number__c ,Credit_Note__r.Status__c,Credit_Note__r.RecordTypeId From Credit_Note_Item__c WHERE Credit_Note__c IN :setCnIds Limit 50000];
            
            integer tempChunkSize = CRM_CreditNote_Queueable__c.getInstance('CRM_UpdateDealProductCoopSpent') != null ? Integer.valueOf(CRM_CreditNote_Queueable__c.getInstance('CRM_UpdateDealProductCoopSpent').Chunk_Size__c) : 200;
            integer chunkSize = lstCNI.size() < tempChunkSize ? lstCNI.size() : tempChunkSize;
            
            for(Credit_Note_Item__c cni : lstCNI){
                count++;
                if(count < chunkSize){
                    system.debug('count If : '+count);
                    lstCreditNoteItems.add(cni);
                }else{
                    lstCreditNoteItems.add(cni);
                    system.debug('count else : '+count);
                    system.debug('CNI List : '+lstCreditNoteItems.size());
                    System.enqueueJob(new CRM_UpdateDealProductCoopSpent(lstCreditNoteItems));
                    lstCreditNoteItems  = new List<Credit_Note_Item__c>();
                    count = 0;
                }
            }
            if(lstCreditNoteItems.size() < chunkSize){
                System.enqueueJob(new CRM_UpdateDealProductCoopSpent(lstCreditNoteItems));
            }
            System.debug('Limit : '+Limits.getQueueableJobs());
        }
    }
    
    /**
    *  @Description - derive the correct Sold To/Ship to relationship on Credit note.
    *  @name - UpdateShipToAccountOnCreditNote
    *  @return - void
    *  @param - List of creditnotes
    */
    public static void UpdateShipToAccountOnCreditNote(List<Credit_Note__c> lstNewCreditNotes){
        set<Id> setAcctIDs = new set<Id>();
        for (Credit_Note__c objCreditNote: lstNewCreditNotes){
            if (objCreditNote.Account__c != null){
                setAcctIDs.add(objCreditNote.Account__c);            
            }
        }    
        map<Id,List<Account>> mapChildShipToAccounts = new map<Id,List<Account>>();
        List<Account> childAccountList = [select Id,Sold_To_Customer__c from Account where Sold_To_Customer__c IN: setAcctIDs];
        for(Account acc:childAccountList){
            if(!mapChildShipToAccounts.containskey(acc.Sold_To_Customer__c))
            {
                List<Account> ChildAccounts =new List<Account>();
                ChildAccounts.add(acc);
                mapChildShipToAccounts.put(acc.Sold_To_Customer__c,ChildAccounts);
            }else{
                mapChildShipToAccounts.get(acc.Sold_To_Customer__c).add(acc);
            }
        }
        Account objAcct = new Account();
        Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT Id,Sales_Organization__c,Ship_To__c,Digital_Country_Code__c,RecordTypeId//added recordTypeId,Sales org and digital country code in query.
                                                                            FROM Account 
                                                                            WHERE Id IN: setAcctIDs]);
        
        
                                                                            
        for(Credit_Note__c objCreditNote: lstNewCreditNotes){
            if (mapAccount != null && objCreditNote.Account__c != null && mapAccount.containsKey(objCreditNote.Account__c)){
                
                objAcct = mapAccount.get(objCreditNote.Account__c);
                
                if(CRM_AppConstants.US_SALES_ORGS.contains(mapAccount.get(objCreditNote.Account__c).Sales_Organization__c)){
                    objCreditNote.Ship_To_Account__c = mapAccount.get(objCreditNote.Account__c).Id;
                    objCreditNote.PO_Number__c ='.';
                }
                
                else {           
                    
                    if(objAcct != null && objAcct.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO && (CRM_AppConstants.GERMANY_SALES_ORGS.contains(objAcct.Sales_Organization__c) || CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(objAcct.Digital_Country_Code__c))){
                        objCreditNote.Ship_To_Account__c = objAcct.Id;
                    }
                    else if(objAcct != null && objAcct.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO && (CRM_AppConstants.GERMANY_SALES_ORGS.contains(objAcct.Sales_Organization__c) || CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(objAcct.Digital_Country_Code__c))){
                        if(mapChildShipToAccounts.containsKey(objAcct.id)) {
                            if(mapChildShipToAccounts.get(objAcct.id).size() == 1)
                                objCreditNote.Ship_To_Account__c = mapChildShipToAccounts.get(objAcct.Id)[0].Id;
                        }else if (mapChildShipToAccounts.isEmpty() && objAcct.ship_to__c == TRUE) { //Ankita US#793 Italy Changes
                            objCreditNote.Ship_To_Account__c = objAcct.Id;
                        }/*else{
                            objCreditNote.Ship_To_Account__c = objAcct.Id;
                        }*/ 
                    }
                } 
            }
        }
    }

    /**
    *  @Description - Restrict to delete Credit note having status equal to Ready to Pay and Paid
    *  @name - restrictToDeleteApprovedCN
    *  @return - void
    *  @param - List of creditnotes
    */
    public static void restrictToDeleteApprovedCN(List<Credit_Note__c> lstOldCreditNotes){
        for(Credit_Note__c objCreditNote: lstOldCreditNotes){
            if(CRM_AppConstants.GERMANY_SALES_ORGS.contains(objCreditNote.Account_Sales_Organization__c)){
                 CRM_Functional_Permissions__c CRMFP = CRM_Functional_Permissions__c.getInstance(userinfo.getProfileId());
                 if(objCreditNote.Status__c == CRM_AppConstants.CREDIT_NOTE_STATUS_READY_TO_PAY || 
                    objCreditNote.Status__c == CRM_AppConstants.CREDIT_NOTE_STATUS_PAID){
                    if(!CRMFP.Delete_Approved_Credit_Note_Permission__c){
                        objCreditNote.addError(System.Label.CRM_Restrict_To_Delete_Approved_CN);
                    }
                }
                //Added as part of US : 802 : 2018-CAS Funding-Pricing Project
                else if(objCreditNote.Status__c != CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED && 
                         objCreditNote.Status__c != CRM_AppConstants.CREDIT_NOTE_STATUS_REVISED){
                    objCreditNote.addError(System.Label.CRM_Restrict_To_Delete_CN_Error_Msg);              
                }
            }else if(CRM_AppConstants.US_SALES_ORGS.contains(objCreditNote.Account_Sales_Organization__c)){
                if( objCreditNote.Status__c != CRM_AppConstants.DEAL_PRODUCT_STATUS_PLANNED ){
                    objCreditNote.addError(System.Label.CRM_Restrict_To_Delete_Without_Planned_CN);
                }
            }
        }
    }
    
   /**
    *  @Description - to update status on Credit note.
    *  @name - updateCreditNoteStatus
    *  @return - void
    *  @param - List of creditnotes
    */
    public static void updateCreditNoteStatus(List<Credit_Note__c> lstNewCreditNotes,Map<Id,Credit_Note__c> mapOldCreditNotes){
        
        for(Credit_Note__c newCredNote : lstNewCreditNotes) {
            Credit_Note__c oldCredNote = mapOldCreditNotes.get(newCredNote.Id);
            
            if(newCredNote.Credit_Note_Header_Status__c != oldCredNote.Credit_Note_Header_Status__c) {
                if(newCredNote.Credit_Note_Header_Status__c == CRM_AppConstants.CREDIT_NOTE_HEADER_STATUS_IN_SAP
                    && newCredNote.Status__c != CRM_AppConstants.CREDIT_NOTE_STATUS_PAID) {
                    
                    newCredNote.Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_PAID;       
                }
                else if(newCredNote.Credit_Note_Header_Status__c == CRM_AppConstants.CREDIT_NOTE_HEADER_STATUS_IN_FAILED
                    && newCredNote.Status__c != CRM_AppConstants.CREDIT_NOTE_STATUS_FAILED){
                        
                    newCredNote.Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_FAILED;
                }
                else if(newCredNote.Credit_Note_Header_Status__c == CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED
                    && newCredNote.Status__c != CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED){
                        
                    newCredNote.Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED;
                }
                
            }
            // Allow changing the Account on Credit note if no Credit Note Items are present,else throw error thatthe account cannot be changed
            if( newCredNote.Account_Sales_Organization__c != null && CRM_AppConstants.US_SALES_ORGS.contains(newCredNote.Account_Sales_Organization__c) &&
                oldCredNote.Account__c != NULL && newCredNote.Account__c != NULL && newCredNote.Account__c != oldCredNote.Account__c ){
                if(newCredNote.Credit_Note_Item_Count__c == 0){
                    newCredNote.Ship_To_Account__c = newCredNote.Account__c;
                }else {
                    newCredNote.addError(System.Label.CRM_Credit_Note_Account_Change_Error);
                }
            }
        }
    } 
}