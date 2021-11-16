/**
   @Author Cognizant
   @name CRM_EditAllCreditNoteItemsCtrl
   @CreateDate 1 March 2017
   @Description controller for vf to add Edit All CreditNoteItem in Credit Note Records
   @Version <1.0>
   @reference 
*/

global with sharing class CRM_EditAllCreditNoteItemsCtrl {
    public boolean isReadOnly{get; set;}
    public string recordName{get; set;}
    public String cnCurrencyCode{get; set;}
    global CRM_EditAllCreditNoteItemsCtrl(ApexPages.StandardController stdCon){
        Id cnId = ApexPages.currentPage().getParameters().get('cnId');
        if(cnId != null){
            List<Credit_Note__c> lstCreditNote = new List<Credit_Note__c>();
            lstCreditNote = [SELECT Id,Name,Status__c,CurrencyIsoCode FROM Credit_Note__C WHERE Id =:cnId];
            if(!lstCreditNote .isEmpty()){
                recordName = lstCreditNote[0].Name;
                cnCurrencyCode = lstCreditNote[0].CurrencyIsoCode;
                if(lstCreditNote[0].Status__c != CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED && lstCreditNote[0].Status__c != CRM_AppConstants.CREDIT_NOTE_STATUS_REVISED){
                	isReadOnly = true;
                }
            }
        }
    }
    
    /**
     *  Method
     *  @name getCreditNoteItems
     *  @param cnId - Id of the creditNote for which CreditNoteItems needs to fetched
     *  @return DealCreditNoteItemWrapper - DealCreditNoteItemWrapper to be made available for user selection
     */
    
    @RemoteAction
    global static DealCreditNoteItemWrapper getCreditNoteItems(Id cnId){
        DealCreditNoteItemWrapper dealCNIWrapper = new DealCreditNoteItemWrapper();
        Map<Id,List<CreditNoteItemWrapper>> mapdealCNIWrapper = new Map<Id,List<CreditNoteItemWrapper>>();
        List<CreditNoteItemWrapper> lstCNItemWrapper = new List<CreditNoteItemWrapper>();
        
        //fetching creditnoteItems for the creditNotes passed
        for(Credit_Note_Item__c cnItem : [SELECT Id,Name,Amount__c, Credit_Note__c,Deal__r.Name,Deal__c,Deal_Product_Hyperlink__c,Deal_Product_Name__c,
                                         Deal_Product_Id__c,Requested_Co_op_Amount__c,Unique_Id__c,Product__r.Name,Product__c,ProductCode__c
                                         FROM Credit_Note_Item__c
                                         WHERE Credit_Note__c = :cnId]){
                     CreditNoteItemWrapper cniWrapper = new CreditNoteItemWrapper();
                     cniWrapper.amount = cnItem.Amount__c;
                     cniWrapper.cnItem = cnItem;
                     lstCNItemWrapper.add(cniWrapper);  
                     if(mapdealCNIWrapper.containsKey(cnItem.Deal__c)){
                        mapdealCNIWrapper.get(cnItem.Deal__c).add(cniWrapper);
                     }else{
                        mapdealCNIWrapper.put(cnItem.Deal__c,new List<CreditNoteItemWrapper>{cniWrapper});
                     } 
                       
         }
         dealCNIWrapper.lstCNIWrapper = lstCNItemWrapper;
         dealCNIWrapper.mapdealCNIWrapper = mapdealCNIWrapper;  
         return dealCNIWrapper;
    }
    
    /**
     *  Method to update Credit Note Items 
     *  @name saveCreditNoteItems
     *  @param Id cnId, List<CreditNoteItemWrapper> cnItems, Boolean quickSave
     *  @return List<CreditNoteItemWrapper>
     *  @throws CRM_EditAllCreditNoteItemsCtrlException
     */
    @RemoteAction
    global static DealCreditNoteItemWrapper saveCreditNoteItems(Id cnId,List<CreditNoteItemWrapper> cnItems, Boolean quickSave) {
        system.debug('cnItems :: '+cnItems.size());
        List<Credit_Note_Item__c > lstCnItemsUpdate = new List<Credit_Note_Item__c >();
        for(CreditNoteItemWrapper cniWrapper : cnItems){
            Credit_Note_Item__c cni = cniWrapper.cnItem;
            system.debug('cni.Amount__c :: '+cni.Amount__c+'--'+cni.Deal__r.Name);
            system.debug('cniWrapper.amount :: '+cniWrapper.amount);
            if(cni.Amount__c != cniWrapper.amount){
            		system.debug('deal ID '+cni.Deal__c);
                    cni.Amount__c = cniWrapper.amount;
                    lstCnItemsUpdate.add(cni);
            }
        }
           
        // Commit changes
        Savepoint sp = Database.setSavepoint();
        try{
            if(lstCnItemsUpdate.size() > 0)
                update lstCnItemsUpdate;
        }catch(System.DMLException e){
            Database.rollback(sp);
            throw new CRM_EditAllCreditNoteItemsCtrlException (e.getDmlMessage(0));
        }catch(Exception e){
            Database.rollback(sp);
            throw new CRM_EditAllCreditNoteItemsCtrlException (e.getMessage());
        }
       
        if(quickSave)
            return getCreditNoteItems(cnId);
        else
           return null;
    }
    
	 /**
     *  Method to fetch CRM_Max_Product_Limit__c to fetch CNI limit 
     *  @name getMaxCreditNoteItemLimit
     *  @return Integer 
     *  @throws None
     */
    global Integer getMaxCreditNoteItemLimit() {
        return CRM_Max_Product_Limit__c.getInstance('Edit_Credit_Note_Item') != null ? Integer.valueOf(CRM_Max_Product_Limit__c.getInstance('Edit_Credit_Note_Item').Count__c) : 50;
    }
    
    
    /*
    * Wrapper Class for CreditNoteItem
    */
    global class CreditNoteItemWrapper{
        
        global Credit_Note_Item__c cnItem;
        global Boolean isSelected;
        global Boolean isDirtyRow;
        global Decimal amount;
        global Map<String, Boolean> inValidFormatMap = new Map<String, Boolean>();
        global CreditNoteItemWrapper(){}
    }
    
    
    
    /*
    * Wrapper for DealCreditNote
    */
    global class DealCreditNoteItemWrapper{
        
        global List<CreditNoteItemWrapper> lstCNIWrapper;
        global Map<Id,List<CreditNoteItemWrapper>> mapdealCNIWrapper;
        
        global DealCreditNoteItemWrapper(){
            lstCNIWrapper = new List<CreditNoteItemWrapper>();
            mapdealCNIWrapper = new Map<Id,List<CreditNoteItemWrapper>>();
        }
    }

    /**
     * Method to get logged in uSer Locale
    **/
    global String getUserLocale() {
        /*String currentUserLocale = UserInfo.getLocale();
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale.toLowerCase());
        return currentUserLocale.toLowerCase();*/
        String currentUserLocale = UserInfo.getLocale();
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }

        /*if (currentUserLocale.contains('en-')) {
            currentUserLocale = currentUserLocale.substringBefore('-');
        }*/
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale);
        return currentUserLocale;
    }

    global String getUserLocaleLowerCase() {
        String currentUserLocale = UserInfo.getLocale();
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale.toLowerCase());
        return currentUserLocale.toLowerCase();
    }

    public class CRM_EditAllCreditNoteItemsCtrlException extends Exception {}
}