public class RF_ReleaseforceTriggerHandler implements RF_TriggerInterface{
    
    public void BeforeInsert(List<SObject> newRecordsList) {
        //  RF_ReleaseHelper.updateMpmReleaseDate(Trigger.New);  
        
        
        RF_ReleaseHelper.syncCountryInsert(newRecordsList); // W-017708
        RF_ReleaseHelper.setSourceFrmRcrdType(newRecordsList);
        RF_ReleaseHelper.setDefaultDateOnInsert(newRecordsList);
        //RF_ReleaseHelper.setMPMFromExt(Trigger.New);
        
        RF_ReleaseHelper.defautlDistributorFromStudio(Trigger.New);
        RF_ReleaseHelper.defaultlablecode(Trigger.New);
        RF_ReleaseHelper.insertprimaryBackupcontemail(newRecordsList);
        
        
        //RF_ReleaseHelper.changeRecordTypePageLayoutForSDS(Trigger.New);
        //ReleaseDefaultDateHandler.setDefaultDatesOnCreate(Trigger.New);
        //RF_ReleaseHelper.setDefaultDateOnInsertApprovecatalog(newRecordsList);
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { 
        Map<id,release__c> relConMap = new Map<id,release__c>();
        Try{
            system.debug('newItems contains: '+newItems);   
            // system.debug('recursion: '+checkRecursion.hasAlreadyRun());  
            /*if(newItems!=null && !newItems.IsEmpty()){
                RF_ReleaseHelper.setDefaultDates(newItems,oldItems); 
            }*/
            Id profileId = userinfo.getProfileId();
        	Id userId = userInfo.getUserId();
            if(RF_ReleaseHelper.checkSDSUser(userId, profileId)){
                for(Id releaseId : newItems.keySet()){
                    Release__c newRelease = (Release__c)newItems.get(releaseId);
                    Release__c oldRelease = (Release__c)oldItems.get(releaseId);
                    if(newRelease.Source__c != LABEL.RF_SDS && newRelease.Record_Type_Name__c != LABEL.RF_SDS){
                        if(RF_ReleaseHelper.editedThoseFiveFields(newRelease,oldRelease)){
                            newRelease.addError(LABEL.RF_PREVENT_SDS_USER); 
                        }
                    }
                    else{
                        continue;
                    }
                }
            }
            
            RF_ReleaseHelper.syncCountryUpdate(newItems,oldItems);    // W-017708 ++
            
            RF_ReleaseHelper.setDefaultDates(newItems,oldItems); //
            
            RF_ReleaseHelper.setIntegrationStatus(newItems,oldItems);
            
            RF_ReleaseHelper.setIntegrationStatus2(newItems,oldItems);
            
            RF_ReleaseHelper.defautlDistributorFromStudio(Trigger.New);
            
            RF_ReleaseHelper.defaultlablecode(Trigger.New);   
            
            RF_ReleaseHelper.defaultprimaryBackupcontemail(newItems, oldItems);
            
            //RF_ReleaseHelper.preventSDSUser(Trigger.newMap, Trigger.oldMap);
            
            RF_ReleaseHelper.updatePVOD_PEST_BasedOnCountry(newItems, oldItems);
            //RF_ReleaseHelper.PreventTheatricalDate(trigger.new,trigger.old);
            
            //RF_ReleaseHelper.updatePrimaryContactOnUpdate(newItems);
            
            
            
        }Catch(System.Exception ex){
            system.debug('ex IS: '+ex);
            //RF_ExceptionLogHandler.createExceptionLog(ex ,'RF_ReleaseTriggerHandler');
            
        }
    }
    //  public void BeforeDelete(List<sObject> oldRecordsList , Map<Id, SObject> oldItems) {}
    
    public void AfterInsert(List<sObject> newRecordsList , Map<Id, SObject> newItems) {
        
        Try{
            //RF_ReleaseHelper
            system.debug('After insert1');
            //RF_ReleaseHelper.insertExtTitleName(newRecordsList);
            system.debug('After insert1');
            //RF_ReleaseHelper.updatePrimaryContactOnInsert(newRecordsList);
            system.debug('After insert2');
            //RF_ReleaseHelper.assigningOwnerBasedOnDigitalOwner(newRecordsList);
            
            RF_ReleaseHelper.updateParentOnInsert(newRecordsList);
            RF_ReleaseHelper.updateParentOnInsertNew(newRecordsList);
            // RF_ReleaseHelper.setSourceFrmRcrdType(newRecordsList);
            //RF_ReleaseHelper.changeRecordTypePageLayoutForSDS(Trigger.New);
            
            
        }Catch(System.Exception ex){
            
            //RF_ExceptionLogHandler.createExceptionLog(ex ,'RF_ReleaseTriggerHandler');
            
        }
        
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<id,release__c> relConMap = new Map<id,release__c>();
        Try{
            //RF_ReleaseHelper.
            system.debug('after update trigger method newItems: '+newItems);
            RF_ReleaseHelper.updateParentRecord(newItems,oldItems);
            RF_ReleaseHelperTVsetDate.updateChildMRPMaterials(newItems,oldItems);  // W-017691:  DCHO
            //RF_ReleaseHelper.changeRecordTypePageLayoutForSDS(Trigger.New);
            //RF_ReleaseHelper.insertExtTitleName(Trigger.Old);
            // RF_ReleaseHelper.updateParentRecordNew(newItems,oldItems);
            
        }Catch(System.Exception ex){
            
            // RF_ExceptionLogHandler.createExceptionLog(ex ,'RF_ReleaseTriggerHandler');
            
        }
    }
    public void BeforeDelete(List<sObject> oldRecordsList , Map<Id, sObject> oldRecordsMap){}
    
    
}