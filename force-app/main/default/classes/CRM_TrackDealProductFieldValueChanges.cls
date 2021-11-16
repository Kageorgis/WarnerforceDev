/**
@Author: Accenture
@name: CRM_TrackDealProductFieldValueChanges
@CreateDate: August 11, 2020
@Description: Apex class called from After Trigger/After Delete/After Insert context to track field value changes of Deal Product (OpportunityLineItem) as a part of history tracking (Audit Purpose).
@Version - 1.0
@reference: None
*/

public with sharing class CRM_TrackDealProductFieldValueChanges {
    
    /** 
    *  Method to check for field value changes and based on the changes for the fields setup to track create data in a custom object for history tracking
    *  @name trackFieldValueChanges
    *  @param trigger new List, trigger old Map
    *  @return void
    *  @throws none
	*/
    public static void trackFieldValueChanges(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> oldMap){      
        List<OpportunityLineItem> dealProductList = new List<OpportunityLineItem>(); //List to store the deal product records which needs to be tracked (as per the Deal Record Type)
        List<Deal_Product_Field_History_Tracking__mdt> fieldAuditList = new List<Deal_Product_Field_History_Tracking__mdt>(); //List to store the audit field details for the current object as configured in the custom metadata
        List<Deal_Product_Field_History_Tracker__c> fieldHistoryTrackRecordCreateList = new List<Deal_Product_Field_History_Tracker__c>(); //List to store the records that needs to be created in the custom object for field history tracking
        
        Map<String, Schema.SObjectField> fieldDetailsMap = Schema.SObjectType.OpportunityLineItem.fields.getMap();
        
        DataWrapper dw = new DataWrapper();
        
        fieldAuditList = [SELECT Id, Deal_Product_Field_API_Name__c, Deal_Product_Field_Name__c FROM Deal_Product_Field_History_Tracking__mdt WHERE Track_Changes__c=true];

        try{
            if(!fieldAuditList.isEmpty()){
                for(OpportunityLineItem oli : newList){
                    if(Label.CRM_DealProductTrackFieldHistory_DealRecordTypes.contains(oli.Deal_Record_Type__c)){
                        dealProductList.add(oli);
                    }
                }
                
                dw.fieldAuditList = fieldAuditList;
                dw.fieldDetailsMap = fieldDetailsMap;
                
                if(!dealProductList.isEmpty()){
                    fieldHistoryTrackRecordCreateList = createHistoryTrackerRecordList(dealProductList, oldMap, dw);
                }
            }
            
            if(!fieldHistoryTrackRecordCreateList.isEmpty()){
                Database.SaveResult[] saveResultList =  Database.insert(fieldHistoryTrackRecordCreateList, false);
            }
        }catch(Exception e){
            System.debug('CRM_TrackFieldValueChanges -> Error occurred :' + ' Line ' + e.getLineNumber() + ' Message - ' + e.getMessage());
        }
    }
    
    /** 
    *  Method to check for field value changes from the trigger conteaxt as per the fields to be tracked and build the data to be created based on that
    *  @name createHistoryTrackerRecordList
    *  @param trigger new List, trigger old Map, data wrapper (which will contain the fields to be tracked)
    *  @return List of records that need to be created for field value changes history tracking
    *  @throws none
	*/
    private static List<Deal_Product_Field_History_Tracker__c> createHistoryTrackerRecordList(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> oldMap, DataWrapper dw){
        List<Deal_Product_Field_History_Tracker__c> fieldHistoryTrackRecordCreateList = new List<Deal_Product_Field_History_Tracker__c>();
        List<Deal_Product_Field_History_Tracking__mdt> fieldAuditList = dw.fieldAuditList;
        
        for(Deal_Product_Field_History_Tracking__mdt fht : fieldAuditList){
            for(OpportunityLineItem oli : newList){
                if(oli.get(fht.Deal_Product_Field_API_Name__c)!=oldMap.get(oli.Id).get(fht.Deal_Product_Field_API_Name__c)){
                    Schema.SObjectField field = dw.fieldDetailsMap.get(fht.Deal_Product_Field_API_Name__c);
                    Schema.DisplayType fieldType = field.getDescribe().getType();

                    Deal_Product_Field_History_Tracker__c fhtCreate = new Deal_Product_Field_History_Tracker__c();
                    fhtCreate.Field_API_Name__c = fht.Deal_Product_Field_API_Name__c;
                    fhtCreate.Field_Name__c = fht.Deal_Product_Field_Name__c;
                    fhtCreate.Modified_By_Id__c = UserInfo.getUserId();
                    fhtCreate.Modified_By_Name__c = UserInfo.getName();
                    fhtCreate.Modified_Date_Time__c = DateTime.now();
                    if(String.valueOf(fieldType).toUpperCase()=='CURRENCY'){
                        fhtCreate.New_Value__c = oli.CurrencyIsoCode + ' ' + String.valueOf((Decimal)oli.get(fht.Deal_Product_Field_API_Name__c));
                        fhtCreate.Old_Value__c = oli.CurrencyIsoCode + ' ' + String.valueOf((Decimal)oldMap.get(oli.Id).get(fht.Deal_Product_Field_API_Name__c));
                    }else if(String.valueOf(fieldType).toUpperCase()=='PERCENT' || String.valueOf(fieldType).toUpperCase()=='DOUBLE'){
                        fhtCreate.New_Value__c = String.valueOf((Decimal)oli.get(fht.Deal_Product_Field_API_Name__c));
                        fhtCreate.Old_Value__c = String.valueOf((Decimal)oldMap.get(oli.Id).get(fht.Deal_Product_Field_API_Name__c));
                    }else if(String.valueOf(fieldType).toUpperCase()=='DATE'){
                        fhtCreate.New_Value__c = String.valueOf((Date)oli.get(fht.Deal_Product_Field_API_Name__c));
                        fhtCreate.Old_Value__c = String.valueOf((Date)oldMap.get(oli.Id).get(fht.Deal_Product_Field_API_Name__c));
                    }else if(String.valueOf(fieldType).toUpperCase()=='DATETIME'){
                        fhtCreate.New_Value__c = String.valueOf((DateTime)oli.get(fht.Deal_Product_Field_API_Name__c));
                        fhtCreate.Old_Value__c = String.valueOf((DateTime)oldMap.get(oli.Id).get(fht.Deal_Product_Field_API_Name__c));
                    }else{
                        fhtCreate.New_Value__c = String.isNotBlank((String)oli.get(fht.Deal_Product_Field_API_Name__c))?(String)oli.get(fht.Deal_Product_Field_API_Name__c):'';
                        fhtCreate.Old_Value__c = String.isNotBlank((String)oldMap.get(oli.Id).get(fht.Deal_Product_Field_API_Name__c))?(String)oldMap.get(oli.Id).get(fht.Deal_Product_Field_API_Name__c):'';
                    }
                    fhtCreate.Deal__c = oli.OpportunityId;
                    fhtCreate.Product__c = oli.Product2Id;
                    fhtCreate.Deal_Product_Id__c = oli.Id;
                    fhtCreate.Deal_Product_Name__c = oli.Product_Name__c;
                    
                    fieldHistoryTrackRecordCreateList.add(fhtCreate);
                }
            }
        }

        return fieldHistoryTrackRecordCreateList;
    }
    
    /**
    *  @Description - wrapper class to contain the details of the fields that needs to be tracked for value changes
    *  @name  DataWrapper 
    */
    public class DataWrapper{
        public List<Deal_Product_Field_History_Tracking__mdt> fieldAuditList{
            get; set;
        }
        public Map<String, Schema.SObjectField> fieldDetailsMap{
            get; set;
        }
    }
    
	/** 
    *  Method to add record entry in the custom object for deal product history tracking during Deal Product Creation/Deletion
    *  @name dealProductCreateDeleteAuditEntry
    *  @param dealProductList (Trigger.new for AfterInsert OR Trigger.old for AfterDelete), operation (Create/Delete)
    *  @return void
    *  @throws none
	*/
    public static void dealProductCreateDeleteAuditEntry(List<OpportunityLineItem> dealProductList, String operation){
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>(); //List to store the deal product records which needs to be tracked (as per the Deal Record Type)
        List<Deal_Product_Field_History_Tracker__c> fieldHistoryTrackRecordCreateList = new List<Deal_Product_Field_History_Tracker__c>(); //List to store the records that needs to be created in the custom object for fied history tracking
        
        try{
            for(OpportunityLineItem oli : dealProductList){
                if(Label.CRM_DealProductTrackFieldHistory_DealRecordTypes.contains(oli.Deal_Record_Type__c)){
                    oliList.add(oli);
                }
            }
            
            if(!oliList.isEmpty()){
                for(OpportunityLineItem oli : oliList){
                    Deal_Product_Field_History_Tracker__c fhtCreate = new Deal_Product_Field_History_Tracker__c();
                    fhtCreate.Field_Name__c = (operation.toUpperCase()=='CREATE' || operation.toUpperCase()=='INSERT')?'Record Created':operation.toUpperCase()=='DELETE'?'Record Deleted':'';
                    fhtCreate.Field_API_Name__c = 'Id';
                    fhtCreate.Modified_By_Id__c = UserInfo.getUserId();
                    fhtCreate.Modified_By_Name__c = UserInfo.getName();
                    fhtCreate.Modified_Date_Time__c = DateTime.now();
                    fhtCreate.New_Value__c = '';
                    fhtCreate.Old_Value__c = '';
                    fhtCreate.Deal__c = oli.OpportunityId;
                    fhtCreate.Product__c = oli.Product2Id;
                    fhtCreate.Deal_Product_Id__c = oli.Id;
                    fhtCreate.Deal_Product_Name__c = oli.Product_Name__c;
                    
                    fieldHistoryTrackRecordCreateList.add(fhtCreate);
                }
            }
            
            if(!fieldHistoryTrackRecordCreateList.isEmpty()){
                Database.SaveResult[] saveResultList =  Database.insert(fieldHistoryTrackRecordCreateList, false);
            }
        }catch(Exception e){
            System.debug('CRM_TrackFieldValueChanges -> Error occurred :' + ' Line ' + e.getLineNumber() + ' Message - ' + e.getMessage());
        }
    }
}