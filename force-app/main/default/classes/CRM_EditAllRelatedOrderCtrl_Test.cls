/**
   @Author Cognizant
   @name CRM_EditAllRelatedOrderCtrl_Test
   @CreateDate 21 Oct 2016
   @Description Test class for CRM_EditAllRelatedOrderCtrl
   @Version <1.0>
   @reference Requirement no 476(JAPAN)
  */

@isTest(seeAlldata=false)
public with sharing class CRM_EditAllRelatedOrderCtrl_Test {
    /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None 
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static Order multiOrder;
    static void createTestData() {
        List<Account> lstParentAccounts = CRM_TestDataFactory.createAccounts(1, false);
        lstParentAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        lstParentAccounts[0].RecordTypeId  = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        insert lstParentAccounts;
        
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts[0].RecordTypeId  = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        lstAccounts[0].Sold_to_Customer__c = lstParentAccounts[0].Id;
        insert lstAccounts;
        
        CRM_Max_Product_Limit__c cs = new CRM_Max_Product_Limit__c();
        cs.Name = 'Edit_Orders';
        cs.Count__c = 10;
        insert cs;
        List<Order> lstMultiOrder = CRM_TestDataFactory.createOrders(lstParentAccounts,1,false);   
        List<Order> lstOrder = CRM_TestDataFactory.createOrders(lstParentAccounts,5,false);   
        
        lstMultiOrder[0].RecordTypeId = CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER;
        lstMultiOrder[0].CurrencyIsoCode = 'JPY';
        insert lstMultiOrder[0];
        multiOrder = lstMultiOrder[0];
        
        
        for(integer i=0 ; i < lstOrder.size() ; i++){
            lstOrder[i].RecordTypeId = CRM_RecordTypeUtil.RT_ORDER_STANDARD;
            lstOrder[i].Multi_Order__c = multiOrder.Id;
            lstOrder[i].Ship_To_Account__c = lstAccounts[0].id;
            lstOrder[i].CurrencyIsoCode = 'JPY';
        }
        insert lstOrder;
        
        System.assertEquals(1,[Select count() From Order Where RecordTypeId =: CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER],'One Parent Multi Order');
        System.assertEquals(5,[Select count() From Order Where Multi_Order__c =: multiOrder.Id],'Five Child Order');
        
    }
    
     /**
    *  Test 1: Get All Child Order and Update 
    *  @name relatedOrderTest
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void relatedOrderTest(){
        createTestData();
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditAllRelatedOrders'));
            ApexPages.StandardController sc = new ApexPages.StandardController(multiOrder);
            CRM_EditAllRelatedOrdersCtrl ctrl = new CRM_EditAllRelatedOrdersCtrl(sc);
            
            String localUser = ctrl.getUserLocale();
            String dateFormat = ctrl.getUserDateFormat();
            Integer recordLimit = ctrl.getMaxRelatedOrderLimit();
            system.assertEquals(10,recordLimit);
            
            //get related Orders
            CRM_EditAllRelatedOrdersCtrl.RelatedOrderToEdit[] lstRelatedOrders = CRM_EditAllRelatedOrdersCtrl.getRelatedOrders(multiOrder.Id);
            system.assertEquals(5,lstRelatedOrders.size());
            
            //Update Values
            for(integer i=0 ; i < lstRelatedOrders.size() ; i++){
                lstRelatedOrders[i].PoNumber = 'TestPONumber';
                lstRelatedOrders[i].Comments = 'TestComments';
                lstRelatedOrders[i].requestedDeliveryDate = system.today();
                lstRelatedOrders[i].isDelete = false;
            }
            
            //Save Orders
            CRM_EditAllRelatedOrdersCtrl.saveRelatedOrders(multiOrder.Id,lstRelatedOrders,false);    
            
            //Assert updated valuees
            for(Order childOrder : [Select Id,Customer_PO_Number__c,Comments__c From Order Where Multi_Order__c =: multiOrder.Id]){
                system.assertEquals(childOrder.Customer_PO_Number__c,('TestPONumber'),'Updated PO Number');
                system.assertEquals(childOrder.Comments__c,('TestComments'),'Updated Comments');
                
            }
            
            //Select Orders to delete 
            for(integer i=0 ; i < lstRelatedOrders.size() ; i++){
                lstRelatedOrders[i].isDelete = true;
            }
            
            //Get child orders after delete operation 
            CRM_EditAllRelatedOrdersCtrl.RelatedOrderToEdit[] newLstRelatedOrdes = CRM_EditAllRelatedOrdersCtrl.saveRelatedOrders(multiOrder.Id,lstRelatedOrders,true); 
            //Assert child orders 
            system.assertEquals([Select Count() From Order Where Multi_Order__c =: multiOrder.Id],0,'All Child Orders are deleted');
        }
    }
}