@isTest(seeAlldata=false)
public with sharing class CRM_CloneAccountSplitTemplateCntr_Test {
    /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None 
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static Target_Split_Template__c ast;
   
    static void createTestData() {
      List<Account_Split__c> lstAS = new List<Account_Split__c>();
	  List<Account> lstAcc = new List<Account>();
      ast = new Target_Split_Template__c();
        ast.Name = 'Test AST';
        ast.CurrencyIsoCode = 'EUR';
        insert ast;
		
		for(Integer i=0; i<2; i++){
			Account acc = new Account();
			acc.Name = 'Test - Account ' + i;
			acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
			lstAcc.add(acc);
		}
		insert lstAcc;
        
        for(integer i=0 ; i<2 ; i++){
            Account_Split__c asp = new Account_Split__c();
            asp.Target_Split_Template__c = ast.id;
            asp.Account__c = lstAcc[i].id;
            asp.Share__c = 50;
			asp.CurrencyIsoCode = 'EUR';
            lstAS.add(asp);
        }
        insert lstAS;
    }
     /**
    *  Test 1: Clone AST
    *  @name cloneASTTest
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void cloneASTTest(){
      User u = [Select Id from User where Profile.Name = 'CRM - Local Admin - FR' and isActive = true Limit 1];
        System.runAs(u) {        
            createTestData();
            system.assertEquals(1,[Select Count() From Target_Split_Template__c]);
            system.assertEquals(2,[Select Count() From Account_Split__c]);
      
          Test.setCurrentPageReference(new PageReference('Page.CRM_CloneAccountSplitTemplate'));
          ApexPages.StandardController sc = new ApexPages.StandardController(ast);
          CRM_CloneAccountSplitTemplateController ctrl = new CRM_CloneAccountSplitTemplateController(sc);
          
          Id astId = CRM_CloneAccountSplitTemplateController.cloneAccountSplitTemplate(ast.Id,ast.Name,ast.CurrencyIsoCode);
          List<Id> lstASIds = new List<Id>();
          for(Account_Split__c asi : [Select Id From Account_Split__c]){ 
            lstASIds.add(asi.Id);
          }
          List<CRM_CloneAccountSplitTemplateController.ASLSaveError> errorLst = new List<CRM_CloneAccountSplitTemplateController.ASLSaveError>();
          errorLst = CRM_CloneAccountSplitTemplateController.cloneAccountSplits(astId,lstASIds);
          System.debug('errorLst' + errorLst);
          system.assertEquals(2,[Select Count() From Target_Split_Template__c]);
          system.assertEquals(4,[Select Count() From Account_Split__c]);
      }

    }
}