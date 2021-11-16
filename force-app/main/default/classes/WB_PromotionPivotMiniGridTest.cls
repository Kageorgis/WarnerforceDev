/*******************************************************************************************************************************************
* File Name     :   WB_PromotionPivotMiniGridTest
* Description   :   Test class for WB_PromotionPivotMiniGrid class
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     28 Apr.2016        CTS                ER-000390 - II : Created the class.
********************************************************************************************************************************************/

@isTest
public class WB_PromotionPivotMiniGridTest {
    static testmethod void testPromoCountries()
    {
        
    }
    /*
    public static Account objAccount;
    public static Country__c objCountry;
    public static Agreement__c objStorefront;
    public static Account_Role__c accRole;
    public static Promotion__c objPromotion;
    public static Country_Groups__c objCG;
    public static List<String> StrFields;
    
    static void setUpdata() {
        
        StrFields = new List<String> { 'Account__c' ,'Channels__c' , 'Country__c', 'Currency__c' };
        
        objAccount = TestUtil.initAccount();
        insert objAccount;
        
        accRole =  new Account_Role__c(Account__c = objAccount.Id, User__c = Userinfo.getUserId(), Role__c = 'Promoter');
        insert accRole; 
        
        List<User> userDetail = [SELECT Id, ProfileId, Profile.Name, Territory__c from User where Id =: Userinfo.getUserId()];
        objCountry = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        objCountry.Territory__c = userDetail[0].Territory__c;
        insert objCountry;
        
        objCG = new Country_Groups__c(Name='Test Group', Country__c=objCountry.Name);
        insert objCG;
        
        objStorefront = new Agreement__c(Account__c = objAccount.Id, Country__c = objCountry.Id, status__c = 'Active', Pricing_Currency__c ='AUD');
        insert objStorefront;
        
        objPromotion = new Promotion__c(Name = 'Test Promotion'
                                            , Account__c = objAccount.Id
                                            , Start_Date__c = system.today()-5
                                            , End_Date__c = system.today()+5
                                            , Channels__c = 'EST;VOD'
                                            , Formats__c = 'SD;HD'
                                            , Currency__c = 'AUD - Australian Dollar'
                                            , Country_Group__c = objCG.Id);
        insert objPromotion;
    }
    
    private static testMethod void PositiveTest() {
        
        setUpdata();
        
        ApexPages.currentPage().getParameters().put('Id', objPromotion.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(objPromotion);
        WB_PromotionPivotMiniGrid controller = new WB_PromotionPivotMiniGrid(sc);
        
        Test.startTest();
        WB_PromotionPivotMiniGrid.getIdsByCriteria(objPromotion.Id, StrFields, 2);
        system.assertEquals(objPromotion.Id!=null,true);
        Test.stopTest();
    }
    
    private static testMethod void ChannelFormatNullTest() {
        
        setUpdata();
        
        objPromotion.Channels__c = null;
        objPromotion.Formats__c = null;
        update objPromotion;
        
        ApexPages.currentPage().getParameters().put('Id', objPromotion.Id);
        Test.startTest();
        WB_PromotionPivotMiniGrid.getIdsByCriteria(objPromotion.Id, StrFields, 2);
        system.assertEquals(objPromotion.Id!=null,true);

        Test.stopTest();
    }
    
    private static testMethod void PromotionIdNullTest() {
        
        setUpdata();
        ApexPages.currentPage().getParameters().put('Id', null);
        ApexPages.StandardController sc = new ApexPages.StandardController(objPromotion);
        WB_PromotionPivotMiniGrid controller = new WB_PromotionPivotMiniGrid(sc);
        
        Test.startTest();
        WB_PromotionPivotMiniGrid.getIdsByCriteria(null, StrFields, 2);
        Test.stopTest();
    }
*/
}