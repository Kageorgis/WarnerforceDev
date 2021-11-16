/**
   @Author: Cognizant Team
   @name CRM_GenerateAssortementAccount 
   @CreateDate 8/6/2016
   @Description: To generate assortment account by picking account split template from assortment,and looping through every account on the split template.
   @Version 1.0
  */
public without sharing Class CRM_GenerateAssortementAccount{

    public static set<Id> targetSplitTemplateId = new set<Id>();
    public static set<Id> assortmentId = new set<Id>(); 
    public static map<Id, Bundle__c> mapAssortment = new map<Id, Bundle__c>(); //map to get the assortment in case the assortment account insertion/updation fails
    
    /***
    Purpose    : Prepare the Assortment Account
    Parameters : Trigger.OldMap , Trigger.NewMap
    Return     : Void
    ***/
    public static void prepareAssortmentAccount(Map<Id,Bundle__c> mapOldAssortments, Map<Id,Bundle__c> mapNewAssortments){
        Boolean createAssortmentAcc = false;
        mapAssortment  = mapNewAssortments;    
        Set<Id> setAssortmentIds = new Set<Id>();
        for(Bundle__c newAssortment : mapNewAssortments.values()){
            //in case of update
            if(mapOldAssortments != null && mapOldAssortments.containsKey(newAssortment.id)){
                Bundle__c oldAssortment = mapOldAssortments.get(newAssortment.Id);
                //check if the template id has been changed 
                if(oldAssortment.Account_Split_Template__c != newAssortment.Account_Split_Template__c){
                system.debug('inif ');
                    createAssortmentAcc = true;
                    targetSplitTemplateId.add(newAssortment.Account_Split_Template__c);
                    assortmentId.add(newAssortment.Id);            
                }
                //Req - 609 : System should automatically update all assortment products when changing the checkbox on assortment
                if(oldAssortment.Automatically_Add_Products__c != newAssortment.Automatically_Add_Products__c){
                    setAssortmentIds.add(newAssortment.Id);            
                }
            }else{
                system.debug('in else');
                createAssortmentAcc = true;
                if(newAssortment.Account_Split_Template__c != null){
                    targetSplitTemplateId.add(newAssortment.Account_Split_Template__c);
                    assortmentId.add(newAssortment.Id);           
                 }
            }           
        }
        //If any Template is changed
        if(createAssortmentAcc && targetSplitTemplateId !=null && !targetSplitTemplateId.isEmpty()){
        system.debug('inif '+createAssortmentAcc );
            createAssortmentAccount();
        }
        //Req - 609 : System should automatically update all assortment products when changing the checkbox on assortment
        if(setAssortmentIds != null && !setAssortmentIds.isEmpty()){
            updateAssortmentProducts(setAssortmentIds);
        }
    }
    
    /***
    Purpose    : Insert the Assortment Account
    Parameters : None
    Return     : Void
    ***/
    public static void createAssortmentAccount(){
        Map <Id, list<Account_Split__c>> mapTargetSplitAccountSplit =new map <Id, list<Account_Split__c>>();    //map of Template Id vs the list of Account Splits
        List<Target_Split_Template__c> lsttagetSplttemplate = new list<Target_Split_Template__c>();
        List<Assortment_Account__c> newAssortmentAccountList = new list<Assortment_Account__c>();
        List<Assortment_Account__c> assortmentAccountToBeDeletedList = new list<Assortment_Account__c>();
        List<Opportunity> finalCancelledOppList = new list<Opportunity>();
        Set<Id> newAccountSet = new set<Id>();
        Set<String> cancelledAssortmentAccUniqueKeySet = new set<String>();
        Map<String, Assortment_Account__c> mapAccountTSTVsAssortmentAcc = new map <String, Assortment_Account__c>();
    
    	//US:527 
    	Map<Id,Account_Split__c> mapAccountIdToAccountSplits = new Map<Id,Account_Split__c>();
    	 
        String strKey='';    //Key of map -- combination of Account id and Template id
        Assortment_Account__c assortmentAccnt;       
        list<Bundle__c> lstAssortment = new list<Bundle__c>();
        
        //prepare the map of Template Id vs the List of Account Splits
        for(Account_Split__c accountSplit :[select id, Account__c, Share__c, Target_Split_Template__c ,Target_Split_Template__r.Automatically_Split_to_Ship_To__c
                                            from Account_Split__c where Target_Split_Template__c IN:targetSplitTemplateId]){                                    
            if(mapTargetSplitAccountSplit.containsKey(accountSplit.Target_Split_Template__c)){
                mapTargetSplitAccountSplit.get(accountSplit.Target_Split_Template__c).add(accountSplit);
            }                           
            else{
                mapTargetSplitAccountSplit.put(AccountSplit.Target_Split_Template__c,new list<Account_Split__c>{accountSplit});
            }           
            
            //US:527 : Account split template change
            if(accountSplit.Target_Split_Template__r.Automatically_Split_to_Ship_To__c){
           		mapAccountIdToAccountSplits.put(accountSplit.Account__c,accountSplit);
        	}
        }
        
        
        //US:527 : Get All Shipt To Accounts related to Sold To 
        if(mapAccountIdToAccountSplits.size() > 0){
        	for(Account acc : [Select Id,Account_Split_Share__c,RecordTypeId,Sold_To_Customer__c From Account Where Sold_To_Customer__c IN :mapAccountIdToAccountSplits.keySet() AND Account_Split_Share__c != null]){
        		Account_Split__c soldToAccountSplit;
        		if(mapAccountIdToAccountSplits.containsKey(acc.Sold_To_Customer__c)){
        			soldToAccountSplit = mapAccountIdToAccountSplits.get(acc.Sold_To_Customer__c);
        			populateTargetSplitAccountSplitMap(acc,soldToAccountSplit,mapTargetSplitAccountSplit);
        		}
        	}
        }
        
        //get the list of Assortments and the Assortment Accounts
        lstAssortment = [Select Id,Account_Split_Template__c,(select Id,Account__c,Account__r.Id,Assortment__c,Assortment__r.Account_Split_Template__c,Share__c 
                         from Assortment_Accounts__r) from Bundle__c where Id IN: assortmentId];
       
        //prepare map Key ==> Account + TST id and Value ==> Assortment Account
        for(Bundle__c assortment : lstAssortment){
            
            for(Assortment_Account__c assortmentAccount : assortment.Assortment_Accounts__r){
                            
                strKey = String.valueOf(assortmentAccount.Account__c) + String.ValueOf(assortmentAccount.Assortment__r.Account_Split_Template__c);
                mapAccountTSTVsAssortmentAcc.put(strKey,assortmentAccount);
            }
        }
        system.debug(mapAccountTSTVsAssortmentAcc+'mapAccountTSTVsAssortmentAcc');
        //Iterating through each country plan
        for(Bundle__c assortment : lstAssortment ){            
            if(mapTargetSplitAccountSplit.containsKey(assortment.Account_Split_Template__c)){
                //iterate through the account splits
                system.debug(mapTargetSplitAccountSplit.get(assortment.Account_Split_Template__c)+'mapTargetSplitAccountSplit.get(assortment.Account_Split_Template__c)');
                for(Account_Split__c acctSplit : mapTargetSplitAccountSplit.get(assortment.Account_Split_Template__c)){
                    //If Assortment Account already exists
                    if(assortment.Assortment_Accounts__r != null && !assortment.Assortment_Accounts__r.isempty()){
                        //if account plan matches for same account and template id
                        if(mapAccountTSTVsAssortmentAcc.containsKey(String.valueOf(acctSplit.Account__c) + String.valueOf(assortment.Account_Split_Template__c))){                                
                            //update the assortmentAcc
                            assortmentAccnt = mapAccountTSTVsAssortmentAcc.get(String.valueOf(acctSplit.Account__c) + String.valueOf(assortment.Account_Split_Template__c));
                            assortmentAccnt.share__c = acctSplit.Share__c;                            
                        }
                        else{
                            //create new assortment account 
                            assortmentAccnt = new Assortment_Account__c();
                            assortmentAccnt.Assortment__c = assortment.Id;
                            assortmentAccnt.Account__c = acctSplit.Account__c;
                            assortmentAccnt.Share__c = acctSplit.Share__c;                            
                        }    
                    }else{
                        assortmentAccnt = new Assortment_Account__c();
                        assortmentAccnt.Assortment__c = assortment.Id;
                        assortmentAccnt.Account__c = acctSplit.Account__c;
                        assortmentAccnt.Share__c = acctSplit.Share__c;                        
                    }//End of assortment account already exists 
                    newAssortmentAccountList.add(assortmentAccnt);
                    newAccountSet.add(assortmentAccnt.Account__c);
                }//end of account split loop                    
            }//end of if
        }//end of assortment loop
        
        //Generate Delete list of assortment account and Deal list which are to be deleted - Start
        for(String key : mapAccountTSTVsAssortmentAcc.keySet()){
            if(!newAccountSet.contains(mapAccountTSTVsAssortmentAcc.get(key).Account__c)){
                assortmentAccountToBeDeletedList.add(mapAccountTSTVsAssortmentAcc.get(key));
                cancelledAssortmentAccUniqueKeySet.add(mapAccountTSTVsAssortmentAcc.get(key).Assortment__r.id+'-'+mapAccountTSTVsAssortmentAcc.get(key).Account__r.id);
            }
        }
        
        //Generate Delete list of assortment account and Deal list which are to be deleted - End
        
        system.debug(newAssortmentAccountList+'newAssortmentAccountList');
        if(!newAssortmentAccountList.isempty()){
            Database.UpsertResult[] resultAssAcc = Database.Upsert(newAssortmentAccountList,Assortment_Account__c.Id, false);
            for(Integer i=0; i < resultAssAcc.size(); i++ ){
                if(!resultAssAcc[i].isSuccess()){
                    Database.Error error = resultAssAcc.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();  
                    mapAssortment.get(newAssortmentAccountList[i].Assortment__c).addError('Update/Insert failed on Assortment Account : '+ failedDML);  
                }
            }  
        }
        
        system.debug(assortmentAccountToBeDeletedList+'assortmentAccountToBeDeletedList');
        if(!assortmentAccountToBeDeletedList.isempty()){
            
            List<Opportunity> cancelledOppList = [Select Id,StageName,Bundle__c,AccountId from Opportunity where UniquePublishkey__c  in :cancelledAssortmentAccUniqueKeySet];
            for(Opportunity opp : cancelledOppList){
                    opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED;
            }
            system.debug(cancelledOppList+'cancelledOppList');
            if(!cancelledOppList.isempty()){
            Database.UpsertResult[] resultOpp = Database.Upsert(cancelledOppList,Opportunity.Id, false);
                for(Integer i=0; i < resultOpp.size(); i++ ){
                    if(!resultOpp[i].isSuccess()){
                        Database.Error error = resultOpp.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();  
                        mapAssortment.get(cancelledOppList[i].Bundle__c).addError('Cancelled failed of Assortment Account : '+ failedDML);  
                    }
                }
            }
            Database.DeleteResult[] result = Database.delete(assortmentAccountToBeDeletedList, false);
            for(Integer i=0; i < result.size(); i++ ){
                if(!result[i].isSuccess()){
                    Database.Error error = result.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();  
                    mapAssortment.get(assortmentAccountToBeDeletedList[i].Assortment__c).addError('Delete failed of Assortment Account : '+ failedDML);  
                }
            }
            
            
        }
    }//end of method      */ 
    /***
    Purpose    : Updates the Assortment Products
    Parameters : None
    Return     : Void
    ***/
    public static void updateAssortmentProducts(Set<Id> setAssortmentIds){
        List<Bundle_Product__c> listAssortmentProducts = new List<Bundle_Product__c>();

        try {
            // get the list of associated assortment products
            for(Bundle_Product__c assortmentProduct : [SELECT Id, Product__c, Bundle__c,Bundle__r.Automatically_Add_Products__c,
                                                            Automatically_Add_Product__c
                                                            FROM Bundle_Product__c
                                                            WHERE Bundle__c IN: setAssortmentIds]){
                system.debug('assortmentProduct-->'+assortmentProduct);
                if(assortmentProduct.Bundle__r.Automatically_Add_Products__c){
                    assortmentProduct.Automatically_Add_Product__c = true;
                }else{
                    assortmentProduct.Automatically_Add_Product__c = false;
                }
                listAssortmentProducts.add(assortmentProduct);
            }
            if (!listAssortmentProducts.isEmpty()) {
                update listAssortmentProducts;
            }
        } catch(Exception  e) {
            logAnException(e, null);
        }
    }
    /*
    *  This method will take the exception occured as an input and forward it to the common utility class. 
    *  @name: logAnException
    *  @param: Exception ex
    *  @return: void 
    */
    public static void logAnException(Exception ex, Id recordId){
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        if (recordId != null)
            errorLogInstance.recordId = recordId;
        // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
        errorLogInstance.functionalModule = 'Update Assortment Product';
        errorLogInstance.lineNumber = String.valueof(ex.getLineNumber());
        errorLogInstance.errorMessage = ex.getMessage();
        errorLogInstance.stackTrace = ex.getStackTraceString();

        // Call the logError method which will insert all errors into CRM_Error_Log__c object
        CRM_ErrorLogger.logError(errorLogInstance);     
    }
    
    
     /**
     * @US:527
     * @Description - Method to populate mapTargetSplitAccountSplit Map 
     * @name populateTargetSplitAccountSplitMap 
     * @param acc - Account instance
     * @param acctSplit - Account_Split__c instance
     * @return void
     */
    private static void populateTargetSplitAccountSplitMap(Account acc,Account_Split__c soldToAccSplit,Map <Id, list<Account_Split__c>> mapTargetSplitAccountSplit){
    	
    	Account_Split__c shipToAccSplit = createAccountSplit(acc,soldToAccSplit);
    	
    	if (mapTargetSplitAccountSplit.containsKey(soldToAccSplit.Target_Split_Template__c)){
            mapTargetSplitAccountSplit.get(soldToAccSplit.Target_Split_Template__c).add(shipToAccSplit);
        } else{
            mapTargetSplitAccountSplit.put(soldToAccSplit.Target_Split_Template__c,new List<Account_Split__c>{shipToAccSplit});
        }
    }
    
    /**
     * @US:527
     * @Description - Method to Create Account Split Instance
     * @name createAccountSplit 
     * @param acc - Account instance
     * @param acctSplit - Account_Split__c instance
     * @return Account_Split__c
     */
    private static Account_Split__c createAccountSplit(Account acc,Account_Split__c soldToAccSplit){
    	Account_Split__c accSplit = new Account_Split__c();
    	accSplit.share__c = (acc.Account_Split_Share__c*(soldToAccSplit.Share__c != null ? soldToAccSplit.Share__c : 0))/100;
	    accSplit.Account__c = acc.Id;
	    return accSplit;
    }
}