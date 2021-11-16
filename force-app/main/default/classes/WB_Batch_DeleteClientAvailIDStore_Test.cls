/*
Class Name   : WB_Batch_DeleteClientAvailIDStore_Test 
Description  : This class is to do code coverage for WB_Batch_DeleteClientAvailIDStore class    
Created By   : Cognizant Technology Solutions - Milon Dey
Created On   : JAN 2016

Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

CH01   Added Assertion statements for the required business             Akash Dalvi                                        4/27/2016
       scenarios.                        
*/

@isTest
private class WB_Batch_DeleteClientAvailIDStore_Test {

    @isTest
    static void myTest(){
        string idsToStore = getClientAvailIdString();
        List<Client_Avail_Id_Store__c> caList = new List<Client_Avail_Id_Store__c>();
        Client_Avail_Id_Store__c obj = new Client_Avail_Id_Store__c(
            Re_Price_User__c = userInfo.getUserId(),
            Key__c = 'Test Key',
            ID_Store__c = idsToStore
        );
        caList.add(obj);
        insert caList;
        
        Test.startTest();
        
            WB_Batch_DeleteClientAvailIDStore objBatch = new WB_Batch_DeleteClientAvailIDStore();
            ID batchprocessid = Database.executeBatch(objBatch,200);
            objBatch.execute(null,caList);
        
        Test.stopTest();
    }
    
    @isTest(seeAllData=true)
    static string getClientAvailIdString(){
        List<Client_Avail__c> clientAvailList = [select Id from Client_Avail__c limit 10];
        //system.assertNotEquals(clientAvailList.size(),null);
        string idsToStore = '';
        if(clientAvailList != null && clientAvailList.size() > 0){
            for(Client_Avail__c obj : clientAvailList){
                idsToStore = (idsToStore == '') ? string.valueOf(obj.Id) : idsToStore + ',' + obj.Id;
            }
        }
        //system.assertNotEquals(idsToStore,null);
        return idsToStore;
    }
}