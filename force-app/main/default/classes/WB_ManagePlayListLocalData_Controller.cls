public with sharing class WB_ManagePlayListLocalData_Controller { 

    public String ldId;
    public Local_Title__c playlistLD { get; set; }
    public List<Id> contentTitles = new List<Id>();
    public Boolean isError { get; set; }
    public String playlistVV { get; set; }
    public String playlistCountry { get; set; }
    public String playlistLanguage { get; set; }       
    public String playlistName { get; set; }        
    public List<Local_Title__c> contentLocalData { get; set; }
    public Map<Id,Local_Title__c> contentLocalData_Temp;          //ER-1002
    public List<Local_Title__c> contentLDToUpdate { get; set; }
    //ER - 1002
    public String selectedlocalDataSyncGrNm { get; set; }
    public Boolean isLanguageSame;   //checks whether Language is same for all Countries OR all Country and Language are different
    public List<Local_Title__c> finalLocalDataList;
    public Map<Id,Local_Data_sync_Group_Item__c> localTitleSyncGroupMap;
    public List<Id> countryList;
    public List<Id> languageList;
    Public Set<Id> LanguageSet; 
    public Id syncGroupLanguageId; 
    public Id id;
    public WB_ManagePlayListLocalData_Controller(ApexPages.StandardController controller) {
        id = controller.getRecord().Id;
    } 
    /*
    ER-1661
    Updated on - 22 Jan 2018*/
    public PageReference forwardToListController() {
        PageReference pr = Page.WB_ManagePlayListLocalData;
        if(id!= NULL){
            pr.getParameters().put('LocalTitleId', id); //&param=std
          
        }
        return pr;
   }

    public WB_ManagePlayListLocalData_Controller(ApexPages.StandardSetController controller) {
        contentLocalData = new List<Local_Title__c>();
        localTitleSyncGroupMap = new Map<Id,Local_Data_sync_Group_Item__c>();
        contentLocalData_Temp = new Map<Id,Local_Title__c>();
        ldID = System.currentPagereference().getParameters().get('LocalTitleId');
        playlistLD = [SELECT Id, Playlist__c, Playlist__r.Id, Playlist__r.Name, Title__r.Name, Country__r.Id, 
                            Country__r.Name, Language__r.Id, Language__r.Name 
                      FROM Local_Title__c 
                      WHERE Id = :ldID LIMIT 1];
        isError = false;
        playlistVV = playlistLD.Title__r.Name;
        playlistCountry = playlistLD.Country__r.Name;
        playlistLanguage = playlistLD.Language__r.Name;   
        playlistname = playlistLD.Playlist__r.Name;            
        getContentLocalData();

    }
    
    public Pagereference getContentLocalData() {
        selectedlocalDataSyncGrNm = '';
        contentTitles.clear();
        contentLocalData.clear();
        isError = false;
        List<contentLocalDataWrapper> contentList = new List<contentLocalDataWrapper>();
        Map<Id,Integer> seqMap = new Map<Id,Integer>();
        List<Local_Title__c> contentLocalData1 = new List<Local_Title__c>();
        
        for(Playlist_Content__c playlistContent : [SELECT Id, Content_Title__r.Id,Content_Sequence__c 
                                                   FROM Playlist_Content__c 
                                                   WHERE Playlist__c = :playlistLD.Playlist__r.Id]){
            contentTitles.add(playlistContent.Content_Title__r.Id);
            seqMap.put(playlistContent.Content_Title__r.Id,(Integer)playlistContent.Content_Sequence__c);
        }
    
        if(contentTitles.size() > 0) 
            contentLocalData1 = [SELECT Id,Language__c,Country__c, Name, Title__c, TitleF__c, Local_Category__c, Category__c, Title__r.US_TV_Air_Date_Formula__c, 
                                        Title__r.US_TV_Air_Date__c, Local_TV_Air_Date__c, Local_Run_Time__c, Local_Season__c, Local_Episodes__c, Local_Rating__c ,
                                        Language__r.name,Country__r.name, Local_Title__c
                                FROM Local_Title__c where Title__c IN :contentTitles AND Country__c = :playlistLD.country__r.Id 
                                AND Language__c = :playlistLD.Language__r.Id ORDER BY Name];
        for(Local_Title__c lt : contentLocalData1)
            contentList.add(new contentLocalDataWrapper(lt, seqMap.get(lt.Title__c)));
        contentList.sort();
        for(contentLocalDataWrapper cldW : contentList)
            contentLocalData.add(cldW.ld);
        
        /*----ER-1002-----*/
        contentLocalData_Temp.clear();
        contentLocalData_Temp = new Map<Id,Local_Title__c>(contentLocalData.deepClone(true));
        /*----ER-1002-----*/
        
        if(contentTitles.size() != contentLocalData.size())
            isError = true;

        return null;
    
    }
    //ER-1002
    /*Below method checks Language is same/different  for all the countries 
        in selected local Data Sync Group */
    public Boolean isLanguageSameOnSyncGrItems (){
        LanguageSet = new set<Id>();
        countryList = new List<Id>();
        languageList = new List<Id>();
        isLanguageSame = false;
        if(selectedlocalDataSyncGrNm != '' && selectedlocalDataSyncGrNm != NULL) {
            for(Local_Data_sync_Group_Item__c groupItem : [SELECT id,Country__c,Country__r.Name,
                                                            Language__r.Name,Language__c
                                                            FROM Local_Data_sync_Group_Item__c 
                                                           WHERE Local_Data_sync_Group__r.name =: selectedlocalDataSyncGrNm]) {
                                                               
           if(! groupItem.Country__r.Name.equals(playlistCountry)  ||  !groupItem.Language__r.Name.equals(playlistLanguage)) {
                localTitleSyncGroupMap.put(groupItem.Id,groupItem);
                countryList.add(groupItem.Country__c);
                languageList.add(groupItem.Language__c);
           }
        }
             LanguageSet.addAll(languageList);                                                  
        }
        if(LanguageSet.size() == 1 ){
            List<Id> languageId = new List<Id>(LanguageSet);
            syncGroupLanguageId = languageId[0];
            return true; //Languages are same
        }
            
        else{
            return false; //Languages are different
        } 
            
        
    }
    
    public Pagereference updateContentLocalData() {
        List<Database.SaveResult> updateResults;
        List<Local_Title__c> finalLocalDataResult;
        Map<Id, Local_Title__c> localTitleMap = new Map<Id, Local_Title__c>();
        finalLocalDataList = new List<Local_Title__c>();
        contentLDToUpdate = new List<Local_Title__c>();
        
        /*ER-1002
        Added By - CAS Team
        Date -     15 July'17*/
        //Check if Local Titles on page has changed value,then add LT into localTitleMap
        for(Local_Title__c new_LTRec: contentLocalData){
            Local_Title__c old_LTRec = contentLocalData_Temp.get(new_LTRec.Id);
            if(old_LTRec != NULL){
                if(new_LTRec.Id == old_LTRec.Id) {
                    if( (new_LTRec.Name != old_LTRec.Name) 
                    || (new_LTRec.Category__c != old_LTRec.Category__c)
                    || (new_LTRec.Local_TV_Air_Date__c != old_LTRec.Local_TV_Air_Date__c) 
                    || (new_LTRec.Local_Episodes__c != old_LTRec.Local_Episodes__c)
                    || (new_LTRec.Local_Rating__c != old_LTRec.Local_Rating__c) 
                    || (new_LTRec.Local_Title__c != old_LTRec.Local_Title__c)) {   
                        localTitleMap.put(new_LTRec.id,new_LTRec);
                    }
                }
            }
        }
        If(selectedlocalDataSyncGrNm != '' && selectedlocalDataSyncGrNm != NULL){
            isLanguageSame = isLanguageSameOnSyncGrItems();
            List<Local_Title__c> localTitleToUpdateList = [SELECT Name,Category__c,Local_TV_Air_Date__c,
                                                                  Title__c,Country__c,Language__c
                                                           FROM Local_Title__c
                                                           WHERE Title__c IN :contentTitles 
                                                           AND Country__c IN:countryList 
                                                           AND Language__c IN:languageList];
            if(localTitleToUpdateList != NULL && localTitleToUpdateList.size() > 0) {
                for( Local_Title__c contentLocalDataRec : localTitleMap.values()) {
                    for(Local_Title__c localTitleRec : localTitleToUpdateList) {
                        for(Local_Data_sync_Group_Item__c syncItem: localTitleSyncGroupMap.values()) {
                            if(localTitleRec.Title__c == contentLocalDataRec.Title__c &&  localTitleRec.Country__c == syncItem.Country__c
                                && localTitleRec.Language__c == syncItem.Language__c){
                                
                                /*If Languages are same in selected Local Data Sync Group and Seasonal LT 
                                on page then it updates below 4 fields*/
                                system.debug('isLanguageSame****'+isLanguageSame);
                                system.debug('syncGroupLanguageId****'+syncGroupLanguageId);
                                system.debug('playlistLD.Language__c****'+playlistLD.Language__c);
                                if(isLanguageSame && syncGroupLanguageId == playlistLD.Language__c ){
                                    system.debug('inside if****');
                                    localTitleRec.Category__c = contentLocalDataRec.Category__c;
                                    localTitleRec.Local_TV_Air_Date__c = contentLocalDataRec.Local_TV_Air_Date__c;
                                    localTitleRec.Local_Episodes__c = contentLocalDataRec.Local_Episodes__c;
                                   // localTitleRec.Name = contentLocalDataRec.Name;
                                    localTitleRec.Local_Title__c = contentLocalDataRec.Local_Title__c;
                                }
                                /*If Languages are different in selected Local Data Sync Group and Seasonal LT 
                                on page then it updates below 4 fields*/
                                
                                else {
                                   localTitleRec.Category__c = contentLocalDataRec.Category__c;
                                   localTitleRec.Local_TV_Air_Date__c = contentLocalDataRec.Local_TV_Air_Date__c;
                                   localTitleRec.Local_Episodes__c = contentLocalDataRec.Local_Episodes__c;
                                }
                                finalLocalDataList.add(localTitleRec);
                            }
                        }
                    }
                }
            }
        } //End Of main #IF
        
        if(finalLocalDataList != NULL && finalLocalDataList.size() != 0){
            for(Local_Title__c objLDItems: finalLocalDataList){
            if(!localTitleMap.containsKey(objLDItems.Id))   
                localTitleMap.put(objLDItems.Id,objLDItems);
            }   
        }
        
        finalLocalDataResult = localTitleMap.values();
        updateResults = Database.update(finalLocalDataResult, false);
        getContentLocalData();
        return null;
    
    }
        
    // Go back to the Playlist local data
    public Pagereference cancel() {
        PageReference page = new PageReference('/' + ldId );     
        page.setRedirect(true);
        return page;
    }
    
    public class contentLocalDataWrapper implements Comparable{
    
        public Local_Title__c ld;
        public Integer SeqNumber;
    
        // Constructor
        public contentLocalDataWrapper(Local_Title__c ld, Integer SeqNumber) {
            this.ld = ld;
            this.SeqNumber = SeqNumber;
        }
    
        public Integer compareTo(Object compareTo) {
            contentLocalDataWrapper contentLocalDataWrapper = (contentLocalDataWrapper) compareTo;
            if (SeqNumber == contentLocalDataWrapper.SeqNumber) return 0;
            if (SeqNumber > contentLocalDataWrapper.SeqNumber) return 1;
            return -1;        
        }
    }
    
    /*ER-1002
    Added By - CAS Team
    Date -     15 July'17*/
    public List<Local_Data_sync_Group__c> getLocalDataSyncGroup(){
        return [select id,Name from Local_Data_sync_Group__c];
    }

}