public with sharing class CRM_TopicsListController {
    @AuraEnabled(cacheable=true)
    public static List<Topic> getTopicList(String searchText) {
        searchText = (String.isNotBlank(searchText) && searchText.trim().length() > 1) ? '%'+searchText.trim()+'%' : '%';
        //system.debug('searchText-->'+searchText);
        return [SELECT Id, Name 
            FROM Topic
            WHERE  Name like : searchText
            ORDER BY Name];
        
    }
}