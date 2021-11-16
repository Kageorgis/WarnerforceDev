/**
   @Author Cognizant
   @name CRM_CreateCreditNoteCtrl
   @CreateDate 1 March 2017
   @Description controller for create CreditNote and CreditNoteItems from Deal record
   @Version <1.0>
   @reference
*/
global class CRM_CreateCreditNoteCtrl {
    
    public boolean isValidDealStage{get; set;}
    // Constructor with StandardController as parameter
    public CRM_CreateCreditNoteCtrl(ApexPages.StandardController stdCon){
        String dealId = stdCon.getId();
        List<Opportunity> lstDeals = [Select stagename,co_op_closed__c From Opportunity Where Id =:dealId];
        if(!lstDeals.isEmpty() && lstDeals[0].stagename == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED && !lstDeals[0].co_op_closed__c){
            isValidDealStage = true;
        }
    }
    
    /**
     *  Method to create Credit Note and creditNoteItem from deal Record
     *  @name createCreditNote
     *  @param dealId,accountId - Id of the creditNote and account for which CreditNote needs to be created
     *  @return Credit_Note__c - CreditNote which is created
    **/
    @RemoteAction
    global static Credit_Note__c createCreditNote(Id dealId, Id accountId){
        
        List<Id> lstDealIds = new List<Id>();
        List<CRM_AddDealsOnCreditNoteController.DealWrapper> lstDealWrapper = new List<CRM_AddDealsOnCreditNoteController.DealWrapper>();
        List<Opportunity> lstDeals = new List<Opportunity>();
        
        //Fetch deal from dealId
        lstDeals = [SELECT Id,Co_op_Requested_Amount__c,CurrencyIsoCode,Name,Co_op_Balance__c,stagename, Promo_Start_Date__c,Recordtype.Name, Coop_Budget__c
                    FROM Opportunity WHERE Id = :dealId];
        if(!lstDeals.isEmpty() && lstDeals[0].Co_op_Requested_Amount__c == 0){
            throw new CRM_CreateCreditNoteCtrlException (System.Label.CRM_Create_CN_Invalid_CoopRequested_Amount);      
        }            
        //Insert CreditNote record for the account in deal
        Credit_Note__c creditNote = new Credit_Note__c();
        creditNote = insertCreditNote(accountId,lstDeals);
        
        for(Opportunity deal : lstDeals)
        {
            CRM_AddDealsOnCreditNoteController.DealWrapper dealWrapper = new CRM_AddDealsOnCreditNoteController.DealWrapper();
            dealWrapper.isSelected = true;
            dealWrapper.deal = deal;
            lstDealWrapper.add(dealWrapper);
            lstDealIds.add(deal.Id);
        }
        
        if(!lstDeals.isEmpty() && !lstDealWrapper.isEmpty() && !lstDealIds.isEmpty())
        {
          //Create creditNoteItem
            CRM_AddDealsOnCreditNoteController.createCreditNoteItems(creditNote.Id,lstDealWrapper,lstDealIds,lstDeals[0].CurrencyIsoCode);
            
        }
        return creditNote;
    }
    
    /**
     *  Method to insert Credit Note from deal Record
     *  @name createCreditNote
     *  @param accountId - Id of the creditNote and account for which CreditNote needs to be created
     *  @return Credit_Note__c - CreditNote which is created
    **/
    private static Credit_Note__c insertCreditNote(Id accountId,List<Opportunity> lstOfDeals){
      Credit_Note__c creditNote = new Credit_Note__c();
      if(!lstOfDeals.isEmpty()){
        creditNote.CurrencyIsoCode = lstOfDeals[0].CurrencyIsoCode;//UserInfo.getDefaultCurrency();
          creditNote.RecordTypeId = CRM_RecordTypeUtil.RT_CREDIT_NOTE_STANDARD;
          creditNote.Account__c = accountId;
          creditNote.Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED;
          if(lstOfDeals[0].Coop_Budget__c != null){
            creditNote.Coop_Budget__c = lstOfDeals[0].Coop_Budget__c;
          }else{
            throw new CRM_CreateCreditNoteCtrlException (System.Label.CRM_Budget_Not_Found_On_Deal);
          }
          try{
            if(creditNote != null){
              insert creditNote;
            }
          }catch(System.DMLException de){
            throw new CRM_CreateCreditNoteCtrlException (de.getDMLMessage(0));
          }
      }
      
        
        return creditNote;
    }
    
    public class CRM_CreateCreditNoteCtrlException extends Exception {}
   
}