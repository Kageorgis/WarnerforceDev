/**
 * @Author: Harshad Bidwai
 * @name CRM_ProcessAccountBatchForRBA_Test
 * @CreateDate 21st Feb 2017
 * @Description: Test class for CRM_ProcessAccountBatchForRBA
 * @Version 1.0
 */

@isTest 
public class CRM_ProcessAccountBatchForRBA_Test {

    @testsetup  
    public static void createTestDataForBatchNotificationStatus(){ 
        List<Batch_Notification_Recipients__c> userList  = BatchStatusNotificationTest.initUserDetails(2,'test@gmail.com','CRM');
        insert userList;
        System.assertEquals(2, [SELECT Id FROM Batch_Notification_Recipients__c ].size());
    }

    private static testMethod void createRBADeals(){
        List<Account> rbaAcct = CRM_TestDataFactory.createAccounts(5,false);
        for(Integer i=0; i<rbaAcct.size(); i++){
                rbaAcct[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
                rbaAcct[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
                rbaAcct[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
                rbaAcct[i].Video_Physical__c = true;

        }
        insert rbaAcct;    
        
        Test.startTest();
        Id batchJobId = Database.executeBatch(new CRM_ProcessAccountBatchForRBA());
        Test.stopTest();
        
        // Verify 30 valid opportunity records present
        System.assertEquals(30, [SELECT Id FROM Opportunity].size());
 }   
    
    private static testmethod void NegativeTest() {
        try {
             List<Account> rbaAcct = CRM_TestDataFactory.createAccounts(5,false);
             for(Integer i=0; i<rbaAcct.size(); i++){
                    rbaAcct[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
                    rbaAcct[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
                    rbaAcct[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
               }
              insert rbaAcct;
              System.assertEquals(0, [SELECT Id FROM CRM_Error_Log__c].size());
              throw new TestException('Exception');
        } catch (Exception ex) {
            Test.startTest();
            CRM_ProcessAccountBatchForRBA instance = new CRM_ProcessAccountBatchForRBA();
            List<CRM_ErrorLogger.ErrorLog> lstErrors = CRM_DatabaseErrorHandlerForRBA.logAnException(ex);
            Database.executeBatch(instance, 10);
            CRM_DatabaseErrorHandlerForRBA.SendMail(instance.lstExceptions);
            Test.stopTest();
            System.assertEquals(1, lstErrors.size());
        }
    }
    
    public class TestException extends Exception {
    } 
    
    
}