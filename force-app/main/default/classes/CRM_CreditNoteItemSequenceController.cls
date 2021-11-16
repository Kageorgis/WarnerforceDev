/** 
   * @Author: cognizant Team
   * @Description: This is sequence controller for trigger 
   * @Date Created:  03 March 2017
   * @Version: 1.0 
   */

public with sharing class CRM_CreditNoteItemSequenceController {
    
    
    public static void executeAfterInsert(List<Credit_Note_Item__c> lstCreditNoteItems){
        CRM_CreditNoteItemHandler.rollUpAmountToDealCreditNote(lstCreditNoteItems);
    }
    
    public static void executeAfterUpdate(List<Credit_Note_Item__c> lstCreditNoteItems){
        CRM_CreditNoteItemHandler.rollUpAmountToDealCreditNote(lstCreditNoteItems);
    }
    
    public static void executeBeforeInsert(List<Credit_Note_Item__c> lstCreditNoteItems){
        CRM_CreditNoteItemHandler.setDefaultCurrency(lstCreditNoteItems);
    }
    
    public static void executeBeforeUpdate(List<Credit_Note_Item__c> lstCreditNoteItems){
        CRM_CreditNoteItemHandler.setDefaultCurrency(lstCreditNoteItems);
    }
}