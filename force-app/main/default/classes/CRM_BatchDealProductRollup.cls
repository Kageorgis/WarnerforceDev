/**
   @Author Cognizant
   @name CRM_BatchDealProductRollup 
   @CreateDate 18 Jan 2016
   @Description This batch class will be used to Update/Rollup deal product POS fields from schedules entry. It will run daily.
   @Version <1.0>
   @reference Requirement no 53
*/

global class CRM_BatchDealProductRollup implements Database.Batchable<sObject>, Schedulable{       
    /**
     *  start method
     *  @name start
     *  @param Database.BatchableContext BC
     *  @return Database.QueryLocator
     *  @throws Exception None
     */
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    	ID actualsRecordTypeID = CRM_RecordTypeUtil.RT_DEAL_ACTUALS;
    	String stage = CRM_AppConstants.OPPORTUNITY_STAGE_POS_Actuals;
    	
        String strQuery = 'SELECT ID, Opportunity.Promo_Start_Date__c, POS_Last_Date__c, Opportunity.Promo_End_Date__c, (SELECT ID, ScheduleDate, Quantity, Revenue FROM OpportunityLineItemSchedules Order By ScheduleDate Desc)'; 
        strQuery += 'FROM OpportunityLineItem WHERE Opportunity.RecordTypeID =: actualsRecordTypeID AND Opportunity.StageName =: stage'  ;
        return Database.getQueryLocator(strQuery);
    }
    
    /**
     *  Execute the logic
     *  @name execute
     *  @param Database.BatchableContext BC
     *  @param List<OpportunityLineItem> scope
     *  @return None
     *  @throws Exception None
     */
    
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope){
    	List<OpportunityLineItem> dealProductsToUpdate = new List<OpportunityLineItem>();
    	Decimal posRevenueSum;
    	Decimal posQuantitySum;
    	
		for(OpportunityLineItem currentLineItem : scope){   
    		posRevenueSum = 0;
    		posQuantitySum = 0;
        	Date startDate = currentLineItem.Opportunity.Promo_Start_Date__c;
        	Date enddate = currentLineItem.Opportunity.Promo_End_Date__c;
        	
			for(OpportunityLineItemSchedule currentSchedule : currentLineItem.OpportunityLineItemSchedules){
        		if(currentSchedule.ScheduleDate != null && startDate != null && enddate != null && 
        			currentSchedule.ScheduleDate >= startDate && currentSchedule.ScheduleDate <= enddate){
        			
        			if( currentLineItem.POS_Last_Date__c == null)
        				currentLineItem.POS_Last_Date__c = currentSchedule.ScheduleDate;
        				
    				if(currentLineItem.POS_Last_Date__c < currentSchedule.ScheduleDate)
    					currentLineItem.POS_Last_Date__c = currentSchedule.ScheduleDate;
    					
        			posRevenueSum += currentSchedule.Revenue != null ? currentSchedule.Revenue : 0;
        			posQuantitySum += currentSchedule.Quantity != null ? currentSchedule.Quantity : 0;
        		}
    		}
    		currentLineItem.POS_Quantity__c = posQuantitySum;
        	currentLineItem.POS_Revenue__c = posRevenueSum;
			dealProductsToUpdate.add(currentLineItem);
		}
		update dealProductsToUpdate;
	}
    
    /**
     *  Sending mail with batch results to batch executor 
     *  @name finish
     *  @param Database.BatchableContext BC
     *  @return None
     *  @throws Exception None
     */
    
    global void finish(Database.BatchableContext BC){
        /*AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, 
                            CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :BC.getJobId()];  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {a.CreatedBy.Email};  
        mail.setToAddresses(toAddresses);       
        mail.setSubject('"Roll Up Actual Revenue And Quantity To Deal Products" BatchJob Status: ' + a.Status);  
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +  
                                        ' batches with '+ a.NumberOfErrors + ' failures. Message: ' + a.ExtendedStatus);  
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
        */
          BatchStatusNotification.sendBatchStatusMail(BC,'Deal Product Roll up Batch');  
    }
    
    /**
     *  Schedulable method to schedule this batch class
     *  @name execute
     *  @param SchedulableContext sc
     *  @return None
     *  @throws Exception None
     */
    
    global void execute(SchedulableContext sc) {
    }
}