@isTest
public class WB_TVSalesHistoryTriggerHandlerTest {
        
        
      
        
	public static testMethod void postiveTest() {
        WB_Queue_Id__c wbQueueCS = new WB_Queue_Id__c();
        wbQueueCS.Name = 'USA_Q';
        wbQueueCS.Value__c = '00GU0000001fPSB';
        insert wbQueueCS;
        
        country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        //country__c con1= new country__c(Name='Test1',Country_Code__c='Test1',Country_Code2__c = 'Test1',Digital_Owner__c='GermanyQ');
       // insert con1;
        
        test.starttest();
        TV_Sales_History__c tvSalesRecord = new TV_Sales_History__c(Country__c = con.id);
        insert tvSalesRecord;
        
       
        test.stoptest();
	}
	
/*	public static testMethod void negativeTest() {
	    test.starttest();
    	 TV_Sales_History__c tvSalesRecord = new TV_Sales_History__c(Country__c = con.id);
    	 tvSalesRecord.Country__c = '';
         update tvSalesRecord;
        test.stoptest();
	}  */ 

}