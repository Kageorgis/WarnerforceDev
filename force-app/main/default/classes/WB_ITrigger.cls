/*
Class Name : WB_Itrigger
Description  : Interface with all triggering events described.                
Created By   : Cognizant Technology Solutions - Shekhar Vinayak
Created On   : 10th Aug 2015

Change History:
------------------------------------------------------------------------------------------------------
Sr#  Description                     Updated By                                     Updated On
------------------------------------------------------------------------------------------------------
1    [Change Type]     Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

*/

/**
 * Interface containing methods Trigger Handlers must implement to enforce best practice
 * and bulkification of triggers.
 */
public interface WB_ITrigger
{
     /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    void bulkBefore();
     
    /**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
  void bulkAfter();
     
    /**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
    void beforeInsert(SObject so);
     
    /**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     */
    void beforeUpdate(SObject oldSo, SObject so);
 
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */

    void beforeDelete(SObject so);
 
    /**
     * afterInsert
     *
     * This method is called iteratively for each record inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point.
     */
    void afterInsert(SObject so);
 
    /**
     * afterUpdate
     *
     * This method is called iteratively for each record updated during an AFTER
     * trigger.
     */
  void afterUpdate(SObject oldSo, SObject so);
 
    /**
     * afterDelete
     *
     * This method is called iteratively for each record deleted during an AFTER
     * trigger.
     */
   void afterDelete(SObject so);
   
    /**
     * checkReportTemplatefields
     *
     * This method is called iteratively for each record while insertion during an BEFORE
     * trigger.
     */
   //Boolean checkReportTemplatefields(Id newSoId,String reportId);
    
   void checkOptionalFieldsInReport(Announcement_Rule__c annType);
  // void checkOptionalFieldsInReport(String annTypeId,String reportTemplate);
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    void andFinally();
}