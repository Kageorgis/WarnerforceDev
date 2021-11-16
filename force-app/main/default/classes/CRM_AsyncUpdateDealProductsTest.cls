@isTest(seeAllData=false)
private class CRM_AsyncUpdateDealProductsTest {
    static List<Opportunity> lstDeals;
    
    public static void createData() {
        CRM_Default_Configuration__c objCS = new CRM_Default_Configuration__c(Deal_Product_Limit_in_Email_Templates__c = 100);
        insert objCS;
        
        CRM_Batch_Size__c cbs = new CRM_Batch_Size__c();
        cbs.name = 'UpdateRelatedDealProducts_QJob';
        cbs.Batch_Size__c = 4;
        insert cbs;
        
        Double HighLevelForcast = 500;
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false); 
        for (Account acc : lstAccounts) {  
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acc.Sales_Organization__c  = CRM_AppConstants.TERRITORY_UK_CODE;
        }
        insert lstAccounts;
        
        lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1, false);
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            opp.High_Level_Forecast__c = 100;
            //opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        }
        insert lstDeals;
        List<Product_Group__c> lstProductGroup2 = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup2, 200, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.Delivery_Lead_Days__c = 1;
            prodInstance.SAP_Unrestricted_Stock__c = 2;
            prodInstance.SAP_Opened_Sales_Order__c = 1;
            prodInstance.Street_Date__c = System.today() + 50;
        }
        insert lstProduct;
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        
        List<Pricebook_Entry_Period__c> lstPBEP = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.Start_Date__c = System.today() - 100;
            pbep.end_Date__c = System.today() + 400;
        }
        insert lstPBEP;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 5, false);
        for(OpportunityLineItem dealLineItem: lstDealProduct){
            dealLineItem.Initial_Quantity__c = 10;
            dealLineItem.Replen_Quantity__c = 10;
            dealLineItem.UK_Approvers_Cat_FEATURE__c = true;
            dealLineItem.Contribution_is_Minimum__c = true;
            dealLineItem.Price_is_Minimum__c = true;
        }
        insert lstDealProduct;
        system.assertEquals(5, lstDealProduct.size());
        
        insert new CRM_UK_Approval_process_submitter__c(SetupOwnerId=UserInfo.getOrganizationId(), James_Jackson_Id__c='0050B000006q5xz');
    }
    
    
    static testMethod void updateDealStageToCommittedTest(){
        
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d) + 'abc@test.com',
            Email = 'abc@test.com',
            Alias = String.valueOf(d).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id
        );
        insert testUser;
        
            createData();
            
            
        System.runAs(testUser) {
            
            for(Opportunity deal : lstDeals) {
                if(deal != null)
                    Test.startTest();
                    submitDealForApproval(deal);
                     Test.stopTest();
                     CRM_DealHandler.isFirstRun = true; 
                	System.debug('getActualApprover(deal.id)::::'+getActualApprover(deal.id));
                	if(getActualApprover(deal.id)!=null){
                    approveApprovalProcess(getActualApprover(deal.id));
                    CRM_DealHandler.isFirstRun = true; 
                    approveApprovalProcess(getActualApprover(deal.id));
                } 
            }
           
            
        }
        
        
        for(OpportunityLineItem dp : [Select Id,Approved_Qty__c,Initial_Quantity__c From OpportunityLineItem limit 4]){
              //system.assertEquals(dp.Approved_Qty__c,dp.Initial_Quantity__c,'Both Quantity should be same');    
        }
        
        OpportunityLineItem dealProduct = new OpportunityLineItem();
        List<OpportunityLineItem> lstDp = new List<OpportunityLineItem>{dealProduct};
        dealProduct.OpportunityId = null;
        CRM_AsyncUpdateDealProducts con = new CRM_AsyncUpdateDealProducts(lstDp);
        Database.SaveResult[] saveResults = database.update(lstDp, false);
        con.logUpdateErrors(saveResults, lstDp);
    }
    
    static void submitDealForApproval(Opportunity deal){
        PageReference pageRef = Page.CRM_DealApproval;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',deal.id);
        ApexPages.standardController controller = new ApexPages.standardController(deal);
        CRM_DealApproval pg = new CRM_DealApproval(controller); 
        CRM_DataObjects.ProductToEdit[] prds=CRM_DealApproval.getLineItems(deal.id);
        CRM_DealApproval.DealWrapper dw = CRM_DealApproval.getOverlappingDealProducts(deal.id);
        
        
    }
    static Id getActualApprover(Id dealId){
        List<ProcessInstanceWorkitem> approvalProcessStep = new List<ProcessInstanceWorkitem>();
        approvalProcessStep = [SELECT Id,OriginalActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: dealId Limit 1];
        System.debug('approvalProcessStep::::'+approvalProcessStep);
        if(approvalProcessStep.isEmpty())
            return null;
        User user = [Select Id,Name From User Where Id = :approvalProcessStep[0].OriginalActorId];
        return approvalProcessStep[0].Id;
   }
     static void approveApprovalProcess(ID approvalProcessStepId){
        Approval.ProcessWorkitemRequest reqApproval = new Approval.ProcessWorkitemRequest();
        reqApproval.setAction('Approve');
        reqApproval.setWorkitemId(approvalProcessStepId);
        Approval.ProcessResult result =  Approval.process(reqApproval);
       
   }
   
}