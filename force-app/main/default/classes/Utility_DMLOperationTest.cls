/*
Class Name   : Utility_DMLOperationTest
Description  :  This class has Test Data and perform CRUD operations             
Created By   : Cognizant Technology Solutions - Shekhar Vinayak
Created On   :  19th Aug 2015

Change History:
--------------------------------------------------------------------------------------------------------------------------------------------------
Sr#             Description                                                 Updated By                                     Updated On
--------------------------------------------------------------------------------------------------------------------------------------------------


*/

@isTest
public with sharing class Utility_DMLOperationTest {

    
      public Id insertObject(sObject sobj) {
        
        Database.saveResult result;
        result = Database.insert(sobj);
        return result.getId();
    }
    
    /* Insert record  method */
    public List<sObject> multiInsertObject(sObject[] sobj) {
        List<Id> ids = new List<Id>();
        Database.saveResult[] results;
        if ((Limits.getDMLRows() + sobj.size()) > Limits.getLimitDMLRows())
        {
            System.debug(LoggingLevel.ERROR,'Governor Limit Exceeded : ');
            System.debug(LoggingLevel.ERROR,'DMLRows invoked in the Current Context:' + Limits.getDMLRows());
            System.debug(LoggingLevel.ERROR,'DMLRows available For Current Context :' + Limits.getLimitDMLRows());
           // throw new GovernorLimitException('This operation may violate governor limit, hence aborting.');  
        }
        else
        {
            results = Database.insert(sobj, true);
            System.debug(LoggingLevel.INFO,'DMLRows invoked in the Current Context:' + Limits.getDMLRows());
            System.debug(LoggingLevel.INFO,'DMLRows available For Current Context :' + Limits.getLimitDMLRows());
        }

        return sObj;
    }   
    /* Update record  method */
    public sObject updateObject(sobject sobj){ 
        Database.saveResult result;
        
        result = Database.update(sobj);   
        return sobj;
    }
    
    /* Update muliple records  method */
    public List<sObject> multiUpdateObject(sobject[] sobj){
        List<Id> ids = new List<Id>(); 
        Database.saveResult[] results;
        results = Database.update(sobj);   
        return sobj;
    }    
    
    /* Delete record  method */
    public sObject deleteObject(sObject sobj) { 
        Database.deleteResult result;             
        result = Database.delete(sobj);
        return sobj;
    }
    
    /* Delete multiple records  method */
    public List<sObject> deleteMultiObject(sObject[] sobj) { 
        List<Id> ids = new List<Id>();
        Database.deleteResult[] results;             
        results = Database.delete(sobj);
        return sobj;
    }    
    
    
    private static testMethod void test() {

    }

}