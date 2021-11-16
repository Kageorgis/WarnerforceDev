/**
    @Author Accenture
    @name CRM_UploadComponentController
    @CreateDate  Mar 2020
    @Description This class is used to Import(update/insert) the deal products for POS and DFI deals.
    @Version <1.0>
*/
global with sharing class CRM_UploadComponentController {
    
/** 
    *  Method to fetch the fieldSet Values  
    *  @name getFieldSet
    *  @param SObjectName and FieldSetName
    *  @return String of FieldSet Labels
    *  @throws exception
*/
    @AuraEnabled
    public static String getFieldSet(String sObjectName, String fieldSetName) {
        String result = '';
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult describeSObject = objToken.getDescribe();
            Map<String, Schema.FieldSet> fsMap = describeSObject.fieldSets.getMap();
            List<ObjectPermissions> permissionDetails = CRM_UploadComponentController.getPermissionDetails('Opportunity');
            Boolean isEditable = permissionDetails[0].PermissionsEdit;
            String label = System.Label.EditablePOSAndDFIFields;
            if(fsMap.containsKey(fieldSetName)){
                for(Schema.FieldSetMember f : fsMap.get(fieldSetName).getFields()) {
                    if(result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel() + '",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired()) + '",';
                    jsonPart += '"type":"' + (f.getType()) + '",';
                    if(label.contains(f.getFieldPath()) && isEditable){
                        jsonPart += '"editable": true ,';
                    }else{
                        jsonPart += '"editable": false ,';
                    }
                    jsonPart += '"fieldName":"' + f.getFieldPath() + '"';
                    jsonPart += '}';
                    result += jsonPart;
                }
            }
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
        }
        return '['+result+']';
    }
    
/** 
    *  Method to fetch the picklist values from the field
    *  @name getselectOptions
    *  @param SObjectName and FieldName
    *  @return List of Picklist Values
    *  @throws none
*/
    @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, string fld,String recordType,String salesOrg) {
        List < String > allOpts = new list < String > ();
        try{
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        List < Schema.PicklistEntry > values = fieldMap.get(fld).getDescribe().getPickListValues();
            for (Schema.PicklistEntry a: values) {
                if(recordType.equals(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_POS_DEAL)
                   && (System.Label.POS_DFI_Reason_PickList_Values).contains(a.getValue())){
                       allOpts.add(a.getValue());
                   } //ER-007552- Check CoopReason if Deal is from SDS  
                else if(CRM_AppConstants.SALES_JV_ORGS.contains(salesOrg) && recordType.equals(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_POS_DEAL) && 
                        (System.Label.CRMJV_POS_DFI_Reason_PickList_Values).contains(a.getValue())){
                            allOpts.add(a.getValue());
                        }
                else if(recordType.equals(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_DFI_DEAL)
                        && (System.Label.CRM_DFI_Reason_Picklist_Values).contains(a.getValue())){
                            allOpts.add(a.getValue());
                        }
                else if((!fld.equals(System.Label.CRM_Reason) 
                         && (!fld.equals(System.Label.CRM_Account_Fund_Segment))) ||
                        ((fld.equals(System.Label.CRM_Account_Fund_Segment) && 
                          recordType.equals(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_POS_DEAL))) ){
                              allOpts.add(a.getValue());
                          }
            }
        allOpts.sort();
        }catch(Exception except){
            throw new CRM_UploadComponentControllerException(except.getMessage());
        }
        return allOpts;
    }
    
/** 
    *  Method to fetch the Deal Data 
    *  @name getDealData
    *  @param SObjectName, tablColNames and condition
    *  @return List of Deal Attributes
    *  @throws none
*/
    @AuraEnabled
    public static List<sObject> getDealData(String sObjectName , String tablColNames, String whereCondition){
        List<sObject> records = new List<sObject>();
        try{
        List<String> fieldNames = (List<String>) JSON.deserialize(tablColNames, List<String>.class);
        String query = 'SELECT Id,' + String.join(fieldNames, ',') +  ' FROM ' +sObjectName+'' +whereCondition +'Limit 50000';
        for(sObject s : Database.query(query)){
            records.add(s);
            }
        }catch(Exception except){
            throw new CRM_UploadComponentControllerException(except.getMessage());
        }
        return records; 
    }
    
/** 
    *  Method to fetch the Deal Data 
    *  @name getdata
    *  @param SObjectName, Deal Id and fieldName
    *  @return List of Deal Attributes
    *  @throws none
*/
    @AuraEnabled
    public static List<OpportunityLineItem> getdata(String oppId, String sObjectName,String fieldNameJson){
        List<OpportunityLineItem> records = new List<OpportunityLineItem>();
        try{
        List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
        String query = 'SELECT Id,' + String.join(fieldNames, ',') +  
                    ' FROM ' +sObjectName + ' WHERE OpportunityId =: oppId ORDER BY LastModifiedDate DESC Limit 50000';
        for(OpportunityLineItem s : Database.query(query)){
            records.add(s);
        }
        }catch(Exception except){
            throw new CRM_UploadComponentControllerException(except.getMessage());
        }
        return records;
    }
    
/** 
    *  Method to fetch the Filter Data for Advanced Search 
    *  @name getOpptyLineItemFilter
    *  @param none
    *  @return List of Filter Data Values
    *  @throws none
*/    
    @AuraEnabled
    public static List<Filter_Fields__mdt> getOpptyLineItemFilter(){
        list<Filter_Fields__mdt> opptyFilterSearch = new list<Filter_Fields__mdt>();
        try{
         opptyFilterSearch = [Select Id,Label,Type__c,Field_Name__c,Searchable__c from Filter_Fields__mdt LIMIT 50000];
        }catch(Exception except){
            throw new CRM_UploadComponentControllerException(except.getMessage());
        }
        return opptyFilterSearch;
    }
    
/** 
    *  Method to save the data on QuickSave
    *  @name saveData
    *  @param Deal Id
    *  @return Json data
    *  @throws none
*/ 
    @AuraEnabled
    public static String saveData(String opplt, String dealId){ 
        String result = '';
        try{
         result = JSON.serializePretty(CRM_UploadExtractPOSandDFI.savePOSAndDFIDealLineItems(opplt,dealId,true));
        }catch(Exception except){
            throw new CRM_UploadComponentControllerException(except.getMessage());
        }
    return result;
    } 
    
/** 
    *  Method to dealselected records
    *  @name delSelectedRecords
    *  @param List of Deal Id
    *  @return status of delete
    *  @throws none
*/ 
    @AuraEnabled
    public static string delSelectedRecords(String delList, String dealId){
        String result = '';
        try{
         result = JSON.serializePretty(CRM_UploadExtractPOSandDFI.deletedRecordsPOSandDFI(delList,dealId));
        }catch(Exception except){
            throw new CRM_UploadComponentControllerException(except.getMessage());
        }
    return result;
    }
    
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
        lstOpportunity = [SELECT id,name,RecordTypeId,RecordType.Name,
                                      Sales_Organisation__c,Account.Digital_Country_Code__c,StageName,
                                      Pricebook2Id,AccountId,CurrencyISOCode,External_Id__c,
                                      CloseDate,Start_Date__c 
                                      FROM Opportunity 
                                      WHERE Id =: oppId LIMIT 50000];
        }catch(Exception except){
            throw new CRM_UploadComponentControllerException(except.getMessage());
        }
        return lstOpportunity;
    }
    
/** 
    *  Method to fetch the User Permission Details
    *  @name getPermissionDetails
    *  @param SObject Name
    *  @return List of Object Permissions for the User logged in
    *  @throws none
*/ 
    @AuraEnabled
    public static List<ObjectPermissions> getPermissionDetails(String SObjectName){
         List<ObjectPermissions> objPermissions = new List<ObjectPermissions>();
        try{
        Profile profileName = [select id,Name from Profile where id=:Userinfo.getProfileid() LIMIT 50000];
         objPermissions = [
            select Id, SObjectType, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete
            from ObjectPermissions
            where SObjectType =: SObjectName
            and ParentId in (
                select id
                from PermissionSet
                where PermissionSet.IsOwnedByProfile = true and PermissionSet.Profile.Name=: profileName.Name)
        LIMIT 1];
            if(profileName.Name == CRM_AppConstants.SALES_ADMIN_PROFILE_NAME){
                objPermissions[0].PermissionsEdit = false;
            }
        }catch(Exception except){
            throw new CRM_UploadComponentControllerException(except.getMessage());
        }
        return objPermissions;
    }
    
    //--W-017642-Added for retrive deal record to check SalesOrg for JV product-Start--//
/** 
    *  Method to check deal sales org
    *  @name isJVSalesOrg
    *  @param dealSalesOrg - opportunity sales org
    *  @return boolean flag as true if deal sale org has JV sale org
    *  @throws none
*/ 
    @AuraEnabled
    public static boolean isJVSalesOrg(String dealSalesOrg){
        return (dealSalesOrg == CRM_AppConstants.TERRITORY_SDS_US_CODE || dealSalesOrg == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE) ? true : false;
    }
    //--W-017642-Added for retrive deal record to check SalesOrg for JV product-End--//

/**
*  @Description - Exception class
*  @name  CRM_UploadComponentControllerException 
*/   
    public class CRM_UploadComponentControllerException extends Exception {}
}