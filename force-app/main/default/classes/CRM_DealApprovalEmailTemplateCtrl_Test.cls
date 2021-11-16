/**
	@Author Cognizant
	@name CRM_DealApprovalEmailTemplateCtrl_Test
	@CreateDate 10 April 2018
	@Description Test class for CRM_DealApprovalEmailTemplateCtrl
	@Version <1.0>
*/
@isTest
public class CRM_DealApprovalEmailTemplateCtrl_Test {

	static list<Opportunity> digitalOpps;
	static list<Opportunity> opps;
	
	static void allTheDataForThisTestClass() {
		CRM_Default_Configuration__c objCS = new CRM_Default_Configuration__c(Deal_Product_Limit_in_Email_Templates__c = 100);
		insert objCS;
		
		// create Storefront Account 
		List<Account> lstAcc = CRM_TestDataFactory.createAccounts(1, false);
		lstAcc[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
		// lstAcc[0].Digital_Country_Code__c = '772';
		// lstAcc[0].Sales_Organization__c = '6008';
		insert lstAcc;
		System.assertEquals(1, lstAcc.size());

		//create country
		List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
		//create storefronts
		list<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(lstAcc, 'USD', countries[0].id,true);
		
		list<Account> accounts = CRM_TestDataFactory.createAccounts(2, true);
		//update accounts
		accounts[0].Video_Digital__c  = true;
		accounts[0].Games_Digital__c  = true;
		accounts[0].Video_Physical__c = false;
		accounts[0].Games_Physical__c = false;
		accounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
		accounts[0].Storefront__c = storefronts[0].id;
		update accounts;
		
		List<Account> digitalAccount = new List<Account>();
		List<Account> physicalAccount = new List<Account>();
		
		digitalAccount.add(accounts[0]);
		physicalAccount.add(accounts[1]);
		
		//update opps with recordtypes
		opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(physicalAccount,1, true);
		Id digitalRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
		
		digitalOpps = CRM_TestDataFactory.createOpportunitiesWithAccounts(digitalAccount,1, false);
		digitalOpps[0].recordTypeId = digitalRecordTypeId;
		digitalOpps[0].Account = accounts[0];
		insert digitalOpps;
		
		system.assertEquals(1,opps.size());
		system.assertEquals(1,digitalOpps.size());
		
		List<String> strRegion = new List<String>();    
		strRegion.add('FR');
		strRegion.add('UK');
		
		//create country
		List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1,false);
		lstCountries[0].Country_Code2__c = 'FR';
		lstCountries[1].Country_Code2__c = 'UK';
		insert lstCountries;
		
		List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(2, false);
		lstLang[0].Language_Code_2__c = 'en';
		lstLang[1].Language_Code_2__c = 'fr';
		insert lstLang;
		
		//create local data
		List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
		lstLocalData[0].Language__c = lstLang[0].Id;
		lstLocalData[1].Language__c = lstLang[1].Id;
		insert lstLocalData;
		system.assertEquals(2,[select count() from Local_Title__c]);
			
		//create products and associate with Opportunities
		List<Product_Group__c> digitalPG = CRM_TestDataFactory.createProductGroups(1, true);
		List<Product2> digitalProducts = CRM_TestDataFactory.createProducts(digitalPG, 2, false);
		digitalProducts[0].External_Id__c= 'USA_en_12345_EST_HD';
		digitalProducts[1].External_Id__c='USA_fr_12345_EST_HD';
		digitalProducts[0].Product_Market__c='EST';
		digitalProducts[1].Product_Market__c='VODi';
		digitalProducts[0].Local_Title__c = lstLocalData[0].Id;
		digitalProducts[1].Local_Title__c = lstLocalData[1].Id;
		digitalProducts[0].Type__c= CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE;
		digitalProducts[1].Type__c=CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
		digitalProducts[0].recordtypeId= CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
		digitalProducts[1].recordtypeId=CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
		insert digitalProducts;
			
		List<Product2> physicalProducts = CRM_TestDataFactory.createProducts(digitalPG, 2, false);
		physicalProducts[0].productCode= 'code1';
		physicalProducts[1].productCode='code2';
		physicalProducts[0].External_Id__c= 'USA_gr_12345_EST_HD';
		physicalProducts[0].Universal_Picture_Code__c ='upc1';
		physicalProducts[1].Universal_Picture_Code__c='upc2';
		physicalProducts[0].Product_Market__c='EST';
		physicalProducts[1].Product_Market__c='VODi';
		physicalProducts[0].Local_Title__c = lstLocalData[0].Id;
		physicalProducts[1].Local_Title__c = lstLocalData[1].Id;
		physicalProducts[0].Type__c= CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE;
		physicalProducts[1].Type__c=CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
		physicalProducts[0].recordtypeId= CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
		physicalProducts[1].recordtypeId=CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
		insert physicalProducts;
			
		List<PricebookEntry> pbEntriesDigital = CRM_TestDataFactory.createPriceBookEntries(digitalProducts, 1, true);
		List<PricebookEntry> pbEntriesPhysical = CRM_TestDataFactory.createPriceBookEntries(physicalProducts, 1, true);
		
		List<Pricing__c> lstPricing = CRM_TestDataFactory.createPricings(1,false);
		lstPricing[0].Price_Tier__c = '20';
		insert lstPricing;
			
		List<Pricebook_Entry_Period__c> digitalPEB =CRM_TestDataFactory.createPriceBookEntryPeriods(digitalProducts, 1, false);
		for(Pricebook_Entry_Period__c pbep : digitalPEB){
			pbep.Pricing__c = lstPricing[0].Id;
		}
		digitalPEB[1].Retailer_Product_ID__c = 'RPID1234';
			
		List<Pricebook_Entry_Period__c> physicalPEB=CRM_TestDataFactory.createPriceBookEntryPeriods(physicalProducts, 1, false);
		for(Pricebook_Entry_Period__c pbep : physicalPEB){
			pbep.Pricing__c = lstPricing[0].Id;
		}
		physicalPEB.addAll(digitalPEB);
		insert physicalPEB;
			
		List<OpportunityLineItem> dealproductsD = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntriesDigital, new list<Opportunity>{digitalOpps[0]}, 1, false);
		List<OpportunityLineItem> dealproductsP = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntriesPhysical, new list<Opportunity>{opps[0]}, 1, false);
		dealproductsP.addAll(dealproductsD);
		for(OpportunityLineItem ol: dealproductsP) {
			ol.UnitPrice = 10;
			ol.Promoted_Price__c=15;
			ol.Price_is_Minimum__c  = true;
		}
		insert dealproductsP;
		system.assertEquals(2,dealproductsP.size());
	}
	
	static testMethod void test_DealApprovalEmailTemplateCtrl() {
		allTheDataForThisTestClass();
		Opportunity deal = new Opportunity(Id = opps[0].Id);
		CRM_DealApprovalEmailTemplateCtrl objCtrlUK = new CRM_DealApprovalEmailTemplateCtrl();
		objCtrlUK.deal = deal;
		objCtrlUK.getDealProducts();
		
		CRM_DealApprovalEmailTemplateCtrl_BE objCtrlBE = new CRM_DealApprovalEmailTemplateCtrl_BE();
		objCtrlBE.deal = deal;
		objCtrlBE.getDealProducts();
		objCtrlBE.getDealRec();
		
		CRM_DealApprovalEmailTemplateCtrl_JP objCtrlJP = new CRM_DealApprovalEmailTemplateCtrl_JP();
		objCtrlJP.deal = deal;
		objCtrlJP.getDealProducts();
		
		CRM_DealApprovalEmailTemplateCtrl_IT_ES objCtrlITES = new CRM_DealApprovalEmailTemplateCtrl_IT_ES();
		objCtrlITES.deal = deal;
		objCtrlITES.getDealProducts();
		objCtrlITES.getDealRec();
		
		CRM_DealApprovalEmailTemplateCtrl_USCAN objCtrlUSCAN = new CRM_DealApprovalEmailTemplateCtrl_USCAN();
		objCtrlUSCAN.deal = deal;
		objCtrlUSCAN.getDealProducts();
		objCtrlUSCAN.getDealRec();
		
		CRM_DealApprovalEmailTemplateCtrlUSGames objCtrlUSGames = new CRM_DealApprovalEmailTemplateCtrlUSGames();
		objCtrlUSGames.deal = deal;
		objCtrlUSGames.getDealProducts();
	}
}