@isTest(seeAllData=false)
public class WB_ComponentTitle_Search_Controller_Test
{
    
    public static UtilityClass_Test  utilClass = new UtilityClass_Test();    
    
    public static testmethod void noCollectionTitle()
    {

        Title__c titleFeature = (Title__c)utilClass.createTestRecord(utilClass.setUpData(new Title__c (),0));
        
        List<Title__C> titles = [Select id,content_type__c,Video_Version__c from Title__c];
        
        titles[0].Name ='My Feature Title';
        titles[0].content_type__c='Feature';
        titles[0].Video_Version__c ='6000047546';
        
        update titles;
        
        Test.starttest();
        PageReference pageRef = Page.WB_ComponentTitle_Search;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('Id', titleFeature.id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(titles);
        WB_ComponentTitle_Search_Controller controller = new WB_ComponentTitle_Search_Controller(sc);
        controller.cancel();
        test.stoptest();
    }

    public static testmethod void collectionTitleFeatures()
    {

        Title__c titleCollection = (Title__c)utilClass.createTestRecord(utilClass.setUpData(new Title__c (),0));
        Title__c titleFeature = (Title__c)utilClass.createTestRecord(utilClass.setUpData(new Title__c (),0));
        
        List<Title__C> titlesCollection = [Select id,content_type__c,Video_Version__c from Title__c where Id = :titleCollection.Id LIMIT 1];
        
        titlesCollection[0].Name ='My Collection Features Title';
        titlesCollection[0].content_type__c=Label.Collection_Features;
        titlesCollection[0].Video_Version__c ='6000047545';
        titlesCollection[0].Status__c = 'Active';
        titlesCollection[0].Clear_to_Avail__c = true;
        titlesCollection[0].Digital_Planning__c = 'Yes'; 
        titlesCollection[0].Formats__c='SD';
        
        update titlesCollection;

        List<Title__C> titlesFeature = [Select id,content_type__c,Video_Version__c from Title__c where Id = :titleFeature.Id LIMIT 1];        
        
        titlesFeature[0].Name ='My Feature Title';
        titlesFeature[0].content_type__c='Feature';
        titlesFeature[0].Video_Version__c ='6000047546';
        titlesFeature[0].Status__c = 'Active';
        titlesFeature[0].Clear_to_Avail__c = true;
        titlesFeature[0].Digital_Planning__c = 'Yes';
		titlesFeature[0].Formats__c='SD';        
        
        update titlesFeature;
        
        Test.starttest();
        PageReference pageRef = Page.WB_ComponentTitle_Search;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('ID', titlesCollection[0].id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(titlesCollection);
        WB_ComponentTitle_Search_Controller controller = new WB_ComponentTitle_Search_Controller(sc);
        
        //search by video version
        controller.searchByVideoVersion = titlesFeature[0].Video_Version__c;
        controller.searchByTitleName = '';
        controller.search();
        controller.selectAll = true;
        controller.SelectAllTitles();
        controller.save();
        controller.reset();

        //search by Title Name
        controller.searchByVideoVersion = '';
        controller.searchByTitleName = 'My Feature Title';
        controller.search();
        controller.selectAll = true;
        controller.SelectAllTitles();
        controller.save();
        controller.reset();
        
        //deallocate existing titles
        controller.saveExisting();
        controller.selectAllExisting = true;
        controller.SelectAllTitlesExisting();
        controller.saveExisting();
        
        
        test.stoptest();
    }


    public static testmethod void collectionTitleTV()
    {

        Title__c titleCollection = (Title__c)utilClass.createTestRecord(utilClass.setUpData(new Title__c (),0));
        Title__c titleFeature = (Title__c)utilClass.createTestRecord(utilClass.setUpData(new Title__c (),0));
        
        List<Title__C> titlesCollection = [Select id,content_type__c,Video_Version__c from Title__c where Id = :titleCollection.Id LIMIT 1];
        
        titlesCollection[0].Name ='My Bundle TV Title';
        titlesCollection[0].content_type__c=Label.Collection_TV;
        titlesCollection[0].Video_Version__c ='6000047545';
        titlesCollection[0].Status__c = 'Active';
        titlesCollection[0].Clear_to_Avail__c = true;
        titlesCollection[0].Digital_Planning__c = 'Yes';    
        titlesCollection[0].Formats__c ='SD';
        
        update titlesCollection;

        List<Title__C> titlesFeature = [Select id,content_type__c,Video_Version__c from Title__c where Id = :titleFeature.Id LIMIT 1];        
        
        titlesFeature[0].Name ='My Season Title';
        titlesFeature[0].content_type__c='Season';
        titlesFeature[0].Video_Version__c ='6000047546';
        titlesFeature[0].Status__c = 'Active';
        titlesFeature[0].Clear_to_Avail__c = true;
        titlesFeature[0].Digital_Planning__c = 'Yes';    
        titlesFeature[0].Formats__c='SD';
        
        update titlesFeature;
        
        Test.starttest();
        PageReference pageRef = Page.WB_ComponentTitle_Search;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('ID', titlesCollection[0].id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(titlesCollection);
        WB_ComponentTitle_Search_Controller controller = new WB_ComponentTitle_Search_Controller(sc);
        
        //search by video version
        controller.searchByVideoVersion = titlesFeature[0].Video_Version__c;
        controller.searchByTitleName = '';
        controller.search();
        controller.selectAll = true;
        controller.SelectAllTitles();
        controller.save();
        controller.reset();

        //search by Title Name
        controller.searchByVideoVersion = '';
        controller.searchByTitleName = 'My Season Title';
        controller.search();
        controller.selectAll = true;
        controller.SelectAllTitles();
        controller.save();
        controller.reset();
        
        //deallocate existing titles
        controller.saveExisting();
        controller.selectAllExisting = true;
        controller.SelectAllTitlesExisting();
        controller.saveExisting();
        
        
        test.stoptest();
    }
    
}