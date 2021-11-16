@isTest
private class CP_ValidContractAgentTest {
    @isTest
    static void getValidContractsTest(){
        Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        Account acc2 = new Account();
        insert acc1;
        acc2.Name = 'Test Account2';
        acc2.ParentId = acc1.Id;
        insert acc2;
        List<Id> contractId = new List<Id>();
        CP_Contract__c contractRecord = new CP_Contract__c();
        contractRecord.Name = '1234';
        contractRecord.Source_System__c = 'LMSi';
        contractRecord.Account_Licensee__c = acc2.Id;
        insert contractRecord;
        contractId.add(contractRecord.Id);
        CP_Contract__c contractRecord2 = new CP_Contract__c();
        contractRecord2.Name = '1234';
        contractRecord2.Source_System__c = 'LMSi';
        insert contractRecord2;
        contractId.add(contractRecord2.Id);
        CP_ValidContractAgent.validContracts(acc1.Id);
    }
}