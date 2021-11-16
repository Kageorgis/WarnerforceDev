/**
   @Author-Cognizant Technology Solutions
   @name-CRM_TargetHandler
   @CreateDate- 14 Mar 2016
   @Description-
   @Version-1.0
   @reference-None
*/
public with sharing class CRM_TargetHandler {
  
    /*
    
        Description: This method will filter the impacted Account plans that need processing. This method would be called on 'After Insert', 'After Update' and 'After Delete' events.
    
        Inputs: Old and new maps of Target from CRM_Target trigger.
    
        Output: 
        1] updates the PublishedTarget__c field on Account Plan
        2] updates 'Target_Revenue_Has_Changed__c' and 'NR_Version__c' when 'Rollup_Revenue_Change__c' == true
    
    */
    
    public void updateTargetAccountPlan(Map<Id, Target__c> oldTargetMap, Map<Id, Target__c> newTargetMap){
        set<Id> setImpactedAccountPlanIDs = new set<Id>();
        set<Id> setTargetChangedAccountPlans = new set<Id>();

        if(trigger.isInsert || trigger.isUpdate) {
            
            for(Target__c target : newTargetMap.values()) {
                Target__c oldTarget = (oldTargetMap == null? null : oldTargetMap.get(target.Id));
                Boolean hasAccountPlanChanged = (oldTarget != null && target.Account_Plan_Lookup__c != oldTarget.Account_Plan_Lookup__c);
                Boolean hasTargetChanged = (oldTarget != null && target.Target__c != oldTarget.Target__c);
                
                if(trigger.isInsert || ( trigger.isUpdate &&  (hasAccountPlanChanged || hasTargetChanged) )) {

                       setImpactedAccountPlanIDs.add(target.Account_Plan_Lookup__c);

                       if(oldTarget != null && oldTarget.Account_Plan_Lookup__c != null && hasAccountPlanChanged) {
                           setImpactedAccountPlanIDs.add(oldTarget.Account_Plan_Lookup__c);
                       }

                       if(target.Target__c != null && target.Rollup_Revenue_Change__c == true && target.Account_Plan_Lookup__c != null &&
                           (trigger.isInsert || (trigger.isUpdate && hasTargetChanged))) {
                           setTargetChangedAccountPlans.add(target.Account_Plan_Lookup__c);
                       }
                }
            }
        }
        
        if(trigger.isDelete) {
            //US#1034 start
            Map<String, Id> mapUniqueKeyToTargetId = new Map<String, Id>();
            Map<id,Opportunity> mapOfDeals = new Map<id,Opportunity>();
            List<OpportunityLineItem> lstDealItems = new List<OpportunityLineItem>();
            //US#1034 end
            for(Target__c target : oldTargetMap.values()) {
                //US#1034 start
                if(target.Product__c != null && target.Account_Plan_Lookup__c == null){
                    mapUniqueKeyToTargetId.put(target.Account__c + '-' + target.Product__c,target.id);
                }
                //US#1034 end
                setImpactedAccountPlanIDs.add(target.Account_Plan_Lookup__c);
            }
            
            //US#1034 start
            for(OpportunityLineItem dealProd :  [SELECT ID,Product2Id, Opportunityid, Opportunity.Sales_Organisation__c,NR_Deal_Product_Unique_Key__c 
                                                        FROM OpportunityLineItem 
                                                        WHERE NR_Deal_Product_Unique_Key__c != null
                                                        AND NR_Deal_Product_Unique_Key__c IN: mapUniqueKeyToTargetId.keySet() 
                                                        AND (Opportunity.Stagename =: CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED 
                                                                OR Opportunity.Stagename =: CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT)
                                                        AND Opportunity.Sales_Organisation__c NOT IN: CRM_AppConstants.US_SALES_ORGS
                                                        AND Opportunity.Account_Digital_Country_Code__c NOT IN: CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODES LIMIT 10000] ){
                mapOfDeals.put(dealProd.Opportunityid,dealProd.Opportunity);
                lstDealItems.add(dealProd);
            }
            
           //Delete the Deal Products where Country Plans and Account Plans do not exists for the targets 
            if (!lstDealItems.isEmpty()) {
                Database.DeleteResult[] result = Database.delete(lstDealItems, false);
                List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
                for (Integer i=0; i < result.size(); i++ ) {
                    OpportunityLineItem dealProInstance = lstDealItems[i];
                    if (!result[i].isSuccess()) {
                        for (Database.Error err : result[i].getErrors()) {

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_TARGET;
                            errorLog.recordId = dealProInstance.Id;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        if (!listErrorLog.isEmpty()) {
                            CRM_ErrorLogger.logError(listErrorLog);
                        }
                        Database.Error error = result.get(i).getErrors().get(0);
                        String failedDML = error.getMessage(); 
                        OpportunityLineItem oppLineItem = lstDealItems[i];
                        oldTargetMap.get(mapUniqueKeyToTargetId.get(oppLineItem.NR_Deal_Product_Unique_Key__c)).addError(
                            String.format(
                                System.Label.CRM_Opportunity_Line_Item_Delete_Failure_Msg,
                                new String[] {
                                    failedDML
                                }
                            )
                        );
                    }
                }
            } 
            for(AggregateResult result: [SELECT Count(Id) Sum, OpportunityId oppId 
                                                FROM OpportunityLineItem WHERE OpportunityId in :mapOfDeals.keySet() 
                                                GROUP BY OpportunityId]) {
                Integer countDealItems = (Integer)result.get('Sum');
                if(mapOfDeals.containsKey((Id)result.get('oppId')) && countDealItems > 0){
                    mapOfDeals.remove((Id)result.get('oppId'));
                }
            }
            //Delete the Deal with no Deal Products left 
            if (!mapOfDeals.isEmpty()) {
                List<Opportunity> lstDealToDelete = new List<Opportunity>();
                lstDealToDelete = mapOfDeals.values();
                Database.DeleteResult[] result = Database.delete(lstDealToDelete, false);
                List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
                for (Integer i=0; i < result.size(); i++ ) {
                    Opportunity dealInstance = lstDealToDelete[i];
                    if (!result[i].isSuccess()) {
                        for (Database.Error err : result[i].getErrors()) {

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = dealInstance.Id;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_TARGET;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        if (!listErrorLog.isEmpty()) {
                            CRM_ErrorLogger.logError(listErrorLog);
                        }
                    }
                }
            }  
        } 
        
        //US#1034 end
        updateAccountPlans(setImpactedAccountPlanIDs, setTargetChangedAccountPlans); 
    }
    

    /*
        Description: This method rolls up the 'target__c' field on Target object to PublishedTarget__c field on Account Plan object (that are impacted).
    
        Input: Filtered Account Plan IDs
        
        Output: Updating the Account_Plan__c that are impacted.
    */    
    public static void updateAccountPlans(Set<Id> setImpactedAccPlanIds, set<Id> setTargetRevChangedAccPlans) {
        if(setImpactedAccPlanIds.size() > 0 || setTargetRevChangedAccPlans.size() > 0) {
            Map<Id, Account_Plan__c> mapAcctPlans = new Map<Id, Account_Plan__c>(
                    [SELECT Customer__c, isTargetPresent__c, Country_Plan__c, NR_Version__c,
                    (select Id, Target__c, Account_Plan_Lookup__c from Targets__r)
                    FROM Account_Plan__c 
                    WHERE Id IN: setImpactedAccPlanIds OR Id IN:setTargetRevChangedAccPlans ]
                );
                
            
            for(Account_Plan__c accPlan : mapAcctPlans.values()) {
                Decimal totalPlanRevnue = 0;
                
                if(accPlan.Targets__r != null && accPlan.Targets__r.size() > 0) {
                    for(Target__c target : accPlan.Targets__r) {
                        totalPlanRevnue += (target.Target__c == null ? 0 : target.Target__c);
                    }
                }
                
                accPlan.PublishedTarget__c = totalPlanRevnue;
                
                // Here we update the NR Version and Target Revenue has changed fields. 'NR_Version__c' would be set back to '0' by the batch.
                if(setTargetRevChangedAccPlans.contains(accPlan.Id)) {
                    accPlan.Target_Revenue_Has_Changed__c = true;
                    accPlan.NR_Version__c = accPlan.NR_Version__c == null ? 0 : accPlan.NR_Version__c;
                    accPlan.NR_Version__c += 1;
                }

                if (setImpactedAccPlanIds.contains(accPlan.Id)) {
                    if (accPlan.Targets__r.size() > 0) {
                        accPlan.isTargetPresent__c = true;
                    } else {
                        accPlan.isTargetPresent__c = false;
                    }
                }
            }
            update mapAcctPlans.values();
        }
    }
     /**
    *  Description- This method updates Format On Target
    *  @name-updateFormatOnTarget
    *  @param-lstNewTargets - list of targets
    */
    public static void updateFormatOnTarget(List<Target__c> lstNewTargets){
        for(Target__c apTarget : lstNewTargets){
            if(apTarget.Product_Format__c != apTarget.Format__c){
                apTarget.Product_Format__c = apTarget.Format__c;
            }
        }
    }
    
    /*   
        Description: This method is used to update Account object. This method would be called on 'After Insert' and 'After Update' events.
    
        Inputs: Old and new maps of Target from CRM_Target trigger. 
    */
    public static void updateAccount(Map<Id, Target__c> oldTargetMap, Map<Id, Target__c> newTargetMap){
        set<Id> accIds = new set<Id>();
        for(Target__c target:newTargetMap.values()){
            if(trigger.isInsert){  
                accIds.add(target.Account__c);               
            }
            if(trigger.isUpdate){
                Target__c oldTarget = (oldTargetMap == null ? null : oldTargetMap.get(target.id));
                Boolean hasGLCalendarChanged = (oldTarget != null && oldTarget.GL_Calendar__c != target.GL_Calendar__c);
                Boolean hasStartDateChanged = (oldTarget != null && oldTarget.StartDate__c != target.StartDate__c);
                Boolean hasBundleChanged = (oldTarget != null && oldTarget.Bundle__c != target.Bundle__c);
                
                if(hasGLCalendarChanged || hasStartDateChanged || hasBundleChanged){
                    accIds.add(target.Account__c);
                }
            }
        }
    
        if(accIds != null && !accIds.isEmpty()){
            List<Account> accountList = [SELECT Id,scheduleRevenueChanged__c from Account where Id IN:accIds AND scheduleRevenueChanged__c = FALSE];
            for(Account acc:accountList){
                acc.scheduleRevenueChanged__c = TRUE;
            }
            
            if(!accountList.isEmpty() && accountList != null){
                Update accountList;
            }
        }

    }
	
    /* Description: This method is created for ER-003346. This is called in Target Before Insert trigger to check if any EAD exists 
                    for given combination of Video Version, Format, Channel and Country. If does not exist then it creates it.
    */    
    public static void createTempEAD(List<Target__c> lstNewTargets){
        Map<String,ID> mapEADKeyWithProductId = new Map<String,ID>();
        List<Earliest_Avail_Date__c> lstEAD = new List<Earliest_Avail_Date__c>();
        List<Product2> lstProd = new List<Product2>();
        
        for(Target__c target : lstNewTargets){
            if(target.EAD_Key__c != '' && target.EAD_Key__c != null && !mapEADKeyWithProductId.containsKey(target.EAD_Key__c)){
                mapEADKeyWithProductId.put(target.EAD_Key__c, target.Product__c);
            }
        }
        
        System.debug('mapEADKeyWithProductId ' +mapEADKeyWithProductId);
        
        if(!mapEADKeyWithProductId.isEmpty()){
            for(Earliest_Avail_Date__c ead : [select id,Key__c from Earliest_Avail_Date__c where Key__c in :mapEADKeyWithProductId.keySet()]){
                if(mapEADKeyWithProductId.containsKey(ead.Key__c)){
                    mapEADKeyWithProductId.remove(ead.Key__c);
                }
            }
        }    
        
        if(!mapEADKeyWithProductId.isEmpty()){
            lstProd = [select Id, CurrencyIsoCode, Local_Title__r.Title__c, Local_Title__r.Country__c, Product_Market__c, Product_Format__c
                                    from Product2 where ID in :mapEADKeyWithProductId.values()];
            System.debug('lstProd ' +lstProd); 
        }                               
                                    
        for(Product2 prod : lstProd){
            Earliest_Avail_Date__c ead = new Earliest_Avail_Date__c();
            ead.Title__c = prod.Local_Title__r.Title__c;
            ead.Country__c = prod.Local_Title__r.Country__c;
            ead.Channel__c = prod.Product_Market__c;
            ead.Format__c = prod.Product_Format__c;
            ead.Status__c = CRM_AppConstants.EARLIEST_AVAIL_DATE_STATUS_UNLOCKED;
            ead.Source__c = CRM_AppConstants.EARLIEST_AVAIL_DATE_SOURCE_TARGET;
            ead.CurrencyIsoCode = prod.CurrencyIsoCode;
            
            if(!String.isBlank(ead.Title__c) && !String.isBlank(ead.Channel__c) && !String.isBlank(ead.Format__c) && !String.isBlank(ead.Country__c)){
                lstEAD.add(ead);
            }
        }
        System.debug(lstEAD);
        
        if(!lstEAD.isEmpty() && lstEAD != null){
            insert lstEAD;
        }
    }      

}