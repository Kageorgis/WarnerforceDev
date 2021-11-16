/**
   @Author Accenture
   @name importExcelController
   @CreateDate  Mar 2020
   @Description This class is used to upload (update/insert) the deal products for POS and DFI deals through excel import.
   @Version <1.0>
*/
public class ImportExcelController {
    
/** 
    *  Method to fetch the Deal Attributes
    *  @name getOpportunityDetails
    *  @param Deal Id
    *  @return Opportunity Record
    *  @throws none
*/ 
    @AuraEnabled
    public static Opportunity getOpportunityDetails(Id oppId) { 
        Opportunity lstOpportunity = new Opportunity();
        try{
            lstOpportunity = [SELECT id,name,RecordTypeId,RecordType.Name,Sales_Organisation__c,
                                              Account.Digital_Country_Code__c,StageName,Pricebook2Id,AccountId,
                                              CurrencyISOCode,External_Id__c,CloseDate,Start_Date__c 
                                       FROM Opportunity 
                                       WHERE Id =: oppId LIMIT 1];
        }catch(Exception excep){
            throw new ImportExcelControllerException(excep.getMessage());
        }
        return lstOpportunity;
    }

/** 
    *  Method to Upload Objects into UploadObjects
    *  @name uploadObjects
    *  @param uploadObject List, Object Name, Deal Id , Number of Records
    *  @return String
    *  @throws none
*/ 
    @AuraEnabled
    public static String uploadObjects(String uploadObjectList, String objectName, String dealId, Integer totalRecord){ 
        List<UploadObject__c> uploadItemsList =
            (List<UploadObject__c>)System.JSON.deserializeStrict(uploadObjectList, List<UploadObject__c>.class);
        List<UploadObject__c> uploadItemsToUpsert = new List<UploadObject__c> ();
        UploadObject__c upParent = new UploadObject__c();
        upParent.Name=objectName+'_'+dealId ;
        upParent.ObjectName__c =objectName;
        if(objectName.equalsIgnoreCase(System.Label.CRM_OpportunityLineItem_Name) ||
            objectName.equalsIgnoreCase(System.Label.CRM_Reprice_OpportunityLineItem_Name) ){
            upParent.DealId__c=dealId;
        }else {
            upParent.credit_Note_Id__c=dealId;
        }          
        upParent.status__c = System.Label.CRM_InProgressLabel;
        upParent.Total_Count__C=totalRecord;
        insert upParent;
        for(UploadObject__c uo : uploadItemsList){
            uo.UploadObjectParent__c=upParent.Id;
            uploadItemsToUpsert.add(uo);
        }
        List<Database.SaveResult> result = Database.insert(uploadItemsToUpsert);
        return upParent.Id;
    }
    
/** 
    *  Method to call the Batch Processor
    *  @name callBatchClass
    *  @param parent Object Id, Parent Record Type
    *  @return none
    *  @throws none
*/ 
    @AuraEnabled
    public static void callBatchClass(String parentId, String recordType){
        try{
        ImportExcelProcessor.UpdateFields(parentId, recordType); 
        }catch(Exception excep){
            throw new ImportExcelControllerException(excep.getMessage());
        }
    }
    
    
/** 
    *  Method to get Batch Process Progress
    *  @name getUploadProcessProgress
    *  @param Deal Id
    *  @return Upload Object Record
    *  @throws none
*/ 
    @AuraEnabled
    public static UploadObject__c getUploadProcessProgress(String parentId) {
         UploadObject__c uploadResult = new UploadObject__c();
        try{
        String query ='SELECT Comment__c,DealId__c,Id,LastModifiedBy.Name,LastModifiedDate,Name,'+
                        ' ObjectName__c,status__c, UploadObjectParent__c,Processed_Count__c, Success_Count__c, Total_Count__c'+
                        ' FROM UploadObject__c WHERE UploadObjectParent__c = null AND Id =\''+ parentId+'\' LIMIT 1';
    
        uploadResult = Database.query(query);
        }catch(Exception excep){
            throw new ImportExcelControllerException(excep.getMessage());
        }
         return uploadResult;
    }
/** 
    *  Method to get the get columns for Import Export
    *  @name getExportFieldSet
    *  @param Object Name , Field Set Name
    *  @return String
    *  @throws Exception
*/ 
    @AuraEnabled
    public static String getExportFieldSet(String sObjectName, String fieldSetName) {
        String tableheader = '';
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult objdes = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = objdes.fieldSets.getMap();
            if(FsMap.containsKey(fieldSetName)){
                for(Schema.FieldSetMember fsField : FsMap.get(fieldSetName).getFields()) {
                    if(tableheader != ''){
                        tableheader += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + fsField.getLabel() + '",';
                    jsonPart += '"required":"' + (fsField.getDBRequired() || fsField.getRequired()) + '",';
                    jsonPart += '"type":"' + (fsField.getType()) + '",';
                    jsonPart += '"fieldName":"' + fsField.getFieldPath() + '"';
                    jsonPart += '}';
                    tableheader += jsonPart;
            	}
            }
        }
        catch(Exception e){
            tableheader += e.getLineNumber() + ' : ' + e.getMessage();
        }
        return '['+tableheader+']';
    }
/** 
    *  Method to get the get permission details
    *  @name getPermissionDetails
    *  @param Object Name
    *  @return list of permission details
*/  
    @AuraEnabled
    public static List<ObjectPermissions> getPermissionDetails(String SObjectName){
        List<ObjectPermissions> permissionList = new List<ObjectPermissions>();
        try{
       		permissionList = CRM_UploadComponentController.getPermissionDetails(SObjectName);
        }catch(Exception excep){
            throw new ImportExcelControllerException(excep.getMessage());
        }
        return permissionList;
    }
/** 
    *  Method to get the get UploadObjects Errors
    *  @name getUploadObjects
    *  @param UploadId, Status
    *  @return list of error string
*/
    @AuraEnabled
    public static List<String> getUploadObjects(String uploadId,String status){
        List<String> comm = new List<String>();    
        try{
             for(UploadObject__C upObj : [SELECT Comment__c FROM UploadObject__c WHERE 
                                          (UploadObjectParent__c =: uploadId OR Id =: uploadId) and status__c =: status LIMIT 50000]){
                 List<String> temp = new List<String>();
                 if(upObj.Comment__c != null){
                     temp.add(upObj.Comment__c);
                 }
                comm.addAll(temp); 
   			}
 
        }catch(Exception excep){
            throw new ImportExcelControllerException(excep.getMessage());
        }
        return comm;
    }
/** 
    *  Method to get the get UploadObject Details
    *  @name getUploadObjectDetails
    *  @param UploadId
    *  @return uploadObject
*/
     @AuraEnabled
    public static UploadObject__c getUploadObjectDetails(String uploadId){
        UploadObject__C upObj = new UploadObject__C();
        try{
            upObj = [SELECT id,DealId__c,DealRecordType__c,status__c,DealId__r.Sales_Organisation__c FROM UploadObject__c where id =: uploadId LIMIT 50000];
        }catch(Exception excep){
            throw new ImportExcelControllerException(excep.getMessage());
        }
        return upObj;
    }

    
    //--W-017642-Added for retrive deal record to check SalesOrg for JV product-Start--//
/** 
    *  Method to check deal sales org
    *  @name isJVSalesOrgForUpload
    *  @param dealSalesOrg - opportunity sales org
    *  @return boolean flag as true if deal sale org has JV sale org
    *  @throws none
*/ 
    @AuraEnabled
    public static boolean isJVSalesOrgForUpload(String dealSalesOrg){
        return (dealSalesOrg == CRM_AppConstants.TERRITORY_SDS_US_CODE || dealSalesOrg == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE) ? true : false;
    }
    //--W-017642-Added for retrive deal record to check SalesOrg for JV product-End--//

/** 
    *  Class
    *  @name ImportExcelControllerException
    *  extends Exception Class
*/
    public without sharing class ImportExcelControllerException extends Exception {}
}