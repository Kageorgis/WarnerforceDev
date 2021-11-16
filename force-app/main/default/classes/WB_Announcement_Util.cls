public class WB_Announcement_Util {
    
    public static Integer CSV_LIMIT = 30000; //default value
    public static Integer XLS_LIMIT = 100000;//default value
    
    public static Integer LIMIT_FILE_SIZE = 18769510; //default value,17.9 MB
    
    static{
    	try{
    		WB_Pricing_Settings__c  announcementFileSetting = WB_Pricing_Settings__c.getInstance('Announcement File Limit');
    		if(announcementFileSetting != null){
	    		XLS_LIMIT = Integer.valueOf(announcementFileSetting.XLS_Limit__c);
	    		CSV_LIMIT = Integer.valueOf(announcementFileSetting.CSV_Limit__c);
	    		LIMIT_FILE_SIZE = Integer.valueOf(announcementFileSetting.File_Size__c);
    		}
    	}catch(Exception ex){
    		System.debug(ex.getMessage());
    	}
    	
    } 
    
}