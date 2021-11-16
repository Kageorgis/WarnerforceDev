/**
   @Author Cognizant
   @name CRM_CloneDecayCurveTemplateCtrl_Test
   @CreateDate 21 Oct 2016
   @Description Test class for CRM_CloneDecayCurveTemplateController
   @Version <1.0>
   @reference Defect#3895 (JAPAN)
  */

@isTest(seeAlldata=false)
public with sharing class CRM_CloneDecayCurveTemplateCtrl_Test {
    /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None 
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static Decay_Curve_Template__c dct;
    static void createTestData() {
    	List<Decay_Curve_Item__c> lstDCI = new List<Decay_Curve_Item__c>();
    	dct = new Decay_Curve_Template__c();
        dct.Name = 'Test DCT';
        dct.CurrencyIsoCode = 'JPY';
        dct.Version_Number__c = 0;
        dct.Status__c = CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_DRAFT;
        insert dct;
        
        for(integer i=0 ; i<2 ; i++){
            Decay_Curve_Item__c dci = new Decay_Curve_Item__c();
            dci.Name  = 'Test - '+i;
            dci.Percent_Allocation__c = 50;
            dci.Day_Number__c = 1;
            dci.Decay_Curve_Template__c = dct.ID;
            lstDCI.add(dci);
        }
        insert lstDCI;
    }
     /**
    *  Test 1: Clone DCT
    *  @name cloneDCTTest
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void cloneDCTTest(){
    	createTestData();
    	system.assertEquals(1,[Select Count() From Decay_Curve_Template__c]);
    	system.assertEquals(2,[Select Count() From Decay_Curve_Item__c]);
    	
    	User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u) {
        	Test.setCurrentPageReference(new PageReference('Page.CRM_CloneDecayCurveTeplate'));
	        ApexPages.StandardController sc = new ApexPages.StandardController(dct);
	        CRM_CloneDecayCurveTemplateController ctrl = new CRM_CloneDecayCurveTemplateController(sc);
	        
	        Id dctId = CRM_CloneDecayCurveTemplateController.cloneDecayCurveTemplate(dct.Id,dct.Name,dct.CurrencyIsoCode);
	        List<Id> lstDCIIds = new List<Id>();
	        for(Decay_Curve_Item__c dci : [Select Id From Decay_Curve_Item__c]){ 
	        	lstDCIIds.add(dci.Id);
	        }
	        CRM_CloneDecayCurveTemplateController.cloneDecayCurveItems(dctId,lstDCIIds);
	        system.assertEquals(2,[Select Count() From Decay_Curve_Template__c]);
    		system.assertEquals(4,[Select Count() From Decay_Curve_Item__c]);
    	}
    }
}