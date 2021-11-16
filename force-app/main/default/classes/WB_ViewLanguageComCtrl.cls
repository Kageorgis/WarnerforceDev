public class WB_ViewLanguageComCtrl {
	@AuraEnabled
	public static string getVideoVersion(Id titleId){
	    String videoVersion = '';
	    if(titleId != null){
	        List<Title__c> titles = [Select Id,Video_Version__c From Title__c Where Id = :titleId];
	        if(titles.size() > 0){
	            videoVersion = titles[0].Video_Version__c;
	        }
	    }
	    return videoVersion; 
    }
}