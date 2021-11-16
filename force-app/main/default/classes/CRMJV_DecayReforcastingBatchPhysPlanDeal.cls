/**
@Author Cognizant
@name CRMJV_DecayReforcastingBatchPhysPlanDeal 
@CreateDate 14 Dec 2020
@Description: Batch class to reforcast schedule using new replen quantity.
@Version <1.0>
@reference: W-017679 Enable Decay Curves and Re-forecasting Schedules for Planning deal
*/
global class CRMJV_DecayReforcastingBatchPhysPlanDeal implements Database.batchable<sObject>, Database.stateful{
    
    global String query;
    global List<CRMJV_DecayCurveReforcastingService.CRMJV_DecayCurveReforcastingBatchException> lstExceptions = new List<CRMJV_DecayCurveReforcastingService.CRMJV_DecayCurveReforcastingBatchException>();
    global Set<Id> setErrorDealProductIds = new Set<Id>();
    global Set<Id> setProcessedProductIds = new Set<Id>();    
    global Date currentDate;
    private Date weekStartDate;
    
    /**
*  Constrcutor of the Batch
*  @name CRMJV_DecayReforcastingBatchPhysPlanDeal
*  @return  
*/
    
    //global CRMJV_DecayReforcastingBatchPhysPlanDeal(){
    private void buildQuery(){
        currentDate = currentDate == null ? Date.today() : currentDate;
        String weekStart = String.valueOf(currentDate.toStartofWeek().addDays(-1));
        String weekEnd = String.valueOf(currentDate.toStartofWeek().addDays(5));
        String decayDescription='\'%' + String.escapeSingleQuotes('Decay') + '%\'';
        String lastreforecatdate = String.valueOf(date.today());
        weekStartDate = currentDate.toStartofWeek().addDays(-1);
        system.debug('@@currentDate-->'+currentDate+'--weekStart--'+weekStart+'--weekEnd--'+weekEnd);
        
        List<String> listDealStageName = new List<String>{CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED};
            List<String> listSDSJVDealRecordTypeName = new List<String>{'Physical_Planning_Deal'};
                List<String> listSalesJVOrgs = new List<String>(CRM_AppConstants.SALES_JV_ORGS);        
        
        this.query = 'SELECT Id,Name,OpportunityId,Opportunity.Account.Decay_Curve_Template__c,POS_Quantity__c,Actual_Quantity__c,Replen_Quantity__c,' +
            'New_Replen_Ship_Fcst__c,Start_Date__c,End_Date__c,Deal_Record_Type__c,Product2.Id,Product2.Street_Date__c,Opportunity.Bypass_Committed_Deals__c,Opportunity.StageName, ' +
            'Replen_Ship_Fcst__c, Initial_Ship_Fcst__c,ListPrice__c '+
            ',(SELECT Id,Quantity, Revenue, ScheduleDate from OpportunityLineItemSchedules Where ScheduleDate >='+ weekStart +' AND ScheduleDate <= '+ weekEnd +' AND Description LIKE '+decayDescription+' ORDER BY ScheduleDate ASC)' +
            ' From OpportunityLineItem ' +
            ' Where Deal_Sales_Organisation__c IN (\'' + String.join(listSalesJVOrgs, '\',\'') + '\')' +
            ' AND Deal_Record_Type__c IN (\'' + String.join(listSDSJVDealRecordTypeName, '\',\'') + '\')' +
            ' AND Opportunity.StageName IN (\'' + String.join(listDealStageName, '\',\'') + '\')' +   
            ' AND Last_Re_Forecasted_Date__c !='+lastreforecatdate +' '+
            ' AND Replen_Ship_Fcst__c !=null' +
            ' AND POS_Quantity__c!=null' + 
            ' AND ListPrice__c!=null' +
            ' AND Id NOT IN: setProcessedProductIds' +
            ' AND Id NOT IN: setErrorDealProductIds';
    }    
    
    
    /**
*  Start method of Batch
*  @name start
*  @return  Query locator  - returning the records from query string
*/
    global Database.queryLocator start(Database.BatchableContext BC){
        buildQuery();
        system.debug('@@start.query-->'+this.query);       
        return Database.getQueryLocator(this.query);
    }
    
    /**
* Execute method of Batch
* @name execute
* @param dealProducts- For storing the records returned from Start method
*/
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> listDealProducts){
        system.debug('@@listDealProducts-->'+listDealProducts.size());
        CRM_ApplicationUtility.isDecayCurveReforcastingBatch = true;
        for(OpportunityLineItem var :listDealProducts){
            setProcessedProductIds.add(var.Id); 
        }
        setErrorDealProductIds.addAll(CRMJV_DecayCurveReforcastingService.processDecayCurveReforcasting(listDealProducts, weekStartDate));
        lstExceptions.addAll(CRMJV_DecayCurveReforcastingService.getAllExceptions());
        setProcessedProductIds.removeAll(setErrorDealProductIds);
    }
    
    /**
* Finish method of batch process.
*/
    global void finish(Database.BatchableContext BC){
        List<OpportunityLineItem> listOpportunityLineItem = database.query(query);
        Decimal batchSize =  500;
        
        CRM_Batch_Size__c setting = CRM_Batch_Size__c.getInstance('Decay Curve Re-Forcasting Batch');
        if(setting != null && setting.Batch_Size__c != null){
            batchSize = setting.Batch_Size__c;
        }
        
        if(!listOpportunityLineItem.isEmpty()){
            CRMJV_DecayReforcastingBatchPhysPlanDeal dc = new CRMJV_DecayReforcastingBatchPhysPlanDeal();
            database.executeBatch(dc,Integer.valueOf(batchSize));
        }else if(this.lstExceptions.size() > 0){
            map<Id,OpportunityLineItem> mapProductError = new map<Id,OpportunityLineItem>([SELECT Id, Name FROM OpportunityLineItem WHERE Id IN: setErrorDealProductIds LIMIT 50000]);
            sendMail(mapProductError);
        }else{
            BatchStatusNotification.sendBatchStatusMail(BC, System.Label.CRMJV_DecayReforcastingBatchPhysPlanDeal_Success_Mail_Subject);
            
        }
    }
    
    /**
* @Description - Method to send mail to logged in User for all the failure details of processed deals
* @name sendMail
*/
    @TestVisible
    private void sendMail(map<Id,OpportunityLineItem> mapIdToProductInstance){
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        //Get emailIds from Custom setting
        sendTo = BatchStatusNotification.getBatchNotificationRecipients(CRM_AppConstants.Entity_CRM);
        if(!sendTo.isEmpty()) {
            mail.setToAddresses(sendTo);
        }
        // Step 3: Set who the email is sent from
        mail.setReplyTo(UserInfo.getUserEmail());
        mail.setSenderDisplayName(System.Label.CRMJV_DecayReforcastingBatchPhysPlanDeal_Mail_Display_Name);
        // Step 4. Set email contents!
        mail.setSubject(System.Label.CRMJV_DecayReforcastingBatchPhysPlanDeal_Failure_Mail_Subject); 
        
        String body = '';
        body = '<html>';
        body += '<body>';
        body += '<table border = 1>';
        body += '<tr>';
        body += '<th>' + System.Label.CRM_NR_Batch_Products_Column_Name + '</th>';
        body += '<th>' + System.Label.CRM_Failure_Message_Column_Name + '</th>';
        body += '</tr>';
        
        for(CRMJV_DecayCurveReforcastingService.CRMJV_DecayCurveReforcastingBatchException excp : this.lstExceptions){
            body += '<tr>';
            if(excp.recordId != null){
                if(mapIdToProductInstance.containsKey(excp.recordId) && mapIdToProductInstance.get(excp.recordId).Name != null){
                    body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + mapIdToProductInstance.get(excp.recordId).Name + '</a></td>';
                }else{
                    body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '</a></td>';
                }
            }else{
                body +='<td></td>';
            }
            body += '<td>' + excp.lstErrors[0] + '</td>';
            body += '</tr>';
            if(excp.lstErrors.size() > 1){
                body += '<tr>';
                for(Integer i = 1; i < excp.lstErrors.size(); i++){
                    body += '<td>' + excp.lstErrors[i] + '</td>';
                }
                body += '</tr>';
            }
        }
        body += '<table>';
        body += '</body>';
        body += '</html>';
        mail.setHtmlBody(body);
        
        // Step 6: Send all emails in the master list
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
}