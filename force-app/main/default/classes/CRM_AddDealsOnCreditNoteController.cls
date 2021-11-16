/**
   @Author Cognizant
   @name CRM_AddDealsOnCreditNoteController
   @CreateDate 1 March 2017
   @Description controller for vf to add/remove deals from creditNote records
   @Version <1.0>
   @reference
*/
global with sharing class CRM_AddDealsOnCreditNoteController {
    public boolean isReadOnly{get; set;}
    // Constructor with StandardController as parameter
    public CRM_AddDealsOnCreditNoteController(ApexPages.StandardController stdCon) {
        Id cnId = ApexPages.currentPage().getParameters().get('id');
        if(cnId != null){
            List<Credit_Note__c> lstCreditNote = new List<Credit_Note__c>();
            lstCreditNote = [SELECT Status__c FROM Credit_Note__C WHERE Id =:cnId];
            if(!lstCreditNote .isEmpty()){
                if(lstCreditNote[0].Status__c != CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED && lstCreditNote[0].Status__c != CRM_AppConstants.CREDIT_NOTE_STATUS_REVISED){
                    isReadOnly = true;
                }
            }
        }
    }

    /**
     *  Method to fetch deals to be displayed on creditnote record
     *  @name getDeals
     *  @param creditNoteId,cnAccountId - Id of the creditNote and account for which deals needs to fetched
     *  @return DealWrapper[] - list of Deals to be made available for user selection
     */
    @RemoteAction
    global static DealWrapper[] getDeals(Id creditNoteId, Id cnAccountId,Id budgetId) {
        List<DealWrapper> lstDeals = new List<DealWrapper>();
        
        if(creditNoteId != null && cnAccountId != null && budgetId != null){
            for(Opportunity deal : [SELECT Id,Co_op_Requested_Amount__c,Name,Co_op_Balance__c,stagename,Co_op_Spent__c, Promo_Start_Date__c,Recordtype.Name, Coop_Budget__c,Coop_Budget__r.Start_Date__c,Coop_Budget__r.End_Date__c
                                    FROM Opportunity 
                                    WHERE StageName = :CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED 
                                    AND AccountId = :cnAccountId 
                                    AND Coop_Budget__c = :budgetId 
                                    AND Co_op_Requested_Amount__c > 0
                                    AND Co_op_Closed__c = false]) {
                Date budgetStartDate = deal.Coop_Budget__r.Start_Date__c;
                Date budgetEndDate = deal.Coop_Budget__r.End_Date__c;
                if(deal.Promo_Start_Date__c >= budgetStartDate && deal.Promo_Start_Date__c <= budgetEndDate ){
                    DealWrapper dealwrapper = new DealWrapper();
                    dealwrapper.isSelected = false;
                    dealwrapper.deal = deal;
                    lstDeals.add(dealwrapper);
                }
            }
            
        }
        
        return lstDeals;
    }

    /**
     *  Method to upsert CreditNoteItems
     *  @name createCreditNoteItems
     *  @param cnId,lstDealWrapper,listDealIds - Id of the creditNote and deals for which creditNoteItems need to created
     *  @return Boolean - flag to indicate the result of the process/operation
     */
    @RemoteAction
    global static void createCreditNoteItems(Id cnId, List<DealWrapper> lstDealWrapper,List<Id> listDealIds,String cnCurremcy) {
        system.debug('List Deals for creating CreditNoteItems'+lstDealWrapper);
        List<Credit_Note_Item__c> listCreditNoteItemsToCreate = new List<Credit_Note_Item__c>();
        List<Credit_Note_Item__c> listCreditNoteItemsToRemove = new List<Credit_Note_Item__c>();
        //List<DealCreditNote__c>   lstDealCreditNote   = new List<DealCreditNote__c>();
        List<OpportunityLineItem> lstDealProducts = new List<OpportunityLineItem>();
        
        //Get existing DealCreditNote records based on creditnoteitemid and dealId
        Map<String,DealCreditNote__c> mapDealCreditNote = getExistingDealCreditNote(cnId,listDealIds);
        
        //Insert a new record in DealCreditNote junction object
        insertDealCreditNote(cnId,lstDealWrapper,mapDealCreditNote,cnCurremcy);
        
        if(!listDealIds.isEmpty()){
            
            for(OpportunityLineItem oli : [SELECT Id,OpportunityId,Co_op_Balance__c,Co_op_Requested_Amount__c,Name,Product2Id 
                               FROM OpportunityLineItem 
                               WHERE OpportunityId IN :listDealIds]){
                    
                    Credit_Note_Item__c credNoteItem = new Credit_Note_Item__c();
                    credNoteItem.Credit_Note__c = cnId;
                    credNoteItem.Deal__c = oli.OpportunityId;
                    credNoteItem.Deal_Product_Id__c = oli.Id;
                    credNoteItem.Deal_Product_Name__c = oli.Name;
                    credNoteItem.Requested_Co_op_Amount__c = oli.Co_op_Requested_Amount__c;
                    credNoteItem.Amount__c = oli.Co_op_Balance__c > 0 ? oli.Co_op_Balance__c : 0;
                    credNoteItem.Unique_Id__c = cnId+'-'+oli.OpportunityId+'-'+oli.Id;
                    credNoteItem.Product__c = oli.Product2Id;
                    credNoteItem.CurrencyIsoCode = cnCurremcy;
                    listCreditNoteItemsToCreate.add(credNoteItem);          
            }
        }
        System.debug('ListCreditNoteItems'+listCreditNoteItemsToCreate);
        List<Database.UpsertResult> lstSaveResults = Database.upsert(listCreditNoteItemsToCreate,Credit_Note_Item__c.Unique_Id__c,false);
        for(Database.UpsertResult upr : lstSaveResults){
            if(!upr.isSuccess()){
                for(Database.Error err : upr.getErrors()) {
                         throw new CRM_AddDealsOnCreditNoteControllerException(err.getMessage());
                 }
            }
        }
        
    }
    
    /**
     *  Method to insert DealCreditNote record
     *  @name insertDealCreditNote
     *  @param cnId,lstDealWrapper,mapDealCreditNote - Id of the creditNote and deals for which DealCreditNote need to created
     *  @return none
     */
    private static void insertDealCreditNote(Id cnId,List<DealWrapper> lstDealWrapper,Map<String,DealCreditNote__c> mapDealCreditNote,String cnCurremcy){
        
        List<DealCreditNote__c> lstDealCreditNote   = new List<DealCreditNote__c>();
        
        if(!lstDealWrapper.isEmpty())
        {
            for(DealWrapper dwrap: lstDealWrapper)
             {
                String currDealCreditNoteKey = cnId+'-'+dwrap.deal.Id;
    
                if(dwrap.isSelected == true && !mapDealCreditNote.containsKey(currDealCreditNoteKey)) 
                {
                        DealCreditNote__c dealCreditNote = new DealCreditNote__c();
                        dealCreditNote.Opportunity__c = dwrap.deal.Id;
                        dealCreditNote.Credit_Note__c = cnId;
                        dealCreditNote.Unique_Key__c = dwrap.deal.Id+'-'+cnId;
                        dealCreditNote.CurrencyIsoCode = cnCurremcy;
                        lstDealCreditNote.add(dealCreditNote);
                        
                }
            }
        }
        
        if(!lstDealCreditNote.isEmpty()){
                insert lstDealCreditNote;
            }
            
    }

    /**
     *  Method to fetch existing junction object record
     *  @name getExistingDealCreditNote
     *  @param cnId,listDealIds - Id of the creditNote and deals for which existing DealCreditNote__c need to be checked
     *  @return Map<String, DealCreditNote__c> - Map of the DealCreditNote__c records
     */
    private static Map<String, DealCreditNote__c> getExistingDealCreditNote(Id cnId,List<Id> listDealIds){
        Map<String, DealCreditNote__c> mapCurrentDealCreditNotes = new Map<String, DealCreditNote__c>();
        
        //Fetch existing DealCreditNote record for DealId and CreditNoteId combination
        for(DealCreditNote__c dealCredNote  : [SELECT Id, Opportunity__c, Credit_Note__c
            FROM DealCreditNote__c
            WHERE Credit_Note__c = :cnId AND Opportunity__c IN :listDealIds] ){

            String recordKey = dealCredNote.Credit_Note__c + '-' +dealCredNote.Opportunity__c;
            mapCurrentDealCreditNotes.put(recordKey, dealCredNote);
        }

        return mapCurrentDealCreditNotes;
    }
    
    
    /**
     *  Method to get Deals that needs to removed from CreditNote record page
     *  @name getDealsForDeletion
     *  @param cnId - Id of the creditNote record for whicih existing deal records to be fetched
     *  @return List<DealWrapper> - List of the existing Deal records
     */
    @RemoteAction
    global static List<DealWrapper> getDealsForDeletion(Id cnId){
        
        List<DealWrapper> lstDealWrapper = new List<DealWrapper>();
        List<Opportunity> lstDeals = new List<Opportunity>();
        List<Id> lstOpportunityIds = new List<Id>();
        List<DealCreditNote__c> lstDealCreditNotes = new List<DealCreditNote__c>();
        
        //Fetch opportunityId from junction object using creditNoteId
        lstDealCreditNotes =[SELECT Opportunity__c FROM DealCreditNote__c WHERE Credit_Note__c =:cnId];
        
        for(DealCreditNote__c dealCN : lstDealCreditNotes){
            lstOpportunityIds.add(dealCN.Opportunity__c);
        }
        
        //Fetch Opportunity using opportunityId obtained from above
        lstDeals = [SELECT Id,Co_op_Requested_Amount__c,Name,Co_op_Balance__c,stagename, Promo_Start_Date__c,Recordtype.Name, Coop_Budget__c
                                            FROM Opportunity WHERE Id IN :lstOpportunityIds];
        System.debug ('Size of DealCreditNoteList'+lstDealCreditNotes.size());
        for(Opportunity deal : lstDeals){
            DealWrapper dwrap = new DealWrapper();
            dwrap.isSelected = false;
            dwrap.deal = deal;
            lstDealWrapper.add(dWrap);
        }
        return lstDealWrapper;
    }
    
    /**
    *  Method to remove Deals from CreditNote record page and Delete the corresponding CreditNoteItem
    *  @name removeDealsFromCreditNote
    *  @param cnId,lstDealWrapper - Deals of the creditNote that needs to be removed
    *  @return none
    *  @Throw CRM_AddDealsOnCreditNoteControllerException
    */
    @RemoteAction
    global static void removeDealsFromCreditNote(Id cnId, List<DealWrapper> lstDealWrapper){
        
        List<DealCreditNote__c> lstDealCreditNotes = new List<DealCreditNote__c>();
        List<Credit_Note_Item__c> lstCreditNoteItems = new List<Credit_Note_Item__c>();
        List<Opportunity> lstDeals = new List<Opportunity>();
        
        for(DealWrapper dWrap : lstDealWrapper){
            if(dWrap.isSelected == true){
                lstDeals.add(dWrap.deal);
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        try{
            //Delete the junction object
            lstDealCreditNotes = [SELECT Id FROM DealCreditNote__c WHERE Credit_Note__c =:cnId AND Opportunity__c IN :lstDeals];
            
            if(lstDealCreditNotes.size() > 0){
                delete lstDealCreditNotes;
            }
                
            //Delete CreditNoteItem
            lstCreditNoteItems = [SELECT Id FROM Credit_Note_Item__c WHERE Credit_Note__c =:cnId AND Deal__c IN :lstDeals];
            
            if(lstCreditNoteItems.size() > 0){
                delete lstCreditNoteItems;
            }
                
        }catch(System.DMLException e){
            Database.rollback(sp);
            throw new CRM_AddDealsOnCreditNoteControllerException (e.getDmlMessage(0));
        }catch(Exception e){
            Database.rollback(sp);
            throw new CRM_AddDealsOnCreditNoteControllerException (e.getMessage());
        }
   }


    /* Wrapper class to be used as javascript remoting object */
    global class DealWrapper {
        global Boolean isSelected {get;set;}
        global Opportunity deal {get;set;}  
    }
    
    /*  
    *  name getUserDateFormat: e.g. M/d/yyyy
    *  param none
    *  return string
    *  throw none
    */  
    global String getUserDateFormat(){
        return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
    }
    public class CRM_AddDealsOnCreditNoteControllerException extends Exception {} 
}