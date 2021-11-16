@isTest
public class BatchStatusNotificationTest {

    
    //Create Custom Setting records
    public Static List<Batch_Notification_Recipients__c> initUserDetails(Integer noOfRecs,String emailId,String entity){
        List<Batch_Notification_Recipients__c> userLst = new List<Batch_Notification_Recipients__c>();
            for(Integer i=0;i<noOfRecs;i++){
            userLst.add(new Batch_Notification_Recipients__c (User_Email_Id__c = emailId,
                                               Entity__c = entity,
                                               Name='User'+ i));
        }
        return userLst;
    }
    private static testMethod void RightsWithConfirmedStatus() {
        List<Batch_Notification_Recipients__c> userList  = initUserDetails(2,'test@gmail.com','CAS');
        insert userList;
        
        String entity = 'CAS';
        String batchJobName = 'Test Batch';
        String Status = 'Completed';
        String errorMessage = 'Successfully executed'; 
        Integer totalJobItems = 10;
        Integer noOfErrors = 0;
        
        test.startTest();
        BatchStatusNotification b = new BatchStatusNotification();
        b.sendEmailToUsers(entity,batchJobName, Status,totalJobItems,noOfErrors,errorMessage);
        test.stopTest();


    }
    
    private static testMethod void NegativeTest() {
        List<Batch_Notification_Recipients__c> userList  = initUserDetails(2,'test@gmail.com','CAS');
        insert userList;
        
        String entity = 'CAS';
        String batchJobName = 'Test Batch';
        String Status = 'Completed';
        String errorMessage = 'Successfully executed';
        Integer totalJobItems = 10;
        Integer noOfErrors = 5;
        
        test.startTest();
        BatchStatusNotification b = new BatchStatusNotification();
        b.sendEmailToUsers(entity,batchJobName, Status,totalJobItems,noOfErrors,errorMessage);
        test.stopTest();
    }
     

}