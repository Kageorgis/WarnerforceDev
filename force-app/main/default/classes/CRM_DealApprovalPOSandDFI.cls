/**
   @Author: Accenture
   @name: CRM_DealApprovalPOSandDFI
   @CreateDate: May 08, 2020
   @Description:  Controller class to check for entry criteria and further checks before sending a Deal for approval.
   @Version - 1.0
   @reference: None
  */
  global with sharing class CRM_DealApprovalPOSandDFI{
    
    private static boolean raiseAlert;
    public static List<Id> approversIds;
    
    /** 
    *  Method to fetch the Deal Overlap Details
    *  @name getDealOverlapFuture
    *  @param Deal Id
    *  @return Deal Wrapper with Overlap Details
    *  @throws Exception
*/ 
    public static DealWrapper getDealOverlapFuture(Id oppId){
        Opportunity newOpp = [select id,name,Deal_Overlap_Results_10k_Plus__c,Deal_Overlap_Records_Queried__c,
                              Deal_Overlap_Review_Completed__c,Deal_Overlap_Exists__c,Deal_Overlap_Last_Executed__c,
                              LastModifiedDate,RecordType.DeveloperName,Sales_Organisation__c from opportunity where id =: oppId LIMIT 1];
        DealWrapper dealWrapper = new DealWrapper(); 
        dealWrapper.lstLineItemWrapper = new List<CRM_DataObjects.PhysicalProductToEdit>();
        // No OverLap but user has clicked the review button
        if(newOpp.Deal_Overlap_Review_Completed__c && !newOpp.Deal_Overlap_Exists__c){ 
            try{
            raiseAlert = false;
            String result = preApprovalProcessCheckPoint(oppId);
            if(!String.isBlank(result)){
                throw new CRM_DealApprovalException(result);
            }
            }catch(Exception execpt){
                logAnException(execpt, oppId);
                throw new CRM_DealApprovalException(execpt.getMessage());
            }
            dealWrapper.showValidationCheck = System.Label.CRM_No_Overlap_Physical;
            dealWrapper.showMessage = false; // should be false to submit for approval
            dealWrapper.validationError = false; // should be false to submit for approval
            return dealWrapper;
        }
        // OverLapped
        else if(newOpp.Deal_Overlap_Review_Completed__c && newOpp.Deal_Overlap_Exists__c){
            Map<String,Set<Id>> existingdealsThatOverlapProducts = new Map<String,Set<Id>>();
            Set<String> exisitngDealString = new Set<String>();
            Set<Id> existingDealsId = new Set<Id>();
            try {
                raiseAlert = false;
                String result = preApprovalProcessCheckPoint(oppId);
                if(!String.isBlank(result)){
                    throw new CRM_DealApprovalException(result);
                }
                Set<String> productCodes = new Set<String>();
                List<CRM_DataObjects.DealOverLapWrapper> newList1 = new List<CRM_DataObjects.DealOverLapWrapper>();
                CRM_DataObjects.DealOverLapWrapper wrap = new CRM_DataObjects.DealOverLapWrapper();
                CRM_DataObjects.PhysicalProductToEdit prod = new CRM_DataObjects.PhysicalProductToEdit();
                for(Deal_Overlap__c dealOver :[select Current_Deal__c,Current_Deal_Product_Id__c,End_Date__c,
                                               Overlap_Deal_Id__c,Product_Id__c,Product_Name__c,Start_Date__c,Reason__c,Product_Code__c,Overlap_Deal_Code__c,
                                               Overlap_Deal_Stage_Name__c,Overlap_Deal_Product_Start_Date__c,Overlap_Deal_Product_End_Date__c,Overlap_Deal_Name__c from Deal_Overlap__c where Current_Deal__c =: oppId order by Product_Code__c]){
                                                   if(!productCodes.contains(dealOver.Product_Code__c)){
                                                       
                                                       newList1 = new List<CRM_DataObjects.DealOverLapWrapper>();
                                                       wrap = new CRM_DataObjects.DealOverLapWrapper();
                                                       prod = new CRM_DataObjects.PhysicalProductToEdit();
                                                       productCodes.add(dealOver.Product_Code__c);
                                                       prod.lineItemId = dealOver.Current_Deal_Product_Id__c;
                                                       prod.productId = dealOver.Product_Id__c;
                                                       prod.productName = dealOver.Product_Name__c;
                                                       prod.productCode = dealOver.Product_Code__c;
                                                       prod.coopReason = dealOver.Reason__c;
                                                       prod.startDate = dealOver.Start_Date__c;
                                                       prod.endDate = dealOver.End_Date__c;
                                                       wrap.overLapId = dealOver.Overlap_Deal_Id__c;
                                                       wrap.dealCode = dealOver.Overlap_Deal_Code__c;
                                                       wrap.dealName = dealOver.Overlap_Deal_Name__c;
                                                       wrap.stageName = dealOver.Overlap_Deal_Stage_Name__c;
                                                       wrap.startDate = dealOver.Overlap_Deal_Product_Start_Date__c;
                                                       wrap.endDate = dealOver.Overlap_Deal_Product_End_Date__c;
                                                       newList1.add(wrap);
                                                       if(!productCodes.isEmpty() && productCodes.size() < 9999){
                                                           prod.dealOverlapWrap = newList1;
                                                           dealWrapper.lstLineItemWrapper.add(prod);
                                                       }
                                                   }else{
                                                       wrap = new CRM_DataObjects.DealOverLapWrapper();
                                                       wrap.overLapId = dealOver.Overlap_Deal_Id__c;
                                                       wrap.dealCode = dealOver.Overlap_Deal_Code__c;
                                                       wrap.dealName = dealOver.Overlap_Deal_Name__c;
                                                       wrap.stageName = dealOver.Overlap_Deal_Stage_Name__c;
                                                       wrap.startDate = dealOver.Overlap_Deal_Product_Start_Date__c;
                                                       wrap.endDate = dealOver.Overlap_Deal_Product_End_Date__c;
                                                       newList1.add(wrap);
                                                   }
                                                   raiseAlert = true;
                                               }    
            }catch(Exception except){
                logAnException(except, oppId);
                throw new CRM_DealApprovalException(except.getMessage());
            }
            dealWrapper.showMessage = raiseAlert;
            dealWrapper.showValidationCheck = System.Label.CRM_Overlapped_Checked_Physical;
            dealWrapper.validationError = false;
            system.debug(dealWrapper);
            system.debug(dealWrapper.lstLineItemWrapper);
            return dealWrapper;
        }else{
            // Added condition for JV Planning Deal and JV Sales ORG 
            if(newOpp.RecordType.DeveloperName == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_PLANNING_DEAL &&(newOpp.Sales_Organisation__c==CRM_AppConstants.TERRITORY_SDS_US_CODE ||newOpp.Sales_Organisation__c==CRM_AppConstants.TERRITORY_SDS_CANADA_CODE ) ){
                dealWrapper.showValidationCheck = System.Label.CRMJV_Check_For_Review_Before_Overlapping_Deal;
            }else{
                // Not Reviewed for Overlap
                dealWrapper.showValidationCheck = System.Label.CRM_Check_For_Review_Before_Approval;
            }
            dealWrapper.showMessage = true;
            dealWrapper.validationError = true;
            return dealWrapper;
        }
        
    }
    /**
    *  @Description - method to perform approval process and then redirect control back to Deal standard detail page
    *  @name  callStandardApprovalProcess 
    */
    @AuraEnabled
    global static void callStandardApprovalProcess(Id dealID){
            // createNewApprovalProcess(dealID);
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(dealID);
            List<String> userIds = new List<String>{UserInfo.getUserId()};
            // login user
            req.setNextApproverIds(userIds);
            // submit the approval request for processing
            Approval.ProcessResult result = Approval.process(req);
            if(result.isSuccess() == true){
                approveRecord(dealID);
            }
    }
    /**
    *  @Description - method to perform approval of the record
    *  @name  approveRecord 
    */
    @RemoteAction
    global static void approveRecord(Id dealID){
        //--Added for project--adding sales org filed in select list--//
        Opportunity deal = [select id,RecordType.DeveloperName,Promo_Start_Date__c,Sales_Organisation__c from Opportunity where id =: dealID LIMIT 1];
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        // req.setComments('Approval Request - Approved');
        //--Added for JV project--adding sales org condition to skip code logic--//
        if((deal.Sales_Organisation__c != CRM_AppConstants.TERRITORY_SDS_US_CODE && deal.Sales_Organisation__c != CRM_AppConstants.TERRITORY_SDS_CANADA_CODE) && 
          (deal.RecordType.DeveloperName == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL ||
          (deal.RecordType.DeveloperName == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DFI_DEAL
           && deal.Promo_Start_Date__c > System.today()))){
            req.setAction('Approve');
               String workItemId = getWorkItemId(dealID); 
               if(workItemId == null)
               {
                   Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                   req1.setObjectId(dealID);
                   req.setNextApproverIds(approversIds);
                   req1.setProcessDefinitionNameOrId('CRM_Retro_DFI_Submit_Approval');
                   req1.setSkipEntryCriteria(false);
                   Approval.ProcessResult result = Approval.process(req1);
                   System.debug('Error Occured in Trigger');
               }
               else
               {
                   req.setWorkitemId(workItemId);
                   // Submit the request for approval
                   Approval.ProcessResult result =  Approval.process(req);
               }
           }
    }
    /**
    *  @Description - method to get the WorkItemId
    *  @name  getWorkItemId 
    */
     public static Id getWorkItemId(Id targetObjectId){
        Id workItemId = null;
        approversIds = new List<Id>();
        try{
            for(ProcessInstanceWorkitem workItem  : [Select p.Id,ActorId from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: targetObjectId LIMIT 1]){
                if(workItem.ActorId == UserInfo.getUserId()){
                    workItemId  =  workItem.Id;
                }
                approversIds.add(workItem.ActorId);
            }
         }catch(Exception execp){
             throw new CRM_DealApprovalException(execp.getMessage());
         }
        return workItemId;
    }

    /*
    *  This method will take the exception occured as an input and forward it to the common utility class. 
    *  @name: logAnException
    *  @param: Exception ex
    *  @return: void 
    */
    public static void logAnException(Exception ex, Id recordId){
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        if (recordId != null){
            errorLogInstance.recordId = recordId;
        }
        // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
        errorLogInstance.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DEALS;
        errorLogInstance.lineNumber = String.valueof(ex.getLineNumber());
        errorLogInstance.errorMessage = ex.getMessage();
        errorLogInstance.stackTrace = ex.getStackTraceString();
        listErrorLog.add(errorLogInstance);     
    }
    
    /**
    *  @Description - wrapper class
    *  @name  DealProductWrapper 
    */
    
    global without sharing class DealProductWrapper{
        public OpportunityLineItem lineItemRecord;
    }
    /**
    *  @Description - wrapper class
    *  @name  DealWrapper 
    */
    global without sharing class DealWrapper{
        public Boolean showMessage=false;
        public Boolean validationError = false;
        public string showValidationCheck;
        public List<CRM_DataObjects.PhysicalProductToEdit> lstLineItemWrapper;
    }
    /**
    *  @Description - method to perform pre approval process and return errors if present
    *  @name  preApprovalProcessCheckPoint 
    */
    @AuraEnabled 
    global static String preApprovalProcessCheckPoint(Id oppId) 
    {
        Opportunity opp; 
        String stage;
        Date pricingStartDate;
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        //--ER-007676-Added count field in opportunity select list--//
        lstOpportunity = [SELECT id,RecordTypeId, StageName, Start_Date__c,HasOpportunityLineItem,RecordType.Name, RecordType.DeveloperName, 
                            OwnerId, CreatedById, Count_Opportunity_Products__c, Count_Cancel_Opportunity_Products__c 
                            FROM Opportunity WHERE Id =: oppId LIMIT 50000];
        if(!lstOpportunity.isEmpty())
        {
            opp = lstOpportunity.get(0);
            stage = opp.StageName;
            pricingStartDate = opp.Start_Date__c;
        }
        String strReturn = '';
        if (String.isNotBlank(stage))
        {
            if(!(stage.equalsIgnoreCase(CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED)|| stage.equalsIgnoreCase(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED))) 
            {             
                strReturn = Label.CRM_Msg_Deal_Approval_Incorrect_Stage;
            } 
            else if(opp != null && opp.HasOpportunityLineItem == false){
                strReturn = Label.CRM_PhysicalPosDfi_Deal_Approval_No_DealProduct;
            }
            //--ER-007676-check for all DPs in cancel, not allow to submit--Start--//
            else if(opp != null && opp.HasOpportunityLineItem && opp.Count_Opportunity_Products__c == opp.Count_Cancel_Opportunity_Products__c){
                strReturn = System.Label.CRMJV_Submit_DFIDeal_Restrict_ProductCancel;
            }   //--ER-007676-check for all DPs in cancel, not allow to submit--End--//
        } 
        return strReturn;
    }
    /**
    *  @Description - Exception class
    *  @name  CRM_DealApprovalException 
    */ 
    public class CRM_DealApprovalException extends Exception {
        
    }
    
    /** 
    *  Method to fetch the Deal Attributes
    *  @name getOpportunityDetails
    *  @param Deal Id
    *  @return Opportunity Record
    *  @throws none
*/ 
    @AuraEnabled
    public static Opportunity getOpportunityDetails(Id oppId) { 
        Opportunity lstOpportunity = new Opportunity();
        try{
        lstOpportunity = [SELECT id,name,RecordTypeId,RecordType.Name,RecordType.DeveloperName,Deal_Code__c,
                                      Sales_Organisation__c,Deal_Overlap_Last_Executed__c,Deal_Overlap_Results_10k_Plus__c,
                                        StageName,Deal_Overlap_Records_Queried__c,Deal_Overlap_Exists__c,
                                      Pricebook2Id,AccountId,CurrencyISOCode,External_Id__c,
                                      CloseDate,Start_Date__c,Promo_Start_Date__c,Promo_End_Date__c,LastModifiedDate,IsDateMismatched__c
                                      FROM Opportunity 
                                      WHERE Id =: oppId LIMIT 1];
        }catch(Exception except){
            throw new CRM_DealApprovalException(except.getMessage());
        }
        return lstOpportunity;
    }
    
    /**
     *  Method to fetch the overlapping Deals in the system
     *  @name getOverlapDeals
     *  @param Id opportunityId
     *  @return DealWrapper
     *  @throws None
     */
    @AuraEnabled
    public static String getOverlapDeals(Id oppId){
        String result = '';
        try{
            result = JSON.serializePretty(CRM_DealApprovalPOSandDFI.getDealOverlapFuture(oppId));
        }catch(Exception execp){
            throw new CRM_DealApprovalException(execp.getMessage());
        }
        return result;
    }
}