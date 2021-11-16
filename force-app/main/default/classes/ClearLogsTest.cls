/* Test Class for ClearLogs batch */
@isTest
private class ClearLogsTest
{
    static testmethod void testClearLogs()
    {
       Test.startTest();
       /*DateTime dt = DateTime.now().addMOnths(-7);
       String createdDate = dt.format('yyyy-MM-dd')+'T'+dt.format('HH:mm')+':00.000Z';
       String keyPrefix = Transaction_Log__c.getSObjectType().getDescribe().getKeyPrefix();
       String transLogJSON = '{"attributes":{"type":"Transaction_Log__c","url":"/services/data/v25.0/sobjects/Transactin_Log__c/'+keyPrefix+'J0000005v1LH"},"Id":"'+keyPrefix+'J0000005v1LH","Status__c":"Failure","CreatedDate":"'+ createdDate +'"}'; 
       System.debug('MYDEBUG transLogJSON : ' + transLogJSON );
       Transaction_Log__c tl = (Transaction_Log__c)JSON.deserialize(transLogJSON, Transaction_Log__c.class); 
       
       System.debug('Test log : ' + tl.createdDate); 
       */
       ClearLogs c = new ClearLogs();
       Database.executeBatch(c);
       
       List<sObject> scope = new List<sObject>();
       //scope.add(tl);
       Database.BatchableContext bc;
       c.execute(bc, scope);
       
       Test.stopTest();
    }
}