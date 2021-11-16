/*******************************************************************************************************************************************
* File Name     :   WB_checkAPOflagHandlerTest
* Description   :   Test class for Handler to check if any one of the storefront has APO flag set to Yes then only its Accounts APO flag can be set to Yes.
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     10 Dec.2015        CTS                ER-000008 : Created the class.
* 2.0       
********************************************************************************************************************************************/


@isTest
public class WB_checkAPOflagHandlerTest {
    
    public static Account acctGoogle;
    public static Country__c countryFrance;
    public static Language__c languageFrench;
    public static Agreement__c storefrontGoogle;
    
    static void setUpdata() {
        acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        countryFrance = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        insert countryFrance;
        
        languageFrench = TestUtil.initLanguage('TestFrench', '', 1);
        insert languageFrench;
        
        storefrontGoogle = TestUtil.initStoreFront2(acctGoogle.Id, countryFrance.Id);
        storefrontGoogle.Channel_Picklist__c = 'VODc';
        insert storefrontGoogle;
    }
    
    // To get error
    static testMethod void myUnitTest1() {
        
		setUpdata();
        
        Country__c countryUS = TestUtil.initCountry('TestUS', 'TS', 'TS');
        insert countryUS;
        
        Agreement__c storefrontGoogle2 = TestUtil.initStoreFront2(acctGoogle.Id, countryUS.Id);
        storefrontGoogle2.Channel_Picklist__c = 'VODi';
        insert storefrontGoogle2;
        
		Test.startTest();
		acctGoogle.APO__c = 'Yes';
		
		try {
            update acctGoogle;
		} catch (Exception e) {
		    system.assertEquals(true, e.getMessage().contains(Label.WB_Account_Storefront_APO_Flag));
		}
		Test.stopTest();
    }
    
    // Successful updation
    static testMethod void myUnitTest2() {
        
		setUpdata();
        
		Test.startTest();
		
		acctGoogle.APO__c = 'Yes';
		storefrontGoogle.APO__c = 'Yes';
		update storefrontGoogle;
		
		try {
            update acctGoogle;
		} catch (Exception e) {
		    system.assertEquals(true, e.getMessage().contains(Label.WB_Account_Storefront_APO_Flag));
		}
		Test.stopTest();
    }
}