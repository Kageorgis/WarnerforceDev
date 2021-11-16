@isTest
public class WB_MultiselectPage_ControllerTest{

    private static testmethod void availableCombinationTest(){
        
        Account accRec = new Account();
        accRec.Name = 'Amazon';
        insert accRec;
        
        MPM__c mpm = new MPM__c();
        mpm.Name = 'Test MPM';
        mpm.MPM_Number__c = '11223';
        insert mpm;
        
        Title__c title = new Title__c();
        title.Name = 'The Vampire diaries';
        title.Video_Version__c ='1243355672';
        title.Content_Type__c='Feature';
        title.Digital_Planning__c='Yes';
        title.Clear_to_Avail__c = true;
        title.MPM__c = mpm.Id;
        title.Formats__c = 'SD';
        insert title;
        
        Language__c language = new Language__c(Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        insert language;
        
        Country__c country = new Country__c(Name ='France',Country_Code2__c ='AA',Country_Code__c='TC');
        insert country;
        
        Local_Title__c localTitle = new Local_Title__c();
        localTitle.Country__c = country.Id;
        localTitle.Language__c = language.Id;
        localTitle.Category__c='Catalog';
        localTitle.Title__c=title.id;
        insert localTitle;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title.id,Language__c=language.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        Commercial_Avail__c  releasePlan = new Commercial_Avail__c();
        releasePlan.Title__c= title.Id;
        releasePlan.Country_Lookup__c = country.Id;
        releasePlan.Local_Title__c = localTitle.Id;
        releasePlan.Languages__c = language.Id ;
        releasePlan.Channel__c='EST';
        releasePlan.Format__c='SD';
        releasePlan.Language_Type__c='Sub';
        releasePlan.Status__c='Tentative';
        releasePlan.Exclusive_Date__c = date.today()-1;
        releasePlan.Start_Date__c = date.today()-1;
        releasePlan.End_Date__c = date.today()+1;
        releasePlan.Rights_End__c = date.today()+2;
        insert releasePlan;
        
        Agreement__c agreement = new Agreement__c();
        agreement.Account__c = accRec.Id;
        agreement.Country__c = country.Id;
        agreement.Pricing_Currency__c = 'FR';
        agreement.Content_Type__c = 'Season; Feature; Episode';
        agreement.Channel_Picklist__c = 'EST; Hotel';
        agreement.Format__c = 'SD';
        agreement.Status__c = 'Active';
        agreement.SAP_Customer_Number__c='12010421';
        insert agreement;
        
        PageReference pageRef = Page.WB_MultiselectPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(agreement.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(agreement);
        WB_MultiselectPage_Controller testsf = new WB_MultiselectPage_Controller(sc);
       
        testsf.updateStoreFrontRec();
       
        agreement.Content_Type__c = 'Collection TV; Season; Feature; Episode';
        agreement.Channel_Picklist__c = 'EST; Hotel; VODi';
        agreement.Format__c = 'SD; HD';
        agreement.Selected_Combination__c ='Collection TV_EST_HD , Collection TV_EST_SD , Feature_EST_SD , Season_EST_SD , Collection TV_Hotel_HD , Collection TV_VODi_HD';
        update agreement;
        
        agreement.Content_Type__c = 'Collection TV; Feature; Episode';
        agreement.Channel_Picklist__c = 'EST; VODi';
        agreement.Format__c = 'HD';
        update agreement;
        
        PageReference pageRef1 = Page.WB_MultiselectPage;
        Test.setCurrentPage(pageRef1);
        pageRef1.getParameters().put('Id', String.valueOf(agreement.Id));
        ApexPages.StandardController sc1 = new ApexPages.StandardController(agreement);
        WB_MultiselectPage_Controller testsf1 = new WB_MultiselectPage_Controller(sc1);
        
        agreement.Channel_Picklist__c = 'EST';
        update agreement;
        
        agreement.Content_Type__c = 'Feature; Episode';
        update agreement;
      
    }
}