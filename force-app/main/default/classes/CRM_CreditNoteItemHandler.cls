/** 
   * @Author: cognizant Team
   * @Description:  
   * @Date Created:  03 March 2017
   * @Version: 1.0 
   */
public with sharing class CRM_CreditNoteItemHandler {
    public static Set<String> cnPhysicalRecordTypes = new Set<String>{CRM_AppConstants.CREDIT_NOTE_PHYSICAL_RC_API_NAME, CRM_AppConstants.CREDIT_NOTE_PHYSICAL_REVERSE_RC_API_NAME};
    
    public static void rollUpAmountToDealCreditNote(List<Credit_Note_Item__c> lstCreditNoteItem){
        List<AggregateResult> lstAllCreditNoteItems = new List<AggregateResult>();
        Set<Id> setCreditNoteId = new Set<Id>();
        Set<Id> setDealId = new Set<Id>();
        Map<String,String> mapCurrencyIsoCode = new Map<String,String>();       
        //Fetch all Credit Notes
        for(Credit_Note_Item__c cnItem : lstCreditNoteItem){
            setCreditNoteId.add(cnItem.Credit_Note__c);
            setDealId.add(cnItem.Deal__c);
            mapCurrencyIsoCode.put(cnItem.Deal__c+'-'+cnItem.Credit_Note__c,cnItem.CurrencyIsoCode);
        }
        
        System.debug('CreditNoteid'+setCreditNoteId);
        if(!setCreditNoteId.isEmpty()){
            //Fetch All the CreditNoteItem for above creditNotes
            lstAllCreditNoteItems = [SELECT Credit_Note__c,Deal__c,SUM(Amount__c)sumAmount FROM Credit_Note_Item__c 
                                     WHERE Credit_Note__c IN :setCreditNoteId AND Deal__c IN :setDealId
                                     Group by Credit_Note__c,Deal__c];
            System.debug('Aggregate Result'+lstAllCreditNoteItems);                                  
            if(!lstAllCreditNoteItems.isEmpty()){
                //Roll up the amount on DealCreditNote
                updateDealCreditNote(lstAllCreditNoteItems,mapCurrencyIsoCode);
            }
        }       
    }
    
    private static void updateDealCreditNote(List<AggregateResult> lstAllCreditNoteItems,Map<String,String> mapCurrencyIsoCode){
        List<DealCreditNote__c> lstDealCreditNotes = new List<DealCreditNote__c>();
        for(AggregateResult cnItem :lstAllCreditNoteItems){
            String uniqueKey = (String)cnItem.get('Deal__c')+'-'+(String)cnItem.get('Credit_Note__c');
            String dataCurrency = mapCurrencyIsoCode.containsKey(uniqueKey) ? mapCurrencyIsoCode.get(uniqueKey) : UserInfo.getDefaultCurrency();
            System.debug('UNIQUEKEY'+uniqueKey);
            DealCreditNote__c dealCN = new DealCreditNote__c();
            dealCN.Unique_Key__c = uniqueKey;
            dealCN.Opportunity__c = Id.valueOf((String)cnItem.get('Deal__c'));
            dealCN.Credit_Note__c = Id.valueOf((String)cnItem.get('Credit_Note__c'));
            dealCN.Credit_Note_Amount__c = CRM_ApplicationUtility.convertOrgCurrency((Decimal)cnItem.get('sumAmount'), dataCurrency);
            system.debug('dealCN.Credit_Note_Amount__c'+dealCN.Credit_Note_Amount__c);
            lstDealCreditNotes.add(dealCN);
        }
        
        List<Database.UpsertResult> lstSaveResults = Database.upsert(lstDealCreditNotes,DealCreditNote__c.Unique_Key__c,false);
        for(Database.UpsertResult sr : lstSaveResults){
            if(!sr.isSuccess()){
                for(Database.Error err : sr.getErrors()) {
                         throw new CRM_CreditNoteItemHandlerException(err.getMessage());
                 }
            }
        }       
    }
    
    /** 
	*  @description: - This method is used to set the currency code on credit note item as per the currency code on parent credit note.
	*  					Applicable only for Physical & Physical Reverse Credit Note Record Types
	*  @name: setDefaultCurrency
	*  @return: none
	*/
    public static void setDefaultCurrency(List<Credit_Note_Item__c> lstCreditNoteItem){
        Set<ID> cnIds = new Set<ID>();
        Map<ID, String> cnCurrencyMap = new Map<ID, String>(); //Map to store Credit Note Record Id (as key) & the Currency Code (as value)
        Map<ID, String> cnRecordTypeNameMap = new Map<ID, String>(); //Map to store Credit Note Record Id (as key) & the Record Type API Name (as value)
        
        //Get all the Credit Notes belong to the CNIs
        for(Credit_Note_Item__c cni :lstCreditNoteItem){
            cnIds.add(cni.Credit_Note__c);
        }
        //Create a Map of all CN and it's CurrencyISOCode, Map of all CN and it's RecordTypeId
        List<Credit_Note__c> creditNotes = [Select ID, CurrencyISOCode, RecordTypeId, RecordType.DeveloperName from Credit_Note__c where ID IN :cnIds];
        for(Credit_Note__c cn :creditNotes){
            cnCurrencyMap.put(cn.Id, cn.CurrencyISOCode);
            cnRecordTypeNameMap.put(cn.Id, cn.RecordType.DeveloperName);
        }
        //Check the Record Type Dev Name of the Credit Note Item's (CNI) corresponding Credit Note (CN). If its Physical, then set the CNI CurrencyISOCode as per CN CurrencyISOCode
        for(Credit_Note_Item__c cni :lstCreditNoteItem){
            if(cnPhysicalRecordTypes.contains(cnRecordTypeNameMap.get(cni.Credit_Note__c))){
                cni.CurrencyISOCode = cnCurrencyMap.get(cni.Credit_Note__c);
            }
        }
    }
    
    public class CRM_CreditNoteItemHandlerException extends Exception{}    
}