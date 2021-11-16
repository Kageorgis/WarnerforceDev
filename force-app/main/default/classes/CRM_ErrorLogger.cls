/**
   @Author Cognizant
   @name ErrorLogger
   @CreateDate 18 Jan 2016
   @Description This class is used to track error details
   @Version <1.0>
*/
public with sharing class CRM_ErrorLogger {

    /**
     * @Description - Method to insert error log details into CRM_Error_Log__c object
     * @name logError
     * @param ErrorLog errorWrapperInstance - Error log instance in form of inner class instance
     */
    public static void logError(ErrorLog errorWrapperInstance) {
        logError(new ErrorLog[]{errorWrapperInstance});
    }

    /**
     * @Description - Method to insert error log details into CRM_Error_Log__c object
     * @name logErrorFuture
     * @param ErrorLog errorWrapperInstance - Error log instance in form of inner class instance
     */
    public static void logErrorFuture(ErrorLog errorWrapperInstance) {
        logErrorFuture(new ErrorLog[]{errorWrapperInstance});
    }

    /**
     * @Description - Method to insert error log details into CRM_Error_Log__c object
     * @name logError
     * @param ErrorLog[] errorWrapperInstance - List of error log instances
     */
    public static void logError(ErrorLog[] errorWrapperInstance) {
        logErrorDetails(JSON.serialize(errorWrapperInstance));
    }

    /**
     * @Description - Method to insert error log details into CRM_Error_Log__c object
     * @name logErrorFuture
     * @param ErrorLog[] errorWrapperInstance - List of error log instances
     */
    public static void logErrorFuture(ErrorLog[] errorWrapperInstance) {
        logErrorDetailsFuture(JSON.serialize(errorWrapperInstance));
    }

    /**
     * @Description - Method to insert error log details into CRM_Error_Log__c object
     * @name logErrorFuture
     * @param String errorWrapperDetailsJSONString - JSON String of error log details
     */
    private static void logErrorDetails(String errorWrapperDetailsJSONString){
        System.debug('-errorWrapperDetailsJSONString-->'+errorWrapperDetailsJSONString);
        insertErrorLogDetails(errorWrapperDetailsJSONString);
    }

    /**
     * @Description - Method to insert error log details into CRM_Error_Log__c object
     * @name logErrorDetailsFuture
     * @param String errorWrapperDetailsJSONString - JSON String of error log details
     */
    @future
    private static void logErrorDetailsFuture(String errorWrapperDetailsJSONString){
        System.debug('-errorWrapperDetailsJSONString-->'+errorWrapperDetailsJSONString);
        insertErrorLogDetails(errorWrapperDetailsJSONString);
    }

    /**
     * @Description - Method to insert error log details into CRM_Error_Log__c object
     * @name insertErrorLogDetails
     * @param String errorWrapperDetailsJSONString - JSON String of error log details
     */
    private static void insertErrorLogDetails(String errorWrapperDetailsJSONString){
        System.debug('-errorWrapperDetailsJSONString-->'+errorWrapperDetailsJSONString);
        ErrorLog[] listErrorLogItems =
            (ErrorLog[]) JSON.deserialize(errorWrapperDetailsJSONString, List<ErrorLog>.class);
        List<CRM_Error_Log__c> listErrorLogs = new List<CRM_Error_Log__c>();

        for (ErrorLog errorInstance : listErrorLogItems) {
            CRM_Error_Log__c logRec = getErrorLogRecord(errorInstance);
            listErrorLogs.add(logRec);
        }

        System.debug('-listErrorLogs-->'+listErrorLogs);
        if (!listErrorLogs.isEmpty()) {
            insert listErrorLogs;
        }
    }

    /**
     * @Description - Method to create an instance of CRM_Error_Log__c object
     * @name getErrorLogRecord
     * @param ErrorLog errLog - Error log instance in form of inner class instance
     * @return CRM_Error_Log__c Return an instance of CRM_Error_Log__c object with all the error details
     */
    private static CRM_Error_Log__c getErrorLogRecord(ErrorLog errLog) {
        CRM_Error_Log__c errLogRec = new CRM_Error_Log__c();
        errLogRec.Error_Record_Id__c = errLog.recordId;
        errLogRec.Functional_Module__c = errLog.functionalModule;
        errLogRec.Line_Number__c = errLog.lineNumber;
        errLogRec.Message__c = errLog.errorMessage;
        errLogRec.Stack_Trace__c = errLog.stackTrace;
        return errLogRec;
    }

    /**
     * @Description - Inner Class for storing  error log details
     * @name ErrorLog
     */
    public class ErrorLog {
        public Id recordId;
        public String functionalModule;
        public String lineNumber;
        public String errorMessage;
        public String stackTrace;
        public String className;
    }
}