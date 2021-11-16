/**
 * Created by XMMORENO on 6/8/2020.
 */

public with sharing class cp_licenseeLookupController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';

        List < sObject > returnList = new List < sObject > ();

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND RecordType.DeveloperName = \'WBCP_Licensee\' order by Name Limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    @AuraEnabled
    public static List < sObject > fetchPropertyValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';

        List < sObject > returnList = new List < sObject > ();

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by Name limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}