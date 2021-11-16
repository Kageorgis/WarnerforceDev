/** 
* Author: cognizant Team
* Description: This trigger is used to call methods from Handllers to udpate Deal Product and Deal
* Date Created:  05 Dec 2015
* Version: 0.4   
*/
trigger CRM_DealProduct on OpportunityLineItem (before Insert,after insert,after update,after delete,before update, before delete) {
    
    //List<User> runningUser = [SELECT ByPassValidationRule__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
    if (CRM_ApplicationUtility.runningUser != null && CRM_ApplicationUtility.runningUser.size() > 0 && CRM_ApplicationUtility.runningUser[0].ByPassValidationRule__c){
        System.debug('#@#@#@# Bypassing the trigger.');
        return;
    }
    
    CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_DealProduct');       
    if ( (objCustomSettingTriggerSwitch != null && !objCustomSettingTriggerSwitch.IsActive__c)  ) 
        return;
    
    // Bypass deal product trigger invocation for Trade Spend Record Type Deals
    if (!Trigger.isDelete) {
        Integer allRecordSize = trigger.new.size();
        Integer tradeSpendRecordSize = 0;
        for (OpportunityLineItem lineItem : trigger.new) {
            if(lineItem.Deal_Record_Type__c == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_TRADE_SPEND_DEAL) {
                tradeSpendRecordSize++;
            }
        }
        if (allRecordSize == tradeSpendRecordSize) {
            return;
        }
    }
    
    if((!Trigger.isBefore && !Trigger.isInsert) && (!Trigger.isBefore && !Trigger.isUpdate) && !Trigger.isDelete) { 
        Integer allRecordSize = trigger.new.size();
        Integer physicalPOSDFIRecordSize= 0;        
        for (OpportunityLineItem lineItem : trigger.new) {
            if(lineItem.Deal_Record_Type__c == 'Physical_POS_Deal' || lineItem.Deal_Record_Type__c == 'Physical_DFI_Deal' ) {
                physicalPOSDFIRecordSize++;
            }
        }
        if (allRecordSize == physicalPOSDFIRecordSize) {
            return;
        }
    }
    
    if((Trigger.isBefore && Trigger.isInsert)||(Trigger.isBefore && Trigger.isUpdate)) { 
        Integer allRecordSize = trigger.new.size();
        Integer physicalPOSDFIRecordSize= 0;        
        for (OpportunityLineItem lineItem : trigger.new) {
            if(lineItem.Deal_Record_Type__c == 'Physical_POS_Deal' || lineItem.Deal_Record_Type__c == 'Physical_DFI_Deal' || lineItem.Deal_Record_Type__c =='Physical_Planning_Deal') {
                physicalPOSDFIRecordSize++;
            }
        }
        if (allRecordSize == physicalPOSDFIRecordSize) {
            if(!ApexUtil.isTriggerInvoked && !(System.isBatch() && (CRM_ApplicationUtility.isDecayCurveReforcastingBatch || CRM_ApplicationUtility.isJVAutoPhysicalNRBatch))){
                //CRMJV-Added Checks for NR Deal
                if(Trigger.isBefore && Trigger.isUpdate && !Trigger.isInsert){
                    for(OpportunityLineItem lineItem : trigger.new) {
                        if (lineItem.Deal_Stage_Name__c==CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT && (lineItem.Deal_Record_Type__c == 'Physical_POS_Deal' || lineItem.Deal_Record_Type__c == 'Physical_DFI_Deal' || lineItem.Deal_Record_Type__c =='Physical_Planning_Deal') &&
                            (lineItem.Deal_Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || lineItem.Deal_Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)){
                                lineItem.addError(System.Label.CRMJV_Msg_NRDefault_Update, false);
                        }
                    }
                }    
                CRM_UploadExtractPOSandDFI.addPBEPforDealProducts(trigger.new);

                //--ER-007676--validate deal product on cancel action--Start--//
                CRM_UploadExtractPOSandDFI.validateDealProductBeforeCancelAndDelete(trigger.new, false);
                //--ER-007676--validate deal product on cancel action--End--//
            }
            return;
        }
    }
    
    //W-017642,W-017679 - Start - Added functionality for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
    if((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate)){
        Integer allRecordSize = trigger.new.size();
        Integer physicalPOSDFIRecordSize= 0;        
        for (OpportunityLineItem lineItem : trigger.new) {
            if((lineItem.Deal_Record_Type__c == 'Physical_POS_Deal' || lineItem.Deal_Record_Type__c == 'Physical_DFI_Deal' || lineItem.Deal_Record_Type__c =='Physical_Planning_Deal') && 
                    (lineItem.Deal_Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || 
                    lineItem.Deal_Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)){
                physicalPOSDFIRecordSize++;
            }
        }
        if (allRecordSize == physicalPOSDFIRecordSize) {
            if(!ApexUtil.isTriggerInvoked && !System.isBatch()){
                boolean isTriggerInsert = Trigger.isInsert ? true : false;                    
                CRM_AutoEstablishSchedulesHelper.executeDealProductScheduling(Trigger.oldMap, Trigger.newMap.values(), isTriggerInsert);
            }
            return;
        }
    }   //W-017642,W-017679 - END - Added functionality for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
    
    if(Trigger.isBefore && Trigger.isDelete) { 
        Integer allRecordSize = trigger.old.size();
        Integer physicalPOSDFIRecordSize= 0;        
        for (OpportunityLineItem lineItem : trigger.old) {
            if(lineItem.Deal_Record_Type__c == 'Physical_POS_Deal' || lineItem.Deal_Record_Type__c == 'Physical_DFI_Deal' || lineItem.Deal_Record_Type__c =='Physical_Planning_Deal') {
                physicalPOSDFIRecordSize++;
            }
        }
        if (allRecordSize == physicalPOSDFIRecordSize) {
            if(!ApexUtil.isTriggerInvoked && !(System.isBatch() && (CRM_ApplicationUtility.isDecayCurveReforcastingBatch || CRM_ApplicationUtility.isJVAutoPhysicalNRBatch))){
                //CRMJV-Added Checks for NR Deal
                for (OpportunityLineItem lineItem : trigger.old) {
                    if (lineItem.Deal_Stage_Name__c==CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT && (lineItem.Deal_Record_Type__c == 'Physical_POS_Deal' || lineItem.Deal_Record_Type__c == 'Physical_DFI_Deal' || lineItem.Deal_Record_Type__c =='Physical_Planning_Deal') &&
                        (lineItem.Deal_Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || lineItem.Deal_Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)){
                            lineItem.addError(System.Label.CRMJV_Msg_NRDefault_Delete, false);
                    }
                }

                //--ER-007325--move validation rule in code for deleting newly added dp from revised deal--Start--//
                CRM_UploadExtractPOSandDFI.validateDealProductBeforeCancelAndDelete(trigger.old, true);
                //--ER-007325--move validation rule in code for deleting newly added dp from revised deal--End--//
            }
            return;
        }
    }
    
    
    if(Trigger.isBefore && Trigger.isInsert) {      
        CRM_DealProductSequenceController.executeBeforeInsert(trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        if(ApexUtil.isTriggerInvoked == false) {
            // Create a Set from Opportunity Ids to Opportunity Line Items. 
            Set<Id> setOpportunityId = new Set<Id>();
            // Create a Set from OpportunityLineItem Ids to Opportunity Line Items. 
            Set<Id> setOpportunityLineItemId = new Set<Id>();
            
            for(OpportunityLineItem oOpportunityLineItem : Trigger.new){
                setOpportunityId.add(oOpportunityLineItem.OpportunityId);
                setOpportunityLineItemId.add(oOpportunityLineItem.Id);
            }
            
            // Create a Map from OpportunityLineItem Ids to Opportunity Line Items with Record Type equals "DC Deals". 
            Map<Id, OpportunityLineItem> newMapOpportunityLineItemDCDeals = new Map<Id, OpportunityLineItem>();
            Map<Id, OpportunityLineItem> OldMapOpportunityLineItemDCDeals = new Map<Id, OpportunityLineItem>();
            // Create a Map from OpportunityLineItem Ids to Opportunity Line Items with Record Type distinct "DC Deals". 
            Map<Id, OpportunityLineItem> newMapOpportunityLineItemNotDCDeals = new Map<Id, OpportunityLineItem>();
            Map<Id, OpportunityLineItem> OldMapOpportunityLineItemNotDCDeals = new Map<Id, OpportunityLineItem>();
            
            for(OpportunityLineItem oOpportunityLineItem : [SELECT Id, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :setOpportunityId AND Opportunity.RecordType.Name<>'DC Deals']) {
                setOpportunityId.remove(oOpportunityLineItem.OpportunityId);
                setOpportunityLineItemId.remove(oOpportunityLineItem.Id);
            }
            for(OpportunityLineItem oOpportunityLineItem : Trigger.new){
                if(setOpportunityLineItemId.contains(oOpportunityLineItem.Id)) {
                    if(Trigger.oldMap.get(oOpportunityLineItem.Id).Impression__c!=oOpportunityLineItem.Impression__c || Trigger.oldMap.get(oOpportunityLineItem.Id).Onsale_Date__c!=oOpportunityLineItem.Onsale_Date__c) {
                        newMapOpportunityLineItemDCDeals.put(oOpportunityLineItem.Id, oOpportunityLineItem);
                        OldMapOpportunityLineItemDCDeals.put(oOpportunityLineItem.Id, oOpportunityLineItem);
                    }
                    else {
                        setOpportunityId.remove(oOpportunityLineItem.OpportunityId);
                        setOpportunityLineItemId.remove(oOpportunityLineItem.Id);
                    }
                }
                else {
                    newMapOpportunityLineItemNotDCDeals.put(trigger.newMap.get(oOpportunityLineItem.Id).Id, trigger.newMap.get(oOpportunityLineItem.Id));
                    OldMapOpportunityLineItemNotDCDeals.put(trigger.oldMap.get(oOpportunityLineItem.Id).Id, trigger.oldMap.get(oOpportunityLineItem.Id));
                }
            }
            if(setOpportunityId.size()>0) {
                CheckQuantitySaleDigitalProducts checkQuantity = new CheckQuantitySaleDigitalProducts();
                Map<Id, OpportunityLineItem> mapOpportunityLineItemError = checkQuantity.CheckOpportunityLineItem(newMapOpportunityLineItemDCDeals, setOpportunityId, setOpportunityLineItemId);
                
                for(OpportunityLineItem oOpportunityLineItem : Trigger.new){
                    if(mapOpportunityLineItemError.containsKey(oOpportunityLineItem.Id)) oOpportunityLineItem.addError('Insufficient stock of products');
                }
            }
            ApexUtil.isTriggerInvoked = true;
        }
        CRM_DealProductSequenceController.executeBeforeUpdate(trigger.oldMap, trigger.newMap);
        //CRM_DealProductSequenceController.executeBeforeUpdate(OldMapOpportunityLineItemNotDCDeals, newMapOpportunityLineItemNotDCDeals);
    }
    
    if(Trigger.isBefore && Trigger.isDelete) {
        //US : 929 : US Games 
        CRM_DealProductSequenceController.executeBeforeDelete(trigger.oldMap);
    }
    
    if(Trigger.isAfter && Trigger.isInsert) {
        DuplicateOpportunityProducts.executeAfterInsert(trigger.new);   
        CRM_DealProductSequenceController.executeAfterInsert(trigger.oldMap, trigger.newMap);
        CRM_TrackDealProductFieldValueChanges.dealProductCreateDeleteAuditEntry(Trigger.new, 'create');
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        DuplicateOpportunityProducts.executeAfterUpdate(trigger.oldMap, trigger.newMap);   
        CRM_DealProductSequenceController.executeAfterUpdate(trigger.oldMap, trigger.newMap);
        CRM_TrackDealProductFieldValueChanges.trackFieldValueChanges(trigger.new, trigger.oldMap);
    }
    
    if(Trigger.isAfter && Trigger.isDelete) {
        CRM_DealProductSequenceController.executeAfterDelete(trigger.oldMap);
        CRM_TrackDealProductFieldValueChanges.dealProductCreateDeleteAuditEntry(Trigger.old, 'delete');
    }
}