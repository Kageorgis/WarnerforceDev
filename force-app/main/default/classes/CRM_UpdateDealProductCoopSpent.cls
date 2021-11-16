/**
   @Author Cognizant
   @name CRM_UpdateDealProductCoopSpent  
   @Description This is a queueable class which is called when credit note are inserted/updated to update 
                Co-op spent on related Deal products for Germany and Co op Actual Amount for US Games.
   @Version <1.0>
   @reference
*/
public with sharing class CRM_UpdateDealProductCoopSpent implements Queueable{
    
    List<Credit_Note_Item__c> lstCreditNoteItems = new List<Credit_Note_Item__c>();
    public CRM_UpdateDealProductCoopSpent(List<Credit_Note_Item__c> lstCreditNoteItems){
        this.lstCreditNoteItems = lstCreditNoteItems;
    }
    
    public void execute(QueueableContext context) {
    	List<OpportunityLineItem> lstDealProducts = new List<OpportunityLineItem>();
    	Map<String,Credit_Note_Item__c> mapDpIdToCNI = new Map<String,Credit_Note_Item__c>();
    	List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
    	if(!lstCreditNoteItems.isEmpty()){
    		for(Credit_Note_Item__c cni : lstCreditNoteItems){
    			mapDpIdToCNI.put(cni.Deal_Product_Id__c,cni);
    		}
    		if(mapDpIdToCNI.size() > 0){
    		    //US#931 Deal Product --> Co Op Actual Amount 
    			for(OpportunityLineItem dp : [SELECT Id,Opportunity.Sales_Organisation__c,Opportunity.Account.Digital_Country_Code__c,Co_op_Spent__c,Co_op_Actual_Amount__c,Customer_reference__c From OpportunityLineItem WHERE Id IN :mapDpIdToCNI.KeySet()]){
    				if(mapDpIdToCNI.containsKey(dp.Id) && mapDpIdToCNI.get(dp.Id).Amount__c != null){
    					String cnStatus = mapDpIdToCNI.get(dp.Id).Credit_Note__r.Status__c;
    					Id creditNoteRecordType =  mapDpIdToCNI.get(dp.Id).Credit_Note__r.RecordtypeId;
    					Decimal amount = (cnStatus == CRM_AppConstants.CREDIT_NOTE_STATUS_FAILED || cnStatus == CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED) ? (-mapDpIdToCNI.get(dp.Id).Amount__c) : mapDpIdToCNI.get(dp.Id).Amount__c;
    					 //US#931 Update Deal Product --> Co Op Actual Amount with Credit Note Item's Amount. start
    					if(cnStatus == CRM_AppConstants.CREDIT_NOTE_STATUS_READY_TO_PAY && CRM_AppConstants.US_SALES_ORGS.contains(dp.Opportunity.Sales_Organisation__c)){
    					   if(creditNoteRecordType == CRM_RecordTypeUtil.RT_CREDIT_NOTE_REVERSE){
    					    dp.Co_op_Actual_Amount__c = ( amount * -1);
    					    }else{
    					        dp.Co_op_Actual_Amount__c = amount; 
    					    }
    					    dp.Customer_Reference__c = mapDpIdToCNI.get(dp.Id).Customer_Reference_Number__c;
    					}
    					
    					if(CRM_AppConstants.GERMANY_SALES_ORGS.contains(dp.Opportunity.Sales_Organisation__c)){
    					    //US#931 Update Deal Product --> Co Op Actual Amount with Credit Note Item's Amount. start
    					    if(dp.Co_op_Spent__c == 0 || dp.Co_op_Spent__c == null){
    							dp.Co_op_Spent__c = amount;
    						}else{
    							dp.Co_op_Spent__c += amount;
    						}
    					}
    					lstDealProducts.add(dp);
    				}
    			}
    			if(!lstDealProducts.isEmpty()){
    				Database.SaveResult[] result = Database.Update(lstDealProducts, false);
    				OpportunityLineItem dpObj = new OpportunityLineItem();
    				for(Integer i=0; i < result.size(); i++ ){
		                dpObj = lstDealProducts[i];
		                if(!result[i].isSuccess()){
		                    List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList = logAnException(result[i].getErrors(),result[i].getId());
		                    listErrorLog.addAll(errorLogInstanceList);
		                }
		             }
    			}
    			if(!listErrorLog.isEmpty())
    				CRM_ErrorLogger.logError(listErrorLog); 
    		}
    	}
    }
    
    /** 
    *  @description: - This method is used to add Exception log for Deal product
    *  @name: logAnException
    *  @return: void
    */ 
    public static List<CRM_ErrorLogger.ErrorLog> logAnException(List<Database.Error> errors, Id recordId){
    	List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList = new list<CRM_ErrorLogger.ErrorLog>();
    	CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        for(Database.Error err : errors){
        	errorLogInstance.recordId = recordId;
        	errorLogInstance.functionalModule = 'Deal Product Coop Spent Update After Approved Credit Note';
	        errorLogInstance.className = 'CRM_UpdateDealProductCoopSpent';
	        errorLogInstance.lineNumber = '';
	        errorLogInstance.errorMessage = ' Error Message: ' +err.getMessage();
	        errorLogInstance.stackTrace = ' Error Code: ' + String.valueOf(err.getStatusCode());
        	errorLogInstanceList.add(errorLogInstance);
        }
        return errorLogInstanceList;
    }
}