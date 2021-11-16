/* 
   * Author: cognizant Team
   * Description: This trigger is used to call methods of Handlers 
   * Date Created:  14 mar 2016
   * Version: 0.1 
   */
trigger CRM_Deal on Opportunity (before Insert,after insert,after update,after delete,before update, before delete) {
    Id posRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Physical_POS_Deal').getRecordTypeId();
    Id dfiRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Physical_DFI_Deal').getRecordTypeId();
    Id ITVPRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ITVP_Formats_Opportunities').getRecordTypeId();
    Id TradeSpendRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Spend').getRecordTypeId();// added as a part of ER007120

  //  Id planningRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Physical_Planning_Deal').getRecordTypeId();
    
    Set<Id> accountIdSet = new Set<Id>();
    Set<Id> pricebookIdSet = new Set<Id>();
    Set<Id> posdfiDealRecordTypeSet = new Set<Id>{posRecordTypeID, dfiRecordTypeID};
    
    Integer ITVP_RecordSize=0;//ER-007020 Bypass Trigger for ITVP deals 
        List <opportunity> lstITVP = new list<opportunity>();
        if(!(trigger.new == null)){
            lstITVP.addAll(trigger.new);
        }
        else{
            lstITVP.addALL(trigger.old);
        }
        for (Opportunity deal : lstITVP) {
            //ER-007020 Bypass Trigger for ITVP deals 
            if(deal.RecordTypeId == ITVPRecordTypeID){
                ITVP_RecordSize+=1;
            }
        }
        //ER-007020 Bypass Trigger for ITVP deals 
        if(lstITVP.size() == ITVP_RecordSize){
            return;
        }
        //ER-007020 Bypass Trigger for ITVP deals End
    
    if (CRM_ApplicationUtility.runningUser != null && CRM_ApplicationUtility.runningUser.size() > 0 && CRM_ApplicationUtility.runningUser[0].ByPassValidationRule__c){
        System.debug('#@#@#@# Bypassing the trigger.');
        return;
    }

    CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_Deal');       
    if ( (objCustomSettingTriggerSwitch != null && !objCustomSettingTriggerSwitch.IsActive__c)  ) 
        return;

    // Bypass deal trigger invocation for Trade Spend Record Type Deals ER007120
    if (!Trigger.isDelete) {
        Integer allRecordSize = trigger.new.size();
        Integer tradeSpendRecordSize = 0;
        Integer posandDfirecordsize = 0;
        Set<Id> accountsForposDfiDeals = new Set<ID>(); //Added as a part of US #W-017615
        //Set<Id> oppIdSet = new Set<Id>();

        for (Opportunity deal : trigger.new) {

            
            if(deal.RecordTypeId == TradeSpendRecordTypeID) {
                if(Trigger.isBefore && Trigger.isInsert) {
                    if (deal.StageName == null || deal.StageName == '') {
                        deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
                    }
                }
                tradeSpendRecordSize++;
            }
            if(posdfiDealRecordTypeSet.contains(deal.RecordTypeId)){
                accountIdSet.add(deal.AccountId);
                pricebookIdSet.add(deal.Pricebook2Id);
                posandDfirecordsize ++;
                
                //Added as a part of US #W-017615 - start
                if(Trigger.isAfter && Trigger.isUpdate) {
                    if(Trigger.oldMap != null && deal.StageName != Trigger.oldMap.get(deal.ID).StageName && 
                       deal.StageName != null &&
                      (deal.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_US_CODE ) || 
                      (deal.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE )) {
                          accountsForposDfiDeals.add(deal.AccountId);
                    }
                } //Added as a part of US #W-017615 - end
            }
      
        }

        //Added as a part of US #W-017615 - start
        if(!accountsForposDfiDeals.isEmpty()) {
            CRM_DealHandler.checkScheduleRevenueChangedFlagOnAccount(accountsForposDfiDeals);
        } //Added as a part of US #W-017615 - end
        
        if(!accountIdSet.isEmpty() && Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            CRM_DealHandler handler = new CRM_DealHandler();
            handler.beforeInsertUpdatePhysicalPOSDFIDeal(accountIdSet, pricebookIdSet, Trigger.new);
        }
        
        if (allRecordSize == tradeSpendRecordSize) {
            CRM_ApplicationUtility.byPassDealTrigger = true;
        }
        if (allRecordSize == posandDfirecordsize) {
            system.debug('CRM_Deal Trigger -> posandDfirecordsize = ' +posandDfirecordsize);
            return;
        }
    }

    if (CRM_ApplicationUtility.byPassDealTrigger) {
        if(Trigger.isBefore && Trigger.isInsert) {
            CRM_DealHandler handler = new CRM_DealHandler();
            handler.updateDealFromAccount(trigger.new);
        }
        if(Trigger.isAfter && Trigger.isUpdate) {
            CRM_DealHandler handler = new CRM_DealHandler();
            handler.addChatterPostUSGames(Trigger.oldMap,Trigger.newMap);
        }
        return;
    }
        
    if(Trigger.isBefore && Trigger.isInsert) {
        for (Opportunity deal : trigger.new) {
            if (String.isNotBlank(deal.Deal_Code__c)) {
                CRM_ApplicationUtility.mapClonedDealsIdToInstance.put(deal.Deal_Code__c, deal);
            }
        }
        CRM_DealSequenceController.executeBeforeInsert(trigger.new); 
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
        //US#490- logic to update the product group on deal. 
        //      if(ApexUtil.isTriggerInvoked == false) {
            // Create a Set from Opportunity Ids to Opportunity Line Items.
        Set<Id> setOpportunityId = new Set<Id>();
        
        for(Opportunity oOpportunity : Trigger.new){
            if((oOpportunity.StageName=='Confirmed' || oOpportunity.StageName=='Verbal') && oOpportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DC) {
                setOpportunityId.add(oOpportunity.Id);
            }
        }
        
        if(setOpportunityId.size()>0) {
            CheckQuantitySaleDigitalProducts checkQuantity = new CheckQuantitySaleDigitalProducts();
            Map<Id, Opportunity> mapOpportunityError = checkQuantity.CheckOpportunity(Trigger.newMap, Trigger.oldMap, setOpportunityId);
            
            for(Opportunity oOpportunity : Trigger.new){
                if(mapOpportunityError.containsKey(oOpportunity.Id)) oOpportunity.addError('Insufficient stock of products.');
            }
        }
        //       ApexUtil.isTriggerInvoked = true;
        //     }
        CRM_DealSequenceController.executeBeforeUpdate(trigger.oldmap,trigger.newmap);
    }

    if(Trigger.isBefore && Trigger.isDelete) {
         CRM_DealSequenceController.executeBeforeDelete(trigger.oldmap);
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        if (
            CRM_ApplicationUtility.mapClonedDealsIdToInstance != null &&
            CRM_ApplicationUtility.mapClonedDealsIdToInstance.size() > 0 &&
            CRM_ApplicationUtility.mapClonedDealsIdToInstance.keySet() != null
        ) {
            List<Opportunity> existingDeals = [SELECT Id, Deal_Code__c FROM Opportunity WHERE Deal_Code__c IN:  CRM_ApplicationUtility.mapClonedDealsIdToInstance.keySet()];
            
            for (Opportunity deal : existingDeals) {
                if (CRM_ApplicationUtility.mapClonedDealsIdToInstance.containsKey(deal.Deal_Code__c)) {
                    Opportunity opp = CRM_ApplicationUtility.mapClonedDealsIdToInstance.get(deal.Deal_Code__c);
                    CRM_ApplicationUtility.clonedDealIds.add(opp.Id);
                }
            }
            System.debug('--CRM_ApplicationUtility.clonedDealIds-->'+CRM_ApplicationUtility.clonedDealIds);
        }
        
        CRM_DealSequenceController.executeAfterInsert(trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        CRM_DealSequenceController.executeAfterUpdate(trigger.oldmap,trigger.newmap);
    }
    
    if(Trigger.isAfter && Trigger.isDelete) {
    }
}