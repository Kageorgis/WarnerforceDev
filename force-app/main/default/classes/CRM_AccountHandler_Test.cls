/**
   @Author Cognizant
   @name CRM_AccountHandler_Test
   @CreateDate 27 Dec 2016
   @Description Test class for CRM_AccountHandler
   @Version <1.0>
  */

@isTest(seeAllData=false)
public class CRM_AccountHandler_Test {
    
  /**
    *  Test 2: Test to insert account and set Physical Product Flag.
    *  Expected: Physical Product Flag set on Accounts.
    *  @name insertAccounts
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void insertAccounts(){   
        CRM_TestDataFactory.createCustSettingForAccount();
        Test.startTest();
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(8, false);
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        lstAccounts[1].Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
        lstAccounts[2].Sales_Organization__c = CRM_AppConstants.TERRITORY_BELGIUM_CODE;
        lstAccounts[3].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        lstAccounts[4].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        lstAccounts[5].Sales_Organization__c = CRM_AppConstants.TERRITORY_ITALY_CODE;
        lstAccounts[6].Sales_Organization__c = CRM_AppConstants.TERRITORY_SPAIN_CODE;
        lstAccounts[7].Sales_Organization__c = CRM_AppConstants.TERRITORY_FINLAND_CODE;
        for (Account acc : lstAccounts) {
            acc.Games_Physical__c = false;
            acc.Video_Physical__c = false;
        }
        insert lstAccounts;
        Test.stopTest();

        for(Account acc : [Select Sales_Organization__c,Games_Physical__c,Video_Physical__c,Music_Physical__c,Storefront__c From Account where ID IN :lstAccounts]){
            if(acc.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE){
                System.assertEquals(true,acc.Games_Physical__c,'Game Physical Flag must be Set for Japan.');
                System.assertEquals(true,acc.Video_Physical__c,'Video Physical Flag must be Set for Japan.');   
                System.assertEquals(true,acc.Music_Physical__c,'Music Physical Flag dose not set for Japan.');
            } else {
                System.assertEquals(true, acc.Games_Physical__c, 'Game Physical Flag must be Set for France,Netherland,Belegium, Germany, Italy, Spain, Nordics.');
                System.assertEquals(true,acc.Video_Physical__c,'Video Physical Flag must be Set for France,Netherland,Belegium, Germany, Italy, Spain, Nordics.');
                System.assertEquals(false,acc.Music_Physical__c,'Music Physical Flag dose not set for France,Netherland,Belegium, Germany, Italy, Spain, Nordics.');
            }
        }
    }

}