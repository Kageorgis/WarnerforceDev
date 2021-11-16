/**
@Author Accenture
@name ExcelFileUploadBatch
@CreateDate  Mar 2020
@Description This class is used to process the upload Batch of Deal Products.
@Version <1.0>
*/
global class ExcelFileUploadBatch implements Database.Batchable<sObject>,Database.stateful{
    public String query;
    private Map<String, Integer> processedCount = new Map<String, Integer>();
    private Map<String, Integer> successCount = new Map<String, Integer>();
    //--WBCTASK000295555--Added map to hold unique deals to update reprice flage in finish method--Start--//
    public Map<Id,Opportunity> mapIdToDealToSetRepriceFlags = new Map<Id,Opportunity>();
    //--WBCTASK000295555--Added map to hold unique deals to update reprice flage in finish method--End--//

/** 
*  Method for batch process start
*  @name start
*  @param batchable context
*  @return Databse.QueryLocator
*  @throws none
*/ 
    global Database.QueryLocator start(Database.BatchableContext bc) {
        query='select id,status__c,ObjectName__c,InputObjectData__c,Comment__c,credit_Note_Id__c,'+
            'DealId__c,DealRecordType__c,Total_Count__C, UploadObjectParent__c from UploadObject__c'+
            ' where UploadObjectParent__c!=null and status__c=\'InProgress\' and createddate >= LAST_N_DAYS:1 LIMIT 50000';
        return Database.getQueryLocator(query);
    }
    
/** 
*  Method for batch process execute
*  @name execute
*  @param uploadObjects List
*  @return none
*  @throws none
*/ 
    global void execute(Database.BatchableContext bc, List<UploadObject__C> UploadObjects){    
        for(UploadObject__c uo : UploadObjects){  
            boolean isSuccess = true;
            Integer errorCount = 0;
            String errorDataStr = '';
            List<String> errResult = new List<String>();
            try{
                if(uo.ObjectName__c == System.Label.CRM_OpportunityLineItem_Name) { 
                    //Added PHYSICAL_PLANNING_DEAL Check for CRM-JV W-017676
                    if((uo.DealRecordType__c).equals( CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_DFI_DEAL)||
                       (uo.DealRecordType__c).equals( CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_POS_DEAL)||
                       (uo.DealRecordType__c).equals(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_PLANNING_DEAL)) {                  
                           errResult = CRM_UploadExtractPOSandDFI.excelUploadPOSAndDFI(uo.InputObjectData__c,uo.DealId__c);                         
                       }
                }else if(uo.ObjectName__c == System.Label.CRM_Reprice_OpportunityLineItem_Name) { 
                   	   CRM_UploadExtractPOSandDFI.updateBulkRepriceDealProducts(uo.InputObjectData__c); 
                }else{
                    errResult=CRM_UploadExtractCreditNoteItem_POSDeal.excelUploadPOSCreditNoteItem(uo.InputObjectData__c,uo.credit_Note_Id__c);
                }
                if(errResult.size()>0){
                    isSuccess=false;
                    errorCount=errResult.size();
                    errorDataStr=JSON.serializePretty(errResult);
                }
                uo.status__c=isSuccess? System.Label.CRM_SuccessLabel:System.Label.CRM_FailedLabel;
                uo.Success_Count__c=Integer.valueof(uo.Total_Count__C)-errorCount;
                uo.Comment__c=errorDataStr;
                Database.update(uo);  
                Integer total_count = (processedCount.get(uo.UploadObjectParent__c)!=null?
                                       processedCount.get(uo.UploadObjectParent__c):0)+Integer.valueof(uo.Total_Count__C);
                processedCount.put(uo.UploadObjectParent__c,total_count);
                Integer success_count =(successCount.get(uo.UploadObjectParent__c)!=null?
                                        successCount.get(uo.UploadObjectParent__c):0)+(Integer.valueof(uo.Total_Count__C)-errorCount); 
                successCount.put(uo.UploadObjectParent__c,success_count);                                          
            }catch (Exception e) {
                UploadObject__c upload = new UploadObject__c();
                upload.Id=uo.UploadObjectParent__c;
                upload.status__c = System.Label.CRM_FailedLabel;
                upload.Comment__c=e.getMessage();   
                Database.update(upload);
            }
        }
        for (String key : processedCount.keySet()) {
            try{
                UploadObject__c parentObject = [SELECT id,Total_Count__C, Processed_Count__c,DealId__c,ObjectName__c,
                                                Success_Count__c from UploadObject__c where Id =:key LIMIT 1]; 
                //--WBCTASK000295555--Added if block to get count from map for reprice, else block kept same as per existing logic--//
                Integer processedCount = parentObject.ObjectName__c == System.Label.CRM_Reprice_OpportunityLineItem_Name ? 
                                        processedCount.get(key) : 
                                        ((parentObject.Processed_Count__c!=null?
                                        Integer.valueof(parentObject.Processed_Count__c):0)+ processedCount.get(key));
                //--WBCTASK000295555--Added if block to get count from map for reprice, else block kept same as per existing logic--//
                Integer successCount = parentObject.ObjectName__c == System.Label.CRM_Reprice_OpportunityLineItem_Name ?
                                        successCount.get(key) :
                                        ((parentObject.Success_Count__c!=null?
                                        Integer.valueof(parentObject.Success_Count__c):0)+ successCount.get(key));                

                if(processedCount==Integer.valueof(parentObject.Total_Count__C)) {
                    parentObject.status__c= processedCount==successCount?System.Label.CRM_SuccessLabel:System.Label.CRM_FailedLabel;                    
                }else{
                    parentObject.status__c=System.Label.CRM_InProgressLabel;
                }
                parentObject.Processed_Count__c= processedCount;
                parentObject.Success_Count__c = successCount;
                Database.update(parentObject);
                if(parentObject.ObjectName__c == System.Label.CRM_Reprice_OpportunityLineItem_Name) {
                    Opportunity opp = new Opportunity();
                    opp.Id = parentObject.DealId__c;
                    opp.IsRepriceStarted__c=false;
                    opp.IsRepriceCompleted__c=true;
                    //--WBCTASK000295555--Added record in map used in finish method, comment update DML--Start--//
                    //database.update(opp);
                    mapIdToDealToSetRepriceFlags.put(parentObject.DealId__c, opp);
                    //--WBCTASK000295555--Added record in map used in finish method, comment update DML--End--//
                }
            }catch (Exception e) {
                UploadObject__c upobj = new UploadObject__c();
                upobj.Id=key;
                upobj.status__c=System.Label.CRM_FailedLabel;
                upobj.Comment__c=e.getMessage();   
                Database.update(upobj);
            }
        }
    }
    
/** 
*  Method for batch process finish
*  @name finish
*  @param batchable context
*  @return none
*  @throws none
*/
    global void finish(Database.BatchableContext bc){
        //--WBCTASK000295555-reset reprice flages on deal--Start--//
        if(!mapIdToDealToSetRepriceFlags.isEmpty()){
            processDealRepriceFlags();
        }
        //--WBCTASK000295555-reset reprice flages on deal--End--//
    }    

    /**
     * @Description - Added new methof for WBCTASK000295555 to reset flags on deal records once successfully reprice processed and
     *                log an errors in case of nay deal update failure in system
     * @name processDealRepriceFlags
     */
    @TestVisible
    private void processDealRepriceFlags(){
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        if(!mapIdToDealToSetRepriceFlags.isEmpty()){
            Database.SaveResult[] saveResultList = Database.update(mapIdToDealToSetRepriceFlags.values(),false);
            Opportunity oppInstance;
            for(Integer i = 0; i < saveResultList.size(); i++){
                Database.SaveResult saveResultInstance = saveResultList[i];
                oppInstance = mapIdToDealToSetRepriceFlags.values()[i];

                // Error Handling   // Save the error in database
                if(oppInstance != null && !saveResultInstance.isSuccess()){                    
                    for(Database.Error err: saveResultInstance.getErrors()){                        
                        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                        errorLog.recordId = oppInstance.Id;
                        errorLog.functionalModule = System.Label.CRM_Reprice_OpportunityLineItem_Name;
                        errorLog.errorMessage = err.getMessage().left(200);
                        listErrorLog.add(errorLog);
                    }
                }
            }
        }

        // Inserts all errors into database
        if(!listErrorLog.isEmpty()){
            CRM_ErrorLogger.logError(listErrorLog);
        }
    }
}