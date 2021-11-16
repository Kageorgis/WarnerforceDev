/**
 * Created by XMMORENO on 3/3/2020.
 */

public with sharing class cp_RetailDescriptionController {
        @AuraEnabled
        public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList) {
            String searchKey = '%' + searchKeyWord + '%';
            List < sObject > returnList = new List < sObject > ();
            System.debug('The excluded Items -->'+ExcludeitemsList);
            List<string> lstExcludeitems = new List<string>();
            for(sObject item : ExcludeitemsList ){
                lstExcludeitems.add(item.id);
            }

            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records
            String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';
            List < sObject > lstOfRecords = Database.query(sQuery);

            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            return returnList;
        }
    @AuraEnabled
    public static List < sObject > fetchRetailerValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList) {
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();

        List<string> lstExcludeitems = new List<string>();
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.id);
        }

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records
        String sQuery =  'select id, Name, Retailer_Grouping__c from ' +ObjectName + ' where Name LIKE: searchKey AND RecordType.DeveloperName = \'WBCP_Retailer\' AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    }