/**
   @Author Cognizant
   @name CRM_CreditNoteApprovalCtrl 
   @Description Class for CRM_CreditNoteApproval
  */
global with sharing class CRM_CreditNoteApprovalCtrl{
    
    public CRM_CreditNoteApprovalCtrl(ApexPages.StandardController stdCon) {}
    
    /**
    *  @Description: Method to get Opportunity related to Credit Note         
    *  @name getRelatedDeals     
    *  @param Id creditNoteId      
    *  @retuns String        
    */
    @RemoteAction
    global static creditNoteWrapper getRelatedDeals(Id creditNoteId) {
    	creditNoteWrapper cnw = new creditNoteWrapper();
    	List <Credit_Note__c> lstCreditNote = new List <Credit_Note__c>();
        Integer count = 0;
        /*List<Credit_Note_Item__c> lstCreditNoteItems = new List<Credit_Note_Item__c>();
        Map<Id, List<Credit_Note_Item__c>> mapDealIdCreditNoteItem = new Map<Id, List<Credit_Note_Item__c>>();
        Map<Id, Decimal> mapDealIdCreditNoteItemTotalAmount = new Map<Id, Decimal>();
        */
        
        if(creditNoteId != null){
        	lstCreditNote = [SELECT Status__c,Co_op_Spent__c,PO_Number__c FROM Credit_Note__c WHERE Id = :creditNoteId Limit 1];
        	
        	//Pre Check
        	if(!lstCreditNote.isEmpty()){
        		preApprovalCheck(lstCreditNote[0]);
        		
        		List<DealCreditNote__c> lstOfReveisedDCN = [SELECT Id,Opportunity__c,Opportunity__r.Deal_Code__c,Opportunity__r.Name,Opportunity__r.stageName From DealCreditNote__c WHERE Opportunity__r.StageName != :CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED AND Credit_Note__c = :creditNoteId];
        	    if(!lstOfReveisedDCN.isEmpty()){
        	    	cnw.lstOfReveisedDCN = lstOfReveisedDCN;
        	    	return cnw;
        	    }
        	    	 
        	    count = [SELECT count() From DealCreditNote__c WHERE Approval_Required__c = true AND Credit_Note__c = :creditNoteId];
        	    //if all the deal does not match than call the approval process or else auto approve
		        System.debug('#count' + count);
		        if(count > 0){
		        	cnw.isValidForAutoApprove = false;
		            SubmitCreditNoteForApproval(lstCreditNote[0].Id);
		        }else{
		        	cnw.isValidForAutoApprove = true;
		            lstCreditNote[0].Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_READY_TO_PAY;
		            update lstCreditNote;
		        }
	        }
        }
        return cnw;
    }
    
    /**
    *  @Description: Method to call the standard approval process for Credit Note         
    *  @name SubmitCreditNoteForApproval     
    *  @param Id creditNoteId      
    *  @retun void        
    */     
    global static void SubmitCreditNoteForApproval(Id creditNoteId){       
        if (String.isNotBlank(creditNoteId))       
        {       
            try     
            {                                   
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();        
                req.setObjectId(creditNoteId);     
                Approval.ProcessResult result = Approval.process(req);      
            }       
            catch(Exception e)      
            {       
                system.debug(e.getMessage());       
                throw new CRM_CreditNoteException(e.getMessage());      
            }           
        }       
    }
    
    /**
    *  @Description: Method to check condition prior to Credit Note Approval         
    *  @name preApprovalCheck     
    *  @param Credit Note      
    *  @retuns void        
    */
    global static void preApprovalCheck(Credit_Note__c creditNote) {
        if(creditNote != null && !(creditNote.Status__c).equalsIgnoreCase(CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED) && !(creditNote.Status__c).equalsIgnoreCase(CRM_AppConstants.CREDIT_NOTE_STATUS_REVISED)){
            throw new CRM_CreditNoteException(system.Label.CRM_CN_Approval_ErrorMsg);
        }else if(creditNote != null && creditNote.Co_op_Spent__c <= 0){
        	throw new CRM_CreditNoteException(system.Label.CRM_Credit_Note_Approval_Error_Msg);
        }else if (creditNote != null && creditNote.PO_Number__c == null ){
        	throw new CRM_CreditNoteException(system.Label.CRM_Credit_Note_PO_Num_Not_Present);
        }
    }
    global class creditNoteWrapper{
    	public boolean isValidForAutoApprove{get; set;}
    	public List<DealCreditNote__c> lstOfReveisedDCN{get; set;}
    	public creditNoteWrapper(){
    		lstOfReveisedDCN = new List<DealCreditNote__c>();
    	}
    }
    /**
    *  @Description - Exception Class
    *  @name  CRM_CreditNoteException 
    */
    public class CRM_CreditNoteException extends Exception {}
}