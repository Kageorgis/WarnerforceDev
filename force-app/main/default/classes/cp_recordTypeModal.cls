/**
 * Created by XMMORENO on 3/5/2020.
 */

public with sharing class cp_recordTypeModal {
    @AuraEnabled
    public static ListView getListViews() {
        ListView listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Account' AND Name = 'WBCP Licensees' LIMIT 1];

        // Perform isAccessible() check here
        return listviews;
    }
        public static Map<Id, String> recordtypemap {get;set;}

        @AuraEnabled
        public static List<String> fetchRecordTypeValues(){
            List<Schema.RecordTypeInfo> recordtypes = Account.SObjectType.getDescribe().getRecordTypeInfos();
            recordtypemap = new Map<Id, String>();
            for(RecordTypeInfo rt : recordtypes){
                if(rt.getName() != 'Master')
                    recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }
            return recordtypemap.values();
        }

        @AuraEnabled
        public static Id getRecTypeId(String recordTypeLabel){
            Id recid = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();
            return recid;
        }
        @AuraEnabled
        public static String createRelatedProperties(Id accId, List<SObject> props, String accRecName){
            List<Licensee_Property__c> newProps = new List<Licensee_Property__c>();
            for(SObject prop: props){
                Licensee_Property__c newProp = new Licensee_Property__c();
                newProp.Property__c = prop.Id;
                newProp.Account__c = accId;
                newProps.add(newProp);

            }
            insert newProps;
            return  newProps.size()+' properties were successfully added to '+accRecName;
        }
    @AuraEnabled
    public static String createRelatedRetailers(Id accId, List<SObject> retls, String accRecName){
        List<Licensee_Related_Retailer__c> newRetls = new List<Licensee_Related_Retailer__c>();
        for(SObject retl: retls){
            Licensee_Related_Retailer__c newRetl = new Licensee_Related_Retailer__c();
            newRetl.Retailer_Description__c = retl.Id;
            newRetl.Related_Licensee__c= accId;
            newRetls.add(newretl);

        }
        insert newRetls;
        return  newRetls.size()+' retailers were successfully added to '+accRecName;
    }
}