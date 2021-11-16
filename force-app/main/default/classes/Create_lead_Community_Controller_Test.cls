@isTest
public class Create_lead_Community_Controller_Test {
    @IsTest static void Create_Lead(){
           
        Test.startTest();
        String data = '{ "Company" : "Company", "LastName" : "LastName", "BrandName" : "BrandName", "Salutation" : "Salutation", "FirstName" : "FirstName", "phone" : "phone", "BrandCategory" : "Automotive", "Email" : "Email@test.com", "Title" : "Title", "Product" : "Product", "TimingofIntegration" : "TimingofIntegration", "Budget" : "Budget", "BrandEssenceDescription" : "BrandEssenceDescription", "ProductDescription" : "ProductDescription", "KeyMessages" : "KeyMessages", "IntegrationExtensionRequests" : "IntegrationExtensionRequests", "DigitalIntegrationOptions" : "DigitalIntegrationOptions", "DigitalMediaElements" : "DigitalMediaElements","importantthings" : "importantthings","DetailsofMarketing" : "DetailsofMarketing","MainKPIs" : "MainKPIs","PriorityElements" : "PriorityElements" }';
        String message = Create_Lead_Community_Controller.create(data);
        data = '{ "Company" : "Company", "LastName" : "LastName", "BrandName" : "BrandName", "Salutation" : "Salutation", "FirstName" : "FirstName", "phone" : "phone", "BrandCategory" : "BrandCategory", "Email" : "Email", "Title" : "Title", "Product" : "Product", "TimingofIntegration" : "TimingofIntegration", "Budget" : "Budget", "BrandEssenceDescription" : "BrandEssenceDescription", "ProductDescription" : "ProductDescription", "KeyMessages" : "KeyMessages", "IntegrationExtensionRequests" : "IntegrationExtensionRequests", "DigitalIntegrationOptions" : "DigitalIntegrationOptions", "DigitalMediaElements" : "DigitalMediaElements","importantthings" : "importantthings","DetailsofMarketing" : "DetailsofMarketing","MainKPIs" : "MainKPIs","PriorityElements" : "PriorityElements" }';
        message = Create_Lead_Community_Controller.create(data);
        Test.stopTest();
        
    }
}