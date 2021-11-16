public with sharing class WB_ComponentTitle_Search_Controller {

    public List<titleWrapper> titles {get;set;}  
    public String searchByVideoVersion {get;set;}  
    public String searchByTitleName {get;set;}      
    public Boolean titlesReturned {get;set;}
    public Boolean selectAll{get; set;}
    public Title__c collectionTitle {get;set;}
    public String titleid{get;set;}
    public List<Title__c> lstTitles = new List<Title__c>();
    public List<titleWrapper> resultRecordsWrapped = new List<titleWrapper>();
    
    public List<titleWrapper> titlesExisting {get;set;}  
    public Boolean titlesReturnedExisting {get;set;}
    public Boolean selectAllExisting{get; set;}
    public List<Title__c> lstTitlesExisting = new List<Title__c>();
    public List<titleWrapper> resultRecordsWrappedExisting = new List<titleWrapper>();
    
    /*public WB_ComponentTitle_Search_Controller(ApexPages.StandardController controller) {  
    } */
    
    public WB_ComponentTitle_Search_Controller(ApexPages.StandardSetController controller) {
        titleid = ApexPages.currentPage().getParameters().get('ID');      
        collectionTitle = [SELECT id,name,Content_Type__c FROM Title__c WHERE id = :titleid];
        if(collectionTitle.Content_Type__c != Label.Collection_Features && collectionTitle.Content_Type__c != Label.Collection_TV){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, collectionTitle.Name+' is not a Digital Collection Title.'));  
        }            
        fetchExistingTitles();        
    } 
    
    public void search(){  
        String searchQuery = '';
        titlesReturned = false;
        if(searchByVideoVersion != '' && searchByTitleName  == '' && searchByVideoVersion.length() >= 3){
            if(collectionTitle.Content_Type__c == Label.Collection_Features)
                searchQuery = 'SELECT Id,Name,Content_Type__c,Video_Version__c,MPM__c,Clear_to_Avail__c FROM Title__c WHERE Video_Version__c like \'%'+searchByVideoVersion+'%\' AND (Not Content_Type__c like \'%Collection%\') AND (Content_Type__c = \'Feature\') AND collection_Title__c != :titleid AND Status__c = \'Active\' AND Clear_to_Avail__c = TRUE AND Digital_Planning__c = \'Yes\' ';  
            else
                searchQuery = 'SELECT Id,Name,Content_Type__c,Video_Version__c,MPM__c,Clear_to_Avail__c FROM Title__c WHERE Video_Version__c like \'%'+searchByVideoVersion+'%\' AND (Not Content_Type__c like \'%Collection%\') AND (Content_Type__c = \'Season\' OR Content_Type__c = \'Episode\') AND collection_Title__c != :titleid AND Status__c = \'Active\' AND Clear_to_Avail__c = TRUE AND Digital_Planning__c = \'Yes\' ';  
        }
        else if(searchByVideoVersion == '' && searchByTitleName  != '' && searchbyTitleName.length() >= 3){   
            if(collectionTitle.Content_Type__c == Label.Collection_Features)
                searchQuery = 'SELECT Id,Name,Content_Type__c,Video_Version__c,MPM__c,Clear_to_Avail__c FROM Title__c WHERE Name like \'%'+searchByTitleName+'%\'  AND (Not Content_Type__c like \'%Collection%\') AND (Content_Type__c = \'Feature\') AND collection_Title__c != :titleid AND Status__c = \'Active\' AND Clear_to_Avail__c = TRUE AND Digital_Planning__c = \'Yes\' ';       
            else
                searchQuery = 'SELECT Id,Name,Content_Type__c,Video_Version__c,MPM__c,Clear_to_Avail__c FROM Title__c WHERE Name like \'%'+searchByTitleName+'%\'  AND (Not Content_Type__c like \'%Collection%\') AND (Content_Type__c = \'Season\' OR Content_Type__c = \'Episode\') AND collection_Title__c != :titleid AND Status__c = \'Active\' AND Clear_to_Avail__c = TRUE AND Digital_Planning__c = \'Yes\' ';           
        }        
        if(searchQuery != ''){
            lstTitles = Database.query(searchquery);  
            if(lstTitles.size() != 0) {
                titlesReturned = true;
                assignSearchResultsToWrapper();
            }
            else
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Titles not found for your search criteria OR titles with that criteria have already been linked to Digital Collection.'));  
        }
        
    }  
    
    private void assignSearchResultsToWrapper(){
        resultRecordsWrapped.clear();
        for(Title__c ttl : lstTitles)
            resultRecordsWrapped.add(new titleWrapper(ttl));
        titles = resultRecordsWrapped;
    }
    
    private void assignSearchResultsToWrapperExisting(){
        resultRecordsWrappedExisting.clear();
        for(Title__c ttl : lstTitlesExisting)
            resultRecordsWrappedExisting.add(new titleWrapper(ttl));
        titlesExisting = resultRecordsWrappedExisting;
    }
    
    private void fetchExistingTitles(){
        titlesReturnedExisting = false;
        String searchQueryExisting = 'SELECT Id,Name,Content_Type__c,Video_Version__c,MPM__c,Clear_to_Avail__c FROM Title__c WHERE Collection_Title__c = :titleid  ';  
        if(searchQueryExisting != ''){
            lstTitlesExisting = Database.query(searchqueryExisting);  
            if(lstTitlesExisting.size() != 0) titlesReturnedExisting = true;
            assignSearchResultsToWrapperExisting();
        }
    }
    
    public pageReference reset(){  
        searchByVideoVersion = '';
        searchByTitleName = '';
        if(titles.size() != 0) titles.clear();
        if(lstTitles.size() != 0) lstTitles.clear();
        if(resultRecordsWrapped.size() != 0) resultRecordsWrapped.clear();  
        search();
        PageReference pageRef = new PageReference(Apexpages.currentPage().getUrl());
        return pageRef; 
    }  
    
    public pageReference cancel(){                          
        pageReference pageRef= new pageReference('/'+titleid);                        
        return pageRef;                    
    }

    public PageReference save(){
        PageReference pRef = new PageReference('/'+titleid);
        pRef.setRedirect(true);

        List<Title__c> titlesToUpdate = new List<Title__c>();
        for(titleWrapper ttl2 : titles){
            if(ttl2.Selected){
                Title__c titleUpd = ttl2.title;
                titleUpd.Collection_Title__c = titleId;
                titlesToUpdate.add(titleUpd);
            }
        }  
        system.debug('titlesToUpdate...'+titlesToUpdate+titlesToUpdate.size());
        if(titlesToUpdate.size() == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select at least one title to link to Digital Collection Title.'));  
            return null; 
        }
        else {
            try{
                update titlesToUpdate;
                selectAllExisting = false;
                //search();
                fetchExistingTitles();
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Selected component title(s) have been linked to Digital Collection Title.'));  
                return null;
            }
            catch(Exception e){
                ApexPages.addMessages(e);
            }
        }
        return pRef;
    }
    
    public PageReference saveExisting(){
        PageReference pRef = new PageReference('/'+titleid);
        pRef.setRedirect(true);

        List<Title__c> titlesToUpdateExisting = new List<Title__c>();
        for(titleWrapper ttl2 : titlesExisting){
            if(ttl2.Selected){
                Title__c titleUpdExt = ttl2.title;
                titleUpdExt.Collection_Title__c = null;
                titlesToUpdateExisting.add(titleUpdExt);
            }
        }  
        if(titlesToUpdateExisting.size() == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select at least one title to remove from Digital Collection Title.'));  
            return null; 
        }
        else {
            try{
                update titlesToUpdateExisting;
                selectAll = false;
                //search();
                fetchExistingTitles();
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Selected component title(s) have been removed from Digital Collection Title.'));  
                return null;
            }
            catch(Exception e){
                ApexPages.addMessages(e);
            }
        }
        return pRef;
    }

    public void SelectAllTitles(){
        for(titleWrapper ttl1: resultRecordsWrapped){
            ttl1.selected=selectAll;
        }
    }

    public void SelectAllTitlesExisting(){
        for(titleWrapper ttl1: resultRecordsWrappedExisting){
            ttl1.selected=selectAllExisting;
        }
    }
    
    public class titleWrapper{
        public Title__c title {get; set;}
        public Boolean selected {get; set;}
        public titleWrapper(){
        }
        public titleWrapper(Title__c t){
            title = t;
            selected = false;
        }
    }

}