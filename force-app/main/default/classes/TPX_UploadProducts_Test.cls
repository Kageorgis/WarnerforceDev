/******* 
TPX_UploadProducts_Test
Creation Date- 18 April 2016
Description- This class is to do code coverage for TPX_UploadProducts_CC and TPX_UploadProducts_Batch
Author- Martin Mori
*******/

@IsTest
private class TPX_UploadProducts_Test{
	static testMethod void unitTest() {
        //Create PriceBook "ELLEN Price Book"
        Pricebook2 priceBookEllen = new Pricebook2(Name='ELLEN Price Book', isActive=true, Business_Unit__c='1234');
        insert priceBookEllen;
                
        Test.startTest();
        StaticResource csvFile = [select Body from StaticResource where Name = 'TPX_ProductUploadTest'];
        TPX_UploadProducts_CC.binFile = csvFile.Body;
        TPX_UploadProducts_CC uploadProducts = new TPX_UploadProducts_CC();
		uploadProducts.ReadFile();
        Test.stopTest();
    }
}