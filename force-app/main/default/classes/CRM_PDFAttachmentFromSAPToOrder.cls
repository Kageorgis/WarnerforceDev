/**
   @Author Cognizant
   @name CRM_PDFAttachmentFromSAPToOrder 
   @CreateDate 13 OCT 2016
   @Description Inbound Email Service Handler Class
   @Version <1.0>
   @reference Requirement no 474(JAPAN)
*/
global class CRM_PDFAttachmentFromSAPToOrder implements Messaging.InboundEmailHandler {
  
    /*
    @name handleInboundEmail
    @Param Messaging.InboundEmail,Messaging.InboundEnvelope
    @Return Messaging.InboundEmailResult
    @throw none
    */
    private List<CRM_Error_Log__c> listErrorLog;  
    private String orderNumber;
    //Defect#4751: Restricting failures mail to recepients.
    private String restrictedEmailAddress;
    private Decimal LPFRAmount;
    private Order multiReturnOrder;
    private boolean isValidForApproval;
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope){
        listErrorLog = new List<CRM_Error_Log__c>();  
        Messaging.InboundEmailResult inboundEmailresult = new Messaging.InboundEmailresult();
        if(email.binaryAttachments != null && email.Subject != null){
            extractOrderNumberANDLPFRAmountFromSubject(email.Subject);
            Order objOrder = getOrderFromOrderNumber(email.Subject);
            List<Attachment> lstAttachment = getListOfAttachmentFromEmail(objOrder, email.binaryAttachments);
            if(lstAttachment.size() > 0){
                insert lstAttachment;
                inboundEmailresult.success = true;
            }
        }else{
            logError('25','Class.CRM_PDFAttachmentFromSAPToOrder.handleInboundEmail: line 25',System.label.CRM_Attachment_not_found);
        }
        // Inserts all errors into database
        if(listErrorLog.size() > 0){
            insert listErrorLog;
             //DEF#4524 Start
            List<CRM_Error_Log__c> crmErrorLog = [SELECT ID,Message__c,Stack_Trace__c,Functional_Module__c  FROM CRM_Error_Log__c WHERE CreatedBy.Name =: CRM_AppConstants.SFDC_Batch_User AND CreatedDate = TODAY AND ID IN :listErrorLog AND Message__c LIKE :Label.CRM_Invalid_Subject + '%' AND Functional_Module__c =: CRM_AppConstants.FUNCTIONAL_MODULE_PDF_FROM_SAP_TO_RETURNORDER];        
            
            //Defect#4751: Restricting failures mail to recepients.
            CRM_Default_Configuration__c cdc = CRM_Default_Configuration__c.getOrgDefaults();
            restrictedEmailAddress = cdc.CRM_PDF_SAP_To_Order_RestrictedEmail__c; 
            if(!crmErrorLog.isEmpty() && restrictedEmailAddress!=null && email.fromAddress == restrictedEmailAddress ){
                BatchStatusNotification.sendPDFErrorEmailToUsers(crmErrorLog[0].Stack_Trace__c,crmErrorLog[0].Message__c,crmErrorLog[0].Id,CRM_AppConstants.Entity_CRM);
            }
            //DEF#4524 End
        }    
        return inboundEmailresult;
    }
    private void extractOrderNumberANDLPFRAmountFromSubject(String subject){
        List<String> lstSubject = subject != null ? subject.split('-') : new List<String>();
        if(lstSubject.size() > 0 && lstSubject.get(0) != null){
            String regExp = '\\D';
            String tempStr = lstSubject.get(0).replaceAll(regExp,'').trim();
            if(tempStr.length() > 0 && pattern.matches('^[0-9]*$',tempStr))
                orderNumber = String.escapeSingleQuotes(tempStr);
        }
        if(lstSubject.size() > 1 && lstSubject.get(1) != null){
            String decimalRegex = '^\\d*\\.?\\d*$';
            String LPRFAmount = lstSubject.get(1).trim();
            if(LPRFAmount.length() > 0 && pattern.matches(decimalRegex,LPRFAmount))
                LPFRAmount =  Decimal.valueOf(LPRFAmount);
        }else{
            logError('49','Class.CRM_PDFAttachmentFromSAPToOrder.extractOrderNumberANDLPFRAmountFromSubject: line 49 for Order '+orderNumber,(System.Label.CRM_Invalid_Subject+' : '+subject));
        }
    }
  
    private Order getOrderFromOrderNumber(String subject) {
        if(orderNumber != null) {
            List<Order> lstOrder = new List<Order>();
            lstOrder = [Select Id,OrderNumber,Sales_Organisation__c,LPFR_Return_Value__c,OwnerId,Return_Approval__c,Multi_Order__c,Multi_Order__r.Return_Approval__c From Order Where OrderNumber =: orderNumber Limit 1];
            if (lstOrder.size() > 0){
                if(
                    (lstOrder[0].Multi_Order__c == null && (lstOrder[0].Return_Approval__c == CRM_AppConstants.RETURN_ORDER_RETURN_APPROVAL || lstOrder[0].Return_Approval__c == CRM_AppConstants.RETURN_ORDER_RETURN_REJECTED))
                    ||
                    (lstOrder[0].Multi_Order__c != null && (lstOrder[0].Multi_Order__r.Return_Approval__c == CRM_AppConstants.RETURN_ORDER_RETURN_APPROVAL || lstOrder[0].Multi_Order__r.Return_Approval__c == CRM_AppConstants.RETURN_ORDER_RETURN_REJECTED))
                ){
                    return lstOrder[0];
                }else if (CRM_AppConstants.GERMANY_SALES_ORGS.contains(lstOrder[0].Sales_Organisation__c) && lstOrder[0].Return_Approval__c == CRM_AppConstants.RETURN_ORDER_RETURN_AWAITING_APPROVAL){
                    return lstOrder[0];
                }
                if(LPFRAmount != null){
                    if( lstOrder[0].LPFR_Return_Value__c != LPFRAmount){
                        lstOrder[0].LPFR_Return_Value__c = LPFRAmount;
                        //update lstOrder; DEF#4829
                    }
                    if(lstOrder[0].Multi_Order__c != null){
                        List<Order> lstMultiReturnOrder = [SELECT Id,OwnerId,LPFR_Return_Value__c FROM Order WHERE Id = :lstOrder[0].Multi_Order__c];
                        if(!lstMultiReturnOrder.isEmpty()){
                            multiReturnOrder = lstMultiReturnOrder[0];
                            isValidForApproval = isValidForApproval();
                            //DEF#4829 start
                            List<Order> lstChildOrder = [SELECT Id,LPFR_Return_Value__c FROM Order WHERE Multi_Order__c =:multiReturnOrder.Id AND LPFR_Return_Value__c != null AND Id !=:lstOrder[0].Id];
                            
                             Decimal totalLPFRAmount = LPFRAmount != null ? LPFRAmount : 0;
                            for(Order childOrder : lstChildOrder){
                                totalLPFRAmount += childOrder.LPFR_Return_Value__c;
                            }
                            system.debug('totalLPFRAmount : '+totalLPFRAmount);
                            if(multiReturnOrder.LPFR_Return_Value__c != totalLPFRAmount){
                                 multiReturnOrder.LPFR_Return_Value__c = totalLPFRAmount;
                                //update multiReturnOrder; DEF#4829 
                                lstOrder.add(multiReturnOrder);
                            }
                        }
                        //update lstOrder; //assert were failing so commented this line and added below
                    }
                     update lstOrder;
                }
                return lstOrder[0];
            }else{
                logError('69','Class.CRM_PDFAttachmentFromSAPToOrder.getOrderFromOrderNumber: line 69',(System.Label.CRM_Order_Not_Found+' : '+OrderNumber));
                return null;
            }
        }else {
            logError('51','Class.CRM_PDFAttachmentFromSAPToOrder.extractOrderNumberANDLPFRAmountFromSubject: line 51',(System.Label.CRM_Invalid_Subject+' : '+subject));
            return null;
        }
    }
    private boolean isValidForApproval(){
        Integer nonLPFRAmountOrders = [SELECT count() From Order WHERE Multi_Order__c =:multiReturnOrder.Id AND LPFR_Return_Value__c = null];
        List<ProcessInstance> processInstances = [select Id from ProcessInstance where TargetObjectId = :multiReturnOrder.Id];
        if(nonLPFRAmountOrders > 0 || !processInstances.isEmpty()){
            return false;
        }
        return true;
    }
    private List<Attachment> getListOfAttachmentFromEmail(Order objOrder, List<Messaging.InboundEmail.BinaryAttachment> emailAttachments) {
        List<Attachment> lstAttachments = new List<Attachment>();
        boolean attachmentFlag = true;
        if(null != objOrder && emailAttachments != null) {
            for (integer index = 0 ; index < emailAttachments.size() ; index++) {
                if(emailAttachments[index].filename.containsIgnoreCase('.pdf')){
                    //Create Attachment
                    Attachment attachment = new Attachment();
                    // attach to Order
                    attachment.OwnerId = objOrder.OwnerId;
                    attachment.ParentId = objOrder.Id;
                    attachment.Name = emailAttachments[index].filename;// +'-'+String.valueOf(DateTime.now().getTime());
                    attachment.Body = emailAttachments[index].body;
                    lstAttachments.add(attachment);
                    attachmentFlag = false;
                }
            }
        }
        if(attachmentFlag){
            logError('120','Class.CRM_PDFAttachmentFromSAPToOrder.getListOfAttachmentFromEmail: line 120',System.Label.CRM_Attachment_not_found);
        }
        return lstAttachments;
    }
    
    private void logError(String lineNumber,String stackTrace,String errorMsg){
        CRM_Error_Log__c errorLog = new CRM_Error_Log__c();
        errorLog.Functional_Module__c = CRM_AppConstants.FUNCTIONAL_MODULE_PDF_FROM_SAP_TO_RETURNORDER;
        errorLog.Line_Number__c = lineNumber;
        errorLog.Stack_Trace__c = stackTrace;
        errorLog.Message__c = errorMsg;
        listErrorLog.add(errorLog);
    }
}