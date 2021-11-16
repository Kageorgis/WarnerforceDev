/**
@Author: Accenture
@name: CRM_Deal_Overlap_Review_POS_DFI
@CreateDate: May 08, 2020
@Description:  Apex class to check for deal overlaps when launched from Review Deal Overlap Action (on Deal)/Flow.
@Version - 1.0
@reference: None
*/
global with sharing class CRM_Deal_Overlap_Review_POS_DFI{
    /** 
    *  Method to Delete previous Overlaps and generate new overlaps
    *  @name generateOverlaps
    *  @param List of Opportunity Records
    *  @return none
    *  @throws Exception
*/ 
    @InvocableMethod (Label = 'Generate Deal Overlap')
    public static void generateOverlaps(List<Opportunity> oppList){
        if(oppList[0].Deal_Overlap_Review_Completed__c){
            Opportunity opp = new Opportunity(Id = oppList[0].Id,
                                              Deal_Overlap_Review_Completed__c = false, 
                                              Deal_Overlap_Exists__c = false);
            Database.update(opp);
        }
        List<Deal_Overlap__c> dealOverlapList = [Select Id, Current_Deal__c FROM Deal_Overlap__c WHERE Current_Deal__c=:oppList[0].Id LIMIT 9999];
        
        if(!dealOverlapList.isEmpty()){
            Database.delete(dealOverlapList);
        }
        getDealOverlaps(new Set<Id>{oppList[0].Id});
    }
     /** 
    *  Method to generate new overlaps
    *  @name getDealOverlaps
    *  @param set of Opportunity Ids
    *  @return none
    *  @throws Exception
*/ 
    @future
    public static void getDealOverlaps(Set<Id> oppId){
        Map<String, OpportunityLineItem> productCodeDealProductMap = new Map<String, OpportunityLineItem>();
        List<OpportunityLineItem> dealProductList = new List<OpportunityLineItem>();
        List<Deal_Overlap__c> dealOverlapList = new List<Deal_Overlap__c>();
        Boolean dealOverlapResultsExceeds10k = false;
        String productCodes = '';
        String excludeDealStages = '';
        Set<String> excludeDealStagesSet = new Set<String>{CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED};
        //--W-017677 Added for JV project to fetch overlap for ADV/POS, DFI and Planning deal --Start--//
        String jvDealRecordTypes = '';
        Set<String> jvDealRecordTypeSet = new Set<String>{CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL, 
            CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DFI_DEAL,
            CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_PLANNING_DEAL};

        for(String recType : jvDealRecordTypeSet){
            jvDealRecordTypes = jvDealRecordTypes + '\'' + recType + '\',';
        }
        jvDealRecordTypes = jvDealRecordTypes.removeEnd(',');

        //--W-017677 Added for JV project to fetch overlap for ADV/POS, DFI and Planning deal --End--//

        for(OpportunityLineItem oli : [Select Id, OpportunityId, Opportunity.AccountId, Opportunity.RecordType.DeveloperName, 
                                       Start_Date__c, End_Date__c,Opportunity.Start_Date__c, 
                                       Opportunity.CloseDate, Reason__c,
                                       Product2Id, Product2.Name, Opportunity.StageName, 
                                       Product_Code__c, Opportunity.Deal_Code__c, Opportunity.Indirect_Account__c, 
                                       Opportunity.Sales_Organisation__c    //--W-017677 Added field for new planning deal recordtype check for JV project--//
                                       from OpportunityLineItem WHERE OpportunityId IN: oppId LIMIT 50000]){ //TJ - Removed the limit
                                           dealProductList.add(oli);
                                           productCodeDealProductMap.put(oli.Product_Code__c, oli);
                                       }
        
        Integer queryLimitCount = Limits.getLimitQueryRows() - Limits.getQueryRows();
        Opportunity opp = new Opportunity(Id=dealProductList[0].OpportunityId);
        String dealIndirectAccount = dealProductList[0].Opportunity.Indirect_Account__c == null?'':String.escapeSingleQuotes(dealProductList[0].Opportunity.Indirect_Account__c);
        String startDate = String.valueOf(dealProductList[0].Opportunity.Start_Date__c);
        String endDate = String.valueOf(dealProductList[0].Opportunity.CloseDate);
        //--W-017677 Added for JV project to store deal sales org and record type for Planning deal --Start--//
        String dealSalesOrg = dealProductList[0].Opportunity.Sales_Organisation__c;
        String dealRecordTypeDevName = dealProductList[0].Opportunity.RecordType.DeveloperName;
        Boolean isJVPlanningDeal = false;
        if(dealRecordTypeDevName == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_PLANNING_DEAL && 
                (dealSalesOrg == CRM_AppConstants.TERRITORY_SDS_US_CODE || dealSalesOrg == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)){
            isJVPlanningDeal = true;
        }
        system.debug('@@deal info-->'+isJVPlanningDeal+'--'+dealSalesOrg+'--'+dealRecordTypeDevName+'-->'+jvDealRecordTypes);
        //--W-017677 Added for JV project to store deal sales org and record type for Planning deal --Start--//
        
        for(String pCode : productCodeDealProductMap.keySet()){
            productCodes = productCodes + '\'' + pCode + '\',';
        }
        productCodes = productCodes.removeEnd(',');
        
        for(String stages : excludeDealStagesSet){
            excludeDealStages = excludeDealStages + '\'' + stages + '\',';
        }
        excludeDealStages = excludeDealStages.removeEnd(',');
        
        String query = 'Select Id, Opportunity.AccountId, Opportunity.RecordType.DeveloperName, Start_Date__c, OpportunityId, Product_Code__c, End_Date__c,';
        query += ' Status__c, Reason__c, Opportunity.Deal_Code__c, Opportunity.StageName, Opportunity.Name, Opportunity.Indirect_Account__c ';
        query += 'FROM OpportunityLineItem WHERE ';
        query += '(';
        //--W-017677 Added for JV project to fetch overlap for ADV/POS, DFI and Planning deal --Start--//
        if(isJVPlanningDeal){
            query += 'Opportunity.RecordType.DeveloperName IN (' + jvDealRecordTypes + ') AND ';
        }else{
            query += 'Opportunity.RecordType.DeveloperName = ' + '\'' + dealProductList[0].Opportunity.RecordType.DeveloperName + '\'' + ' AND ';
        }
        //--W-017677 Added for JV project to fetch overlap for ADV/POS, DFI and Planning deal --End--//
        query += 'Opportunity.AccountId = ' + '\'' + dealProductList[0].Opportunity.AccountId + '\'' + ' AND Product_Code__c IN (' + productCodes + ')';
        query += ' AND (Start_Date__c <=' + endDate + ' AND End_Date__c >=' + startDate + ') ';
        query += ' AND Opportunity.StageName NOT IN (' + excludeDealStages + ')';
        query += ' AND Status__c NOT IN (' + excludeDealStages + ')';
        query += ' AND Opportunity.Indirect_Account__c = ' + '\'' + dealIndirectAccount + '\') ORDER BY Opportunity.LastModifiedDate DESC LIMIT ' +queryLimitCount;
        system.debug('@@query-->'+query);
        try {
            for(OpportunityLineItem oli : Database.query(query)){
                //check for the same Product Code and get that particular Deal Product
                OpportunityLineItem dealProduct = productCodeDealProductMap.containsKey(oli.Product_Code__c)?productCodeDealProductMap.get(oli.Product_Code__c):null;                   
                //compare for the Start Date, End Date and Reason for the current Deal Product against that particular one for the current Deal
                
                //--W-017677 Added for JV project to insert deal overlap by excluding co-op reason for JV Planning deal --Start--//
                if(isJVPlanningDeal){
                    if(dealProduct!=null && oli.Start_Date__c <= dealProduct.End_Date__c && oli.End_Date__c >= dealProduct.Start_Date__c && !oppId.contains(oli.OpportunityId)){
                        if(dealOverlapList.size()<9999){
                            Deal_Overlap__c dOverlap = new Deal_Overlap__c();
                            dOverlap.Current_Deal__c = dealProductList[0].OpportunityId;
                            dOverlap.Current_Deal_Code__c = dealProductList[0].Opportunity.Deal_Code__c;
                            dOverlap.Current_Deal_Stage__c = dealProductList[0].Opportunity.StageName;
                            dOverlap.Current_Deal_Product_Id__c = dealProduct.Id;
                            dOverlap.Overlap_Deal_Id__c = oli.OpportunityId;
                            dOverlap.Overlap_Deal_Code__c = oli.Opportunity.Deal_Code__c;
                            dOverlap.Overlap_Deal_Name__c = oli.Opportunity.Name;
                            dOverlap.Overlap_Deal_Stage_Name__c = oli.Opportunity.StageName;
                            dOverlap.Overlap_Deal_Product_Start_Date__c = oli.Start_Date__c;
                            dOverlap.Overlap_Deal_Product_End_Date__c = oli.End_Date__c;
                            dOverlap.Product_Id__c = dealProduct.Product2Id;
                            dOverlap.Product_Name__c = dealProduct.Product2.Name;
                            dOverlap.Product_Code__c = dealProduct.Product_Code__c;
                            dOverlap.Start_Date__c = dealProduct.Start_Date__c;
                            dOverlap.End_Date__c = dealProduct.End_Date__c;
                            dealOverlapList.add(dOverlap);
                        }else{
                            dealOverlapResultsExceeds10k = true;
                            break;
                        }
                    }
                }else{      //--W-017677 Added for JV project to insert deal overlap by excluding co-op reason for JV Planning deal --End--//
                    if(dealProduct!=null && oli.Reason__c == dealProduct.Reason__c && oli.Start_Date__c <= dealProduct.End_Date__c && oli.End_Date__c >= dealProduct.Start_Date__c && !oppId.contains(oli.OpportunityId)){
                        if(dealOverlapList.size()<9999){
                            Deal_Overlap__c dOverlap = new Deal_Overlap__c();
                            dOverlap.Current_Deal__c = dealProductList[0].OpportunityId;
                            dOverlap.Current_Deal_Code__c = dealProductList[0].Opportunity.Deal_Code__c;
                            dOverlap.Current_Deal_Stage__c = dealProductList[0].Opportunity.StageName;
                            dOverlap.Current_Deal_Product_Id__c = dealProduct.Id;
                            dOverlap.Overlap_Deal_Id__c = oli.OpportunityId;
                            dOverlap.Overlap_Deal_Code__c = oli.Opportunity.Deal_Code__c;
                            dOverlap.Overlap_Deal_Name__c = oli.Opportunity.Name;
                            dOverlap.Overlap_Deal_Stage_Name__c = oli.Opportunity.StageName;
                            dOverlap.Overlap_Deal_Product_Start_Date__c = oli.Start_Date__c;
                            dOverlap.Overlap_Deal_Product_End_Date__c = oli.End_Date__c;
                            dOverlap.Product_Id__c = dealProduct.Product2Id;
                            dOverlap.Product_Name__c = dealProduct.Product2.Name;
                            dOverlap.Product_Code__c = dealProduct.Product_Code__c;
                            dOverlap.Start_Date__c = dealProduct.Start_Date__c;
                            dOverlap.End_Date__c = dealProduct.End_Date__c;
                            dOverlap.Reason__c = dealProduct.Reason__c;
                            dealOverlapList.add(dOverlap);
                        }else{
                            dealOverlapResultsExceeds10k = true;
                            break;
                        }
                    }
                }
            }
            opp.Deal_Overlap_Review_Completed__c = true;
            opp.Deal_Overlap_Last_Executed__c = DateTime.now();
            opp.Deal_Overlap_Results_10k_Plus__c = dealOverlapResultsExceeds10k;
            opp.Deal_Overlap_Records_Queried__c = Limits.getQueryRows();
            
            if(dealOverlapList.size()>0) {
                opp.Deal_Overlap_Exists__c = true;
                Database.insert(dealOverlapList);
            }else{
                opp.Deal_Overlap_Exists__c = false;
            }
            
            database.update(opp);
            
        } catch(Exception e) {
            System.debug('Exception occurred --> Class: CRM_Deal_Approval_POS_DFI --> Method: getDealOverlaps >> ' + e.getMessage());
        }
    }
}