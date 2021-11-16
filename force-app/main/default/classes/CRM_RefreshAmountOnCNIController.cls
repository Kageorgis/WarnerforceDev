/**
   @Author Cognizant
   @name CRM_RefreshAmountOnCNIController
   @CreateDate 3 March 2017
   @Description controller for vf to Refresh Amount on Credit Note Item
   @Version <1.0>
   @reference 
*/
global with sharing class CRM_RefreshAmountOnCNIController {
    global CRM_RefreshAmountOnCNIController(ApexPages.StandardController stdCon){}
	
	/**
     *  Method
     *  @name refreshAmountOnCNI
     *  @param cnId - Id of the creditNote for which CreditNoteItems needs to fetched
     *  @return DealCreditNoteItemWrapper - DealCreditNoteItemWrapper to be made available for user selection
     */
    @RemoteAction
	global static List<errorWrapper> refreshAmountOnCNI(Id cnId,String cnStatus){
		
		if(cnStatus != CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED && cnStatus != CRM_AppConstants.CREDIT_NOTE_STATUS_REVISED)
			throw new CRM_RefreshAmountOnCNIControllerException(System.label.CRM_Invalid_Status_To_Refresh_Amount_On_CNI);
			
		// Error Wraper List
        List<errorWrapper> errorWrapper = new List<errorWrapper>();
		
		List<Credit_Note_Item__c> lstCreditNoteItems = new List<Credit_Note_Item__c>();
		Map<Id,Credit_Note_Item__c> mapOfDpIdToCNI = new Map<Id,Credit_Note_Item__c>();
		
		for(Credit_Note_Item__c cnItem : [SELECT Id,Name,Amount__c,Deal_Product_Id__c,Product__r.Name
                                          FROM Credit_Note_Item__c
                                          WHERE Credit_Note__c = :cnId]){
			mapOfDpIdToCNI.put(cnItem.Deal_Product_Id__c,cnItem);
		}
		
		if(mapOfDpIdToCNI.size() > 0){
			for(OpportunityLineItem dp : [Select Id,Co_op_Balance__c FROM OpportunityLineItem WHERE Id IN :mapOfDpIdToCNI.keySet()]){
				if(mapOfDpIdToCNI.containsKey(dp.Id)){
					Credit_Note_Item__c cni = mapOfDpIdToCNI.get(dp.Id);
					cni.Amount__c = dp.Co_op_Balance__c > 0 ? dp.Co_op_Balance__c : 0;
					lstCreditNoteItems.add(cni);
				}
			}
			Database.SaveResult[] saveResult = new Database.SaveResult[]{};
			if(!lstCreditNoteItems.isEmpty())
				saveResult = Database.update(lstCreditNoteItems, false);
			
			// Save Results
            for (integer i=0 ; i < saveResult.size() ; i++){
                Credit_Note_Item__c cni = lstCreditNoteItems[i];
				if (!saveResult[i].isSuccess()){
                    Database.Error[] errors = saveResult[i].getErrors();
                    errorWrapper.add(new errorWrapper(cni.Deal_Product_Id__c,errors[0].getMessage(),cni.Product__r.Name));
                }
            } 
			
		}
		return errorWrapper;
	}
	
	global class errorWrapper{
        public String errorMsg;
        public String productName;
		public String dpId;
        
        public errorWrapper(String dpId,String errorMsg,String productName){
            this.dpId = dpId;
            this.errorMsg = errorMsg;
            this.productName = productName;
        }
    }
	
	global class CRM_RefreshAmountOnCNIControllerException extends Exception{}
}