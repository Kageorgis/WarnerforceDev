public with sharing class WB_CAS_ErrorLogger {
    
    public static void logError(ErrorLog errorWrapperInstance) {
        logError(new ErrorLog[]{errorWrapperInstance});
    }
    
    public static void logError(ErrorLog[] errorWrapperInstance) {
       
       insertErrorLogDetails(errorWrapperInstance);
    }
    
   
    private static void insertErrorLogDetails(ErrorLog[] errorWrapperInstance){
       
        List<CAS_Error_Log__c> listErrorLogs = new List<CAS_Error_Log__c>();

        for (ErrorLog errorInstance : errorWrapperInstance) {
            CAS_Error_Log__c logRec = getErrorLogRecord(errorInstance);
            listErrorLogs.add(logRec);
        }

        System.debug('-listErrorLogs-->'+listErrorLogs);
        if (!listErrorLogs.isEmpty()) {
            Database.insert(listErrorLogs,false);
        }
       
    }
    
     private static CAS_Error_Log__c getErrorLogRecord(ErrorLog errLog) {
        CAS_Error_Log__c errLogRec = new CAS_Error_Log__c();
        errLogRec.Record_Id__c = errLog.recordId;
        errLogRec.Error_Category__c = errLog.errorCategory;
        errLogRec.Error_Description__c = errLog.errorDescription;
        errLogRec.Error_Description_Long__c = errLog.errorDescriptionLong;
        errLogRec.Object_Name__c = errLog.objectName;
        errLogRec.Account__c = errLog.account;
        errLogRec.Channel__c = errLog.channel;
        errLogRec.Country__c = errLog.country;
        errLogRec.Format__c = errLog.format;
        errLogRec.Language__c = errLog.language;
        errLogRec.Language_Type__c = errLog.languageType;
        errLogRec.Video_Version__c = errLog.videoVersion;
        errLogRec.PlaylistID__c = errLog.playlistId;
        return errLogRec;
    }
    
    public class ErrorLog {
        public Id recordId;
        public String errorCategory;
        public String errorDescription;
        public String errorDescriptionLong;
        public String objectName;
        public String account;
        public String channel;
        public String country;
        public String format;
        public String language;
        public String languageType;
        public String videoVersion;
        public String playlistId;
        
    }
}