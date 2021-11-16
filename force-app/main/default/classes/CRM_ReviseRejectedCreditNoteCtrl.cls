/**
   @Author Cognizant
   @name CRM_ReviseRejectedCreditNote
   @CreateDate 23 May 2017
   @Description controller for vf to Revise Rejected Credit Note
   @Version <1.0>
   @reference 
*/
global with sharing class CRM_ReviseRejectedCreditNoteCtrl {
    
    global CRM_ReviseRejectedCreditNoteCtrl (ApexPages.StandardController stdCon){}
    /**
     *  Method
     *  @name reviseRejectedCreditNote
     *  @param cnId - Id of the creditNote for which CreditNoteItems needs to fetched
     */
    @RemoteAction
    global static boolean reviseRejectedCreditNote(Id cnId){
        if(cnId != null){
            List<Credit_Note__c> lstCreditNote = new List<Credit_Note__c>();
            lstCreditNote = [SELECT Status__c FROM Credit_Note__C WHERE Id =:cnId];
            if(!lstCreditNote.isEmpty()){
                if(!CRM_AppConstants.CREDIT_NOTE_STATUS_MOVEED_REVISED.contains(lstCreditNote[0].Status__c)){
                    throw new CRM_ReviseRejectedCreditNoteException(System.label.CRM_Invalid_Status_To_Revised_CN);
                }else{
                    lstCreditNote[0].Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_REVISED;
                    try{
                        update lstCreditNote;
                    }catch(System.DmlException de){
                        throw new CRM_ReviseRejectedCreditNoteException(de.getDmlMessage(0));
                    }
                }
            }
        }
        return true;
    }
    
    global class CRM_ReviseRejectedCreditNoteException extends Exception{}
}