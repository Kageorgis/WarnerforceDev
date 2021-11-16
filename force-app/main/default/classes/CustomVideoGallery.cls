public class CustomVideoGallery {
	@AuraEnabled
    public static Map<String,String> getVideo(List<String> videoIds){
        List<Custom_Content__c> ListContent  =  [select ContentDocumentId__c,Download_Url__c from Custom_Content__c where contentDocumentId__c IN :videoIds];
        
        Map<String,String> urls = new Map<String,String>();
        for(Integer i = 0; i < ListContent.size(); i++){
            urls.put(ListContent[i].ContentDocumentId__c,ListContent[i].Download_Url__c);
        }

        return urls;
    }
}