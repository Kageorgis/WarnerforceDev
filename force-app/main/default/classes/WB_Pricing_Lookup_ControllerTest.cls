/*******************************************************************************************************************************************
* File Name     :   WB_Pricing_Lookup_ControllerTest
* Description   :   Test class for Class WB_Pricing_Lookup_Controller
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     1 Mar.2016       CTS                  Created the class.
* 2.0       
********************************************************************************************************************************************/

@isTest
private class WB_Pricing_Lookup_ControllerTest {
    
    public static Account acctGoogle;
    public static Title__c title1;
    public static Country__c countryFrance;
    public static Language__c languageFrench;
    public static Local_Title__c localTitle;
    public static Commercial_Avail__c CommercialAvail;
    public static Agreement__c storefrontGoogle1;
    public static Pricing__c pricing;
    public static List<Client_Avail__c> clientAvailList;
    
    static void setUpdata() {
        acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        title1 = TestUtil.initTitle('TestGoogle', '6000047545');
        title1.Formats__c = 'SD';
        insert title1;
        
        countryFrance = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        insert countryFrance;
        
        languageFrench = TestUtil.initLanguage('TestFrench', '', 1);
        insert languageFrench;
        
        localTitle = TestUtil.initLocalTitle(languageFrench.Id, countryFrance.Id);
        insert localTitle;
        
        CommercialAvail = TestUtil.initReleasePlan(title1.Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        insert CommercialAvail;
        
        storefrontGoogle1 = TestUtil.initStoreFront(acctGoogle.Id, countryFrance.Id, CommercialAvail, title1);
        insert storefrontGoogle1;
        
        pricing = TestUtil.initPricing(acctGoogle.Id, countryFrance.Id);
        insert pricing;
        
        clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(acctGoogle.Id, CommercialAvail, localTitle.Id);
        clientAvail1.Price_Tier_Text__c = '';
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = TestUtil.initClientAvail(acctGoogle.Id, CommercialAvail, localTitle.Id);
        clientAvail2.Price_Tier_Text__c = '';
        clientAvailList.add(clientAvail2);
        insert clientAvailList;
    }
    
    static testMethod void myUnitTest() {
        Test.startTest();
        setUpdata();
        Test.stopTest();
        Client_Avail__c clientAvailInserted = [Select Id, Local_Title__c, Local_Title__r.Price_Code__c from Client_Avail__c limit 1];
        
        localTitle = [Select Id,Price_Code__c from Local_Title__c where Id =: clientAvailInserted.Local_Title__c];
        localTitle.Price_Code__c = 'Direct To Video Catalog';
        update localTitle;
        
        Test.setCurrentPage(Page.WB_Pricing_Lookup);
        //String availIds = localTitle.Id;
        ApexPages.currentPage().getParameters().put('ID', localTitle.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(localTitle);
        WB_Pricing_Lookup_Controller controller = new WB_Pricing_Lookup_Controller(sc);
        controller.selectcon(); 
        controller.getCountry();
        controller.getselectedPrice();
        controller.addCountry();
        controller.addCountryCancel();        
    }    
}