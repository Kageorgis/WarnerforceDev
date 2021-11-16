/**
*  @Author Cognizant
*  @name CRM_AutoTargetCreationAccountInsertBatch
*  @CreateDate 14 Sept 2016
*  @Description This batch class is responsible for automatic creation of  Account Plans and Account Plan Targets for Newly inserted Account 
*  if Country Plan And Country Plan Target exists else set the flag on Product.
*  @Version <1.0>
*  @reference Requirement no 369
*/
    
global class CRM_AutoTargetCreationAccountInsertBatch implements Database.Batchable<sObject>,Database.Stateful{
    /*List of the Accounts created Today*/
    public list<Account> listOfAccountsCreatedToday;
    /*Set of the Accounts failed for error handling*/
    public set<Id> failedAccounts = new set<Id>();
    
    /**
     * Constructor for the batch to assign query and initialization.
    */  
    global CRM_AutoTargetCreationAccountInsertBatch ()
    {
        listOfAccountsCreatedToday = new list<Account>();
    }
    
    /**
    * @description: - Method to fetch all the Account whose Pending_Account_Plan_Creation__c = TRUE
    * @name: getAllLatestAccounts
    * @return: List<Account>  
    */
    public List<Account> getAllLatestAccounts()
    {
        List<Account> listOfAccountsCreatedToday =
            new List<Account>(
                [
                    SELECT  Id ,Name ,Sales_Organization__c ,Price_Book__c ,Games_Digital__c ,
                            Video_Digital__c ,Games_Physical__c ,Video_Physical__c,External_Id__c 
                            FROM Account 
                            WHERE Pending_Account_Plan_Creation__c = TRUE 
                            AND External_Id__c !=NULL
                            AND Id NOT IN :failedAccounts LIMIT 10
                ]
            );
        return listOfAccountsCreatedToday; 
    }
    
    /**
    * @description: - Method to fetch all the products which has valid Pricebook Entry Period.
    * @name: getProductsWithPBEP
    * @param: List<Product2> productScopeList -List of products in the scope.
    * @return: List<Product2>  
    */
    @TestVisible
    private List<Product2> getProductsWithPBEP(List<Product2> productScopeList)
    {
        List<Product2> lstProducts = [SELECT Id,Name, Pending_Country_Plan_Creation__c,Type__c,Street_Date__c, Previous_Street_Date__c,CurrencyIsoCode,Exclusive_Customer__c, 
                            Street_Date_Has_Changed__c,Product_Type__c,Product_Format__c,NR_Product_Created__c, Local_Title__r.Country__r.currencyISOCode, 
                            Product_Price_Group__c,Local_Title__r.Country__r.Country_Code2__c,IsActive,NR_Version__c,RecordTypeId,external_Id__c, 
                                (SELECT Id, Product__c, Start_Date__c, Price_Book__c, //Suggested_Price__c, - US#895 - removed ref. of suggested price
                                         End_Date__c, List_Price__c, Account_Price__c,New_Release__c, CurrencyIsoCode 
                                         FROM Pricebook_Entry_Periods__r 
                                         WHERE Price_Book__c != null 
                                         ORDER BY Start_Date__c, CreatedDate,Product__c, Price_Book__c, CurrencyISOCode) 
                            FROM Product2 WHERE External_Id__c != null AND  Local_Title__r.Country__r.currencyISOCode != null AND Type__c != null AND ID IN : productScopeList];
        return lstProducts;
    } 
    
    
    /**
    *  @description: Method to retrieve the custom setting Auto Target Creation. 
    *  @name: fetchAutoTargetCustomSettingForRegion
    *  @return: Set<String>
    */
    public static Set<String> fetchAutoTargetCustomSettingForRegion(){
        //Map<String,Set<String>> mapOfNameRegionForAutoTargetLocal = new Map<String,Set<String>>();
        List<Auto_Target_Creation__c> autoCreationList = Auto_Target_Creation__c.getall().values();
        Set<String> setOfRegions = new Set<String>();
        for(Auto_Target_Creation__c autoCreateRecord : autoCreationList){ 
            if(autoCreateRecord.name!=null && autoCreateRecord.region__c!=null){
                setOfRegions.addAll(autoCreateRecord.region__c.split(','));
            }
        }
        system.debug('setOfRegions>>>>>>>>>>>>>>>>>'+setOfRegions);
        autoCreationList.clear();
        return setOfRegions;
    }  
    
    
    
    /**
    * Start method of batch process which will process Product related to the latest created account.
    */ 
    global Database.QueryLocator start(Database.BatchableContext BC){
        //  Get all the accounts created today
        listOfAccountsCreatedToday = getAllLatestAccounts();
        //US#945 Enable batch for Ireland start
        if(!listOfAccountsCreatedToday.isEmpty()){ 
        return Database.getQueryLocator([SELECT Id,type__c,Pending_Country_Plan_Creation__c,External_Id__c,
                                            Local_Title__r.Country__r.Country_Code2__c,CurrencyIsoCode
                                            FROM Product2
                                            WHERE 
                                            (((Type__c =: CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE OR Type__c =: CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE) AND Street_Date__c > TODAY) 
                                            OR (Type__c =: CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE OR Type__c =: CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE))  
                                            AND External_Id__c != null AND Type__c != null
                                            AND Pending_Country_Plan_Creation__c = false 
                                                AND Local_Title__r.Country__r.Country_Code2__c IN: fetchAutoTargetCustomSettingForRegion() 
                                            ]);
        }else{ 
            //If no accounts are to be process no need to execute the batch so the query will return 0 products.
            return Database.getQueryLocator([SELECT Id,type__c,Pending_Country_Plan_Creation__c,External_Id__c,
                                                Local_Title__r.Country__r.Country_Code2__c,CurrencyIsoCode
                                                FROM Product2
                                                WHERE id=null ]);
        }
        //US#945 Enable batch for Ireland ends
    }
    
    /**
    * Execute method of batch to process on NR Product records 
    * And checks if Country Plans does not exists the set the flag and if exists create Account Plan and Account Plan Targets
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope){       
        List<Product2> productScopeList =(List<Product2>)scope;
        Map<Id, Product2> mapProducts = new Map<Id, Product2>(getProductsWithPBEP(productScopeList)); 
        failedAccounts.addAll(CRM_AutoTargetCreationHelper.helperFunctionsToBeInvokedFromAccountBatch(listOfAccountsCreatedToday,mapProducts));  
    }
    
    /** 
    *  @description: - Method is used to update the Account after resetting the flag after the accounts and related products are processed 
    *  @name: updateAccountFlag
    *  @return: void
    */
    public void updateAccountFlag(){
        
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        List<Account> accList = new List<Account>();
        accList = listOfAccountsCreatedToday;
        //Set the flag for all the accounts created today and that are not failed
        for(Account acc : accList){
            if(!failedAccounts.contains(acc.Id)){
                acc.pending_account_plan_creation__c = false;
            }
        } 
        if(accList != null && accList.size() > 0){
             Database.SaveResult[] result = Database.Update(accList, false);
             Account acc = new Account();
             for(Integer i=0; i < result.size(); i++ ){
                acc = accList[i];
                if(!result[i].isSuccess()){
                    failedAccounts.add(acc.Id);
                    List<CRM_ErrorLogger.ErrorLog> errorLogInstance = CRM_AutoTargetCreationHelper.logAnException(result[i].getErrors(), result[i].getId(), 'Error found while updating Account Record : Account =' + string.valueOf(acc.id) );
                    listErrorLog.addAll(errorLogInstance);
                }
             }
         }
         CRM_ErrorLogger.logError(listErrorLog);  
    }   
     
    /**
    * Finish method of batch process.
    */ 
    global void finish(Database.BatchableContext BC){
        
        Decimal batchSize =  10;
        
        CRM_Batch_Size__c setting = CRM_Batch_Size__c.getInstance('Auto Target Account Batch');
        if(setting != null && setting.Batch_Size__c != null){
            batchSize = setting.Batch_Size__c;
        }
        
        //Update the Account after processing.
        System.debug('--failedAccounts -->'+failedAccounts);
        updateAccountFlag();
        if(!listOfAccountsCreatedToday.isempty()){
        //Check if there are accounts to be processed except those that have failed in the current batch execution.
            Integer accCount = [SELECT count() FROM Account WHERE Id NOT IN :failedAccounts AND Pending_Account_Plan_Creation__c = true
                                    AND (Games_Digital__c = TRUE OR Video_Digital__c = TRUE 
                                    OR Games_Physical__c = TRUE OR Video_Physical__c = TRUE) ];
            if(accCount > 0){
            //If such accounts exists then recursively call this batch for re-execution.
                CRM_AutoTargetCreationAccountInsertBatch exeBatch = new CRM_AutoTargetCreationAccountInsertBatch();
                exeBatch.failedAccounts = failedAccounts;
                Id batchJobId = Database.executeBatch(exeBatch, Integer.valueOf(batchSize));
            }else{
                BatchStatusNotification.sendBatchStatusMail(BC,'Auto Target Account Batch');  
            }
        }else{
            BatchStatusNotification.sendBatchStatusMail(BC,'Auto Target Account Batch');  
        }
    } 
}