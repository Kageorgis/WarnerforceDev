/******* 
WBCP_ContractChannelsTrigger_Test
Creation Date- 22 July 2021
Description- This class is to do code coverage for WBCP_ContractChannelsTrigger
Author- Nilesh Jha
*******/
@isTest
public class WBCP_ContractChannelsTrigger_Test {
    static testMethod void ContractChannelsTest(){
        Test.startTest();
        String licenseeRecTypeId = CP_ProductUtility.getRecordTypeId(CP_Contract__c.getSobjectType(),'WBCP Contracts'); 
        CP_Contract__c contract = new CP_Contract__c(Name='TEST',Contract_No__c='10001');
        contract.RecordTypeId=licenseeRecTypeId;
        insert contract;
        Contract_Channels__c contractChannels = new Contract_Channels__c(Chnl_Of_Dist_Remap__c='CT-01',Contract_No__c='10001'); 
        insert contractChannels;
        Test.stopTest(); 
    }
}