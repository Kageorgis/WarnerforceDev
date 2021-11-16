/*===============================================================================================================
* @author Ajit Singh
* @date 22/09/2020
* @description: Trigger handler class for CAR which implements all the trigger events like insert,update,delete
==================================================================================================================*/
public class CAR_CARTriggerHandler implements RF_TriggerInterface{
    
    public void BeforeInsert(List<Car__c> newItems) {
        SYSTEM.debug('File Updated 1');
        if(Trigger.isExecuting){
            system.debug('Is executing from BeforeInsert trigger context->'+Trigger.isExecuting);
            SYSTEM.debug('File Updated 2');
            
            CAR_CARHelper.restrictCARCreation(newItems);
            CAR_CARHelper.getRequestorGroup(newItems);
            CAR_CARHelper.insertCarFieldsFromRel(newItems);
            CAR_CARHelper.InsertSDSContactEmails(newItems);
            
        }else{
            system.debug('Is executing from trigger context:'+Trigger.isExecuting);
            SYSTEM.debug('File Updated 3');
            
            CAR_CARHelper.restrictCARCreation(newItems);
            CAR_CARHelper.getRequestorGroup(newItems);
            CAR_CARHelper.insertCarFieldsFromRel(newItems);
            CAR_CARHelper.InsertSDSContactEmails(newItems);
        }
        
        
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { 
        Try{
            system.debug('CAR_CARTriggerHandler-inside BeforeUpdate');
            SYSTEM.debug('File Updated 4');
            
            if(Trigger.isExecuting){
                SYSTEM.debug('File Updated 5');
                
                system.debug('Is executing from BeforeUpdate trigger context->'+Trigger.isExecuting);
                CAR_CARHelper.updateIntegrationStatePickMeUp(newItems,oldItems);
                //CAR_CARHelper.postTOChatter(newItems,oldItems); //POC - @Kalash
                CAR_CARHelper.validateStatus(newItems,oldItems);
                CAR_CARHelper.UpdateCarFields(newItems,oldItems);
                CAR_CARHelper.UpdateRFStudioFields(newItems,oldItems);
                CAR_CARHelper.updateFieldHistoryTracker(newItems,oldItems);
                system.debug('before validateAccountForArtTrack');
                CAR_CARHelper.validateAccountForArtTrack(newItems,oldItems);
                system.debug('after validateAccountForArtTrack');
                
                
            }else{
                SYSTEM.debug('File Updated 6');
                
                system.debug('Is executing from BeforeUpdate trigger context:'+Trigger.isExecuting);
                CAR_CARHelper.updateIntegrationStatePickMeUp(newItems,oldItems);
                //CAR_CARHelper.postTOChatter(newItems,oldItems); //POC - @Kalash
                System.debug('1');
                CAR_CARHelper.validateStatus(newItems,oldItems);
                System.debug('2');
                CAR_CARHelper.UpdateCarFields(newItems,oldItems);
                System.debug('3');
                CAR_CARHelper.UpdateRFStudioFields(newItems,oldItems);
                System.debug('4');
                CAR_CARHelper.updateFieldHistoryTracker(newItems,oldItems); 
                System.debug('5');
                CAR_CARHelper.validateAccountForArtTrack(newItems,oldItems);
                
            }
            
            
        }Catch(System.Exception ex){
            
            // RF_ExceptionLogHandler.createExceptionLog(ex ,'CAR_CARTriggerHandler');
            
        }
    }
    
    public void BeforeDelete(List<sObject> oldRecordsList , Map<Id, SObject> oldItems) {
        System.debug('Inside BeforeDelete method');
        SYSTEM.debug('File Updated 7');
        
        CAR_CARHelper.preventDeletionOfnonDraftCars(oldItems);
    }
    
    public void AfterInsert(List<sObject> newRecordsList , Map<Id, SObject> newItems) {
        Try{
            SYSTEM.debug('File Updated 8');
            
            system.debug('CAR_CARTriggerHandler-inside AfterInsert');
            
            
        }Catch(System.Exception ex){
            
            //    RF_ExceptionLogHandler.createExceptionLog(ex ,'CAR_CARTriggerHandler');
            
        }
        
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Try{
            system.debug('CAR_CARTriggerHandler- inside After Update');
            SYSTEM.debug('File Updated 9');
            
            
        }Catch(System.Exception ex){
            
            //  RF_ExceptionLogHandler.createExceptionLog(ex ,'CAR_CARTriggerHandler');
            
        }
    }
    
    // public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    // public void AfterUndelete(List<sObject> newRecordsList , Map<Id, sObject> newItems) {}
    
}