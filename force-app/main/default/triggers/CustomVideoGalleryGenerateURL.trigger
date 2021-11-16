trigger CustomVideoGalleryGenerateURL on ContentDistribution (after insert, before delete) {
    Profile AdminProfileID,TPXProfileID = new Profile();
    try{
        AdminProfileID = [Select Id From Profile Where Name = 'System Administrator' ];
        TPXProfileID = [Select Id From Profile Where Name = 'TPX - Standard User' ];
    }catch(Exception e){
    }
    
    if(trigger.isInsert && AdminProfileID.Id != null && TPXProfileID.Id != null && ( userinfo.getProfileId() == AdminProfileID.ID || userinfo.getProfileId() == TPXProfileID.ID )){
        List<Custom_Content__c> listUrls = new List<Custom_Content__c>();
        for(ContentDistribution cd : Trigger.new){
            ContentDistribution ContentDFile = [select Name,ContentDocumentId,ContentDownloadUrl from ContentDistribution where ID = :cd.ID];
            
            Custom_Content__c ObjectURL = new Custom_Content__c();
            ObjectURL.Name = ContentDFile.Name;
            ObjectURL.ContentDocumentId__c = ContentDFile.ContentDocumentId;
            ObjectURL.Download_Url__c = ContentDFile.ContentDownloadUrl;
            
            listUrls.add(ObjectURL);
            
        }
        
        if(listUrls.size() > 0){
            insert listUrls;
        }
    }
    
    if( trigger.isDelete && AdminProfileID.Id != null && TPXProfileID.Id != null && ( userinfo.getProfileId() == AdminProfileID.ID || userinfo.getProfileId() == TPXProfileID.ID ) ){
        
        List<string> ids = new List<string>();
        
        for( ContentDistribution cd : trigger.old ){
            ids.add(cd.ID);
        }
        List<ContentDistribution> ContentDFile = [select ContentDocumentId from ContentDistribution where ID IN :ids];
        ids.clear();
        
        for(ContentDistribution cd2: ContentDFile){
            ids.add(cd2.ContentDocumentId);
        }
        
        if(ids.size() > 0){
            List<Custom_Content__c> deleteList = [SELECT ID FROM Custom_Content__c WHERE ContentDocumentId__c IN :ids ];
            if(deleteList.size() > 0){
                delete deleteList;
            }
        } 
    }
}