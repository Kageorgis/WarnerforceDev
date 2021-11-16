/**
@Author Accenture
@name ImportExcelProcessor
@CreateDate  Mar 2020
@Description This class is used to process the upload of Deal Products.
@Version <1.0>
*/
public class ImportExcelProcessor {
    
    /** 
*  Method for batch process 
*  @name UpdateFields
*  @param deal id, deal record type
*  @return none
*  @throws none
*/ 
    @future
    public static void UpdateFields(String recordId, String recordType){
        
        
        list<UploadObject__c> o=[select id,status__c,ObjectName__c,InputObjectData__c,Comment__c,
                                 DealId__c,credit_Note_Id__c,UploadObjectParent__c,Total_Count__C 
                                 from UploadObject__c where UploadObjectParent__c=:recordId LIMIT 50000];
        if(o.size()> 0){
            boolean isSuccess=true;
            Integer errorCount =0;
            Integer totalCount=0;
            String errorDataStr='';
            
            try{ 
                for(UploadObject__c uo : o){  
                    List<String> errResult = new List<String>();
                    Integer childErrorCount=0;
                    if(uo.ObjectName__c==System.Label.CRM_OpportunityLineItem_Name) {
                        //Added PHYSICAL_PLANNING_DEAL Check for CRM-JV W-017676
                        if(recordType.equals(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_DFI_DEAL)||
                           recordType.equals(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_POS_DEAL)|| 
                           recordType.equals(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_PLANNING_DEAL)) {                  
                            errResult = CRM_UploadExtractPOSandDFI.excelUploadPOSAndDFI(uo.InputObjectData__c,uo.DealId__c);
                        }
                    }else{
                        errResult=CRM_UploadExtractCreditNoteItem_POSDeal.excelUploadPOSCreditNoteItem(uo.InputObjectData__c,uo.credit_Note_Id__c);
                    }
                    if(errResult.size()>0){
                        isSuccess=false;
                        errorCount=errorCount+errResult.size();
                        childErrorCount=errResult.size();
                        errorDataStr=JSON.serializePretty(errResult);
                    }
                    totalCount=totalCount+Integer.valueof(uo.Total_Count__C);            
                    uo.status__c = isSuccess? System.Label.CRM_SuccessLabel: System.Label.CRM_FailedLabel;
                    uo.Success_Count__c=Integer.valueof(uo.Total_Count__C)-childErrorCount;
                    uo.Comment__c = errorDataStr;
                    Database.update(uo);
                    // update uo;        
                    UploadObject__c u = new UploadObject__c();
                    u.Id=recordId;
                    u.Success_Count__c=totalCount-errorCount;
                    u.Processed_Count__c=totalCount;
                    Database.update(u);
                    // update u;
                }  
                UploadObject__c u = new UploadObject__c();
                u.Id=recordId;
                if(!String.isEmpty(errorDataStr)){
                    u.status__c = System.Label.CRM_FailedLabel;
                    // u.Comment__c=System.JSON.serializePretty(errorList);
                    
                }
                else{
                    u.status__c = System.Label.CRM_SuccessLabel;          
                }
                Database.update(u);
                // update u;
            }catch (Exception e) {
                UploadObject__c u = new UploadObject__c();
                u.Id=recordId;
                u.status__c = System.Label.CRM_FailedLabel;
                u.Comment__c=e.getMessage();
            }
        }    
    }
}