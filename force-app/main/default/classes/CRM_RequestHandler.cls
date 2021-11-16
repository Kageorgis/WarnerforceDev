/**
   @Author-Cognizant Tech Solutions (Tushar)
   @name-CRM_RequestHandler
   @CreateDate-
   @Description-Tis class is used for Request approval process.
   @Version-1.0
   @reference-None
  */ 
public class CRM_RequestHandler{
    
    public static void UpdateApproverfields(list<Request__c> lstRequest, map<Id, Request__c> mapOfOldRequets){
        
        map<String, CRM_Request_Approval_Settings__c> mapOfCSKeyToListOfValues = new map<String, CRM_Request_Approval_Settings__c>();
            
        list<CRM_Request_Approval_Settings__c> lstCustomSetting = CRM_Request_Approval_Settings__c.getAll().Values();
        
        if(lstCustomSetting.size()> 0 && lstCustomSetting != null)
        {
            for(CRM_Request_Approval_Settings__c customSet : lstCustomSetting)
            {
                String csKey = customSet.Type__c +'-'+customSet.Sub_Type__c;
                csKey.DeleteWhitespace();
                mapOfCSKeyToListOfValues.put(csKey,customSet);
            }
        }       
        for(Request__c req :lstRequest)
        {
            if(mapOfOldRequets == null)
            {
                String reqKey = req.Type__c +'-'+ req.Sub_Type__c;
                reqKey.DeleteWhitespace();
                if(null!=mapOfCSKeyToListOfValues && !mapOfCSKeyToListOfValues.IsEmpty() && mapOfCSKeyToListOfValues.containsKey(reqKey))
                {
                    CRM_Request_Approval_Settings__c custmSettingObj =mapOfCSKeyToListOfValues.get(reqKey);
                    
                    req.Manager_Senior_Mgr__c = custmSettingObj.Manager_Senior_Mgr__c;
                    req.Sales_Director__c = custmSettingObj.Sales_Director__c;
                    req.Sales_Planning_Manager__c = custmSettingObj.Sales_Planning_Manager__c;
                    req.Accounting__c = custmSettingObj.Accounting__c;
                    req.Operations__c = custmSettingObj.Operations__c;
                    req.Controller__c = custmSettingObj.Controller__c;
                    req.FP_A_Director__c = custmSettingObj.FP_A_Director__c;
                }
                if(req.Date_Submitted__c != null) {
                    req.Date_Submitted__c = null;
                }
                if(req.Date_Approved__c != null) {
                    req.Date_Approved__c = null;
                }
                if (req.Status__c != null && req.Status__c != CRM_AppConstants.REQUEST_DRAFT_STATUS) {
                    req.Status__c = CRM_AppConstants.REQUEST_DRAFT_STATUS;
                }
            }else
            {
                if((req.Type__c != mapOfOldRequets.get(req.Id).Type__c) || (req.Sub_Type__c != mapOfOldRequets.get(req.Id).Sub_Type__c))
                {
                    String newReqKey = req.Type__c +'-'+ req.Sub_Type__c;
                    newReqKey.deleteWhiteSpace();
                    if( null!=mapOfCSKeyToListOfValues && !mapOfCSKeyToListOfValues.IsEmpty() && mapOfCSKeyToListOfValues.containsKey(newReqKey))
                    {
                        CRM_Request_Approval_Settings__c newCustmSettingObj =mapOfCSKeyToListOfValues.get(newReqKey);
                    
                        req.Manager_Senior_Mgr__c = newCustmSettingObj.Manager_Senior_Mgr__c;
                        req.Sales_Director__c = newCustmSettingObj.Sales_Director__c;
                        req.Sales_Planning_Manager__c = newCustmSettingObj.Sales_Planning_Manager__c;
                        req.Accounting__c = newCustmSettingObj.Accounting__c;
                        req.Operations__c = newCustmSettingObj.Operations__c;
                        req.Controller__c = newCustmSettingObj.Controller__c;
                        req.FP_A_Director__c = newCustmSettingObj.FP_A_Director__c;
                     }
                }
            }   
        }
    }
}