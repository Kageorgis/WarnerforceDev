public with sharing class CRM_CreditNoteSequenceController {
    public static void executeAfterUpdate(List<Credit_Note__c> lstNewCreditNotes,Map<Id,Credit_Note__c> mapOldCreditNotes){
    	CRM_CreditNoteHandler.updateDealProduct(lstNewCreditNotes,mapOldCreditNotes);
    }
    public static void executeBeforeInsert(List<Credit_Note__c> lstNewCreditNotes){
    	CRM_CreditNoteHandler.UpdateShipToAccountOnCreditNote(lstNewCreditNotes);
    }
    public static void executeBeforeDelete(List<Credit_Note__c> lstOldCreditNotes){
    	CRM_CreditNoteHandler.restrictToDeleteApprovedCN(lstOldCreditNotes);
    } 
    public static void excuteBeforeUpdate(List<Credit_Note__c> lstNewCreditNotes,Map<Id,Credit_Note__c> mapOldCreditNotes){
        CRM_CreditNoteHandler.updateCreditNoteStatus(lstNewCreditNotes,mapOldCreditNotes);
    }
}