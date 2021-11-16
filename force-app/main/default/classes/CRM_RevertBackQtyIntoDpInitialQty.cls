public class CRM_RevertBackQtyIntoDpInitialQty implements Queueable{
    Map<Id,Decimal> mapOfDealProductIdToQuantity = new Map<Id,Decimal>();
    Set<Id> dealIds = new Set<Id>();
    public CRM_RevertBackQtyIntoDpInitialQty(Map<Id,Decimal> mapOfDealProductIdToQuantity){
        this.mapOfDealProductIdToQuantity = mapOfDealProductIdToQuantity;
    }
    
    public void execute(QueueableContext context) {
        updateInitialQuantityOnDealProduct();
    }
    
    private void updateInitialQuantityOnDealProduct(){
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        List<Opportunity> lstdeals = new List<Opportunity>();
        List<OpportunityLineItem> lstDealProducts = [SELECT Id,Initial_Quantity__c,OpportunityId,Product2Id FROM OpportunityLineItem
                                                     WHERE Id IN :mapOfDealProductIdToQuantity.keySet()];
        if(!lstDealProducts.isEmpty()){
            List<CRM_Multiorder_Functionality__c> lstMultiOrderCS = [Select Id,ByPassValidation__c From CRM_Multiorder_Functionality__c Limit 1];
            if(!lstMultiOrderCS.isEmpty()){
                lstMultiOrderCS[0].ByPassValidation__c = true;
                update lstMultiOrderCS;
            }
            
            for(OpportunityLineItem dp : lstDealProducts){
                if(mapOfDealProductIdToQuantity.size() > 0 && mapOfDealProductIdToQuantity.containsKey(dp.Id)){
                    dp.Initial_Quantity__c = mapOfDealProductIdToQuantity.get(dp.Id);
                }
            }
            if(!lstDealProducts.isEmpty()){
                Database.SaveResult[] result = Database.Update(lstDealProducts, false);
                OpportunityLineItem dpObj = new OpportunityLineItem();
                for(Integer i=0; i < result.size(); i++ ){
                    dpObj = lstDealProducts[i];
                    if(!result[i].isSuccess()){
                        List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList = logAnException(result[i].getErrors(),result[i].getId(),'Deal Product Initial Quantity Update after inserting Order Producs From Multi Upload/Extract Page','CRM_MultiUploadExtractOrderController');
                        listErrorLog.addAll(errorLogInstanceList);
                    }
                 }
            }
            
            if(!listErrorLog.isEmpty())
                CRM_ErrorLogger.logError(listErrorLog); 
        
            if(!lstMultiOrderCS.isEmpty()){
                lstMultiOrderCS[0].ByPassValidation__c = false;
                update lstMultiOrderCS;
            }
        }
    }
    /** 
    *  @description: - This method is used to add Exception log for Deal product
    *  @name: logAnException
    *  @return: void
    */ 
    public static List<CRM_ErrorLogger.ErrorLog> logAnException(List<Database.Error> errors, Id recordId, String functionalModule, String className){
        List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList = new list<CRM_ErrorLogger.ErrorLog>();
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        for(Database.Error err : errors){
            errorLogInstance.recordId = recordId;
            errorLogInstance.functionalModule = functionalModule; 
            errorLogInstance.className = className; 
            errorLogInstance.lineNumber = '';
            errorLogInstance.errorMessage = ' Error Message: ' +err.getMessage();
            errorLogInstance.stackTrace = ' Error Code: ' + String.valueOf(err.getStatusCode());
            errorLogInstanceList.add(errorLogInstance);
        }
        return errorLogInstanceList;
    }
}