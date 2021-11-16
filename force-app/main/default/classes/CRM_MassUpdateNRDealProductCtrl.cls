/**
   @Author Cognizant
   @name PageNRProductCtrl
   @CreateDate 25 Jan 2016
   @Description This class is used to upload (update/insert) the deal products.
   @Version <1.0>
   @reference Requirement no 83
*/
global with sharing class CRM_MassUpdateNRDealProductCtrl{

    public Opportunity opp;
    public static ApexPages.StandardController theController;
    public static Integer totalFailedRecords;
     //US#660
    public String accountOwners{get; set;} 
    public static String OWNERGAMES ='Games', OWNERVIDEO ='Video', OWNERBOTH ='Both';
    public String handsontableversion{get; set;} 
    
    /**
    *  @Description - constructor
    *  @name  CRM_UploadDealProductsController 
    */
    global CRM_MassUpdateNRDealProductCtrl(ApexPages.StandardController stdController) {
        theController = stdController;
   		//US#660 starts
        Id profileId = userinfo.getProfileId();
        Id userId = userinfo.getUserId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        //Get Profile,sales org and digital org details to fetch the data for Accounts
        String ProfilePermissions  = CRM_Functional_Permissions__c.getInstance().NRMassUpdateTerritoryCode__c;
        List<String> setSalesOrgs = getCustomSettingRecords('Sales_Orgs__c',ProfilePermissions);
        List<String> setCountryCodes = getCustomSettingRecords('Product_Country_Code__c',ProfilePermissions);
        List<String> setdigitalCountryCodes = getCustomSettingRecords('Digital_Country_Code__c',ProfilePermissions);
        //Get all the valid accounts
        List<Account> lstOfAccounts =[SELECT OWNERId,OWNER.Name,Owner_Games__c,Owner_Games__r.name FROM Account WHERE Sales_Organization__c IN: setSalesOrgs OR Digital_Country_Code__c IN: setdigitalCountryCodes];
        List<CRM_DataObjects.PicklistOption> options = new List<CRM_DataObjects.PicklistOption>();
        List<String> picklistValues = new List<String>(); 
        Set<Id> ownerIdsSet =new  Set<Id>();
        Map<Id,String> mapOwners = new Map<Id,String>();
        
        //Add the filter with first value as My Accounts 
        options.add(new CRM_DataObjects.PicklistOption('myAccount',Label.CRM_My_Account)); 
        picklistValues.add(Label.CRM_My_Account);
        //By Default in Account Owner ,keep My Account being selected
        options[0].selected =true;
        //Add the filter with first value as All Accounts 
        options.add(new CRM_DataObjects.PicklistOption('allAccount',Label.CRM_All_Accounts));
        picklistValues.add(Label.CRM_All_Accounts); 
        //Add Owner name with Video/Games /Video & Games 
        for(Account acc :lstOfAccounts){
            if(acc.Ownerid !=null){
                if(!mapOwners.containsKey(acc.Ownerid) && acc.Ownerid != userId){
                    mapOwners.put(acc.Ownerid,OWNERVIDEO);
                }else{
                    mapOwners.put(acc.Ownerid,OWNERVIDEO);
                }
            }
            
            if(acc.Owner_Games__c !=null){
                if(!mapOwners.containsKey(acc.Owner_Games__c) && acc.Owner_Games__c != userId){
                    mapOwners.put(acc.Owner_Games__c,OWNERGAMES);
                }else if(mapOwners.containsKey(acc.Owner_Games__c) && acc.Owner_Games__c != userId){
                    mapOwners.put(acc.Owner_Games__c,OWNERBOTH);
                }
            }
        }
        
        for(Account acc :lstOfAccounts){
           
            if(acc.OWNER.Name!=Null && mapOwners.containsKey(acc.Ownerid) ){
                if(!ownerIdsSet.contains(acc.Ownerid) && acc.Ownerid != userId){
                    ownerIdsSet.add(acc.Ownerid);
                    accountOwnerName(mapOwners.get(acc.Ownerid),acc.OwnerId,acc.Owner.Name,picklistValues,options); 
                }else if(!ownerIdsSet.contains(acc.Owner_Games__c) && acc.Owner_Games__c != userId){
                    ownerIdsSet.add(acc.Owner_Games__c);
                    accountOwnerName(mapOwners.get(acc.Owner_Games__c),acc.Owner_Games__c,acc.Owner_Games__r.Name,picklistValues,options); 
                }
            }
        } 
        
        PicklistVal pickWrap = new PicklistVal(picklistValues,options);
        accountOwners = JSON.serialize(pickWrap);
        //US#660 Add Account Owner filter to tab end
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().Handsontable_Pro_Version__c;
    }
    
     //US : 989
    public string getHandsonTable_Pro_Licencekey (){
        return CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c != null ? CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c : '';
    } 
    
     //US : 989
    public boolean getUserLocaleForCSV(){
        String availableLocales =CRM_Default_Configuration__c.getOrgDefaults().User_Locale__c != null ? CRM_Default_Configuration__c.getOrgDefaults().User_Locale__c : '';
        List<String> lstAlpha = availableLocales.split(',');
        Set<String> setLocales = new Set<String>();
        setLocales.addall(lstAlpha);
        if(setLocales.contains(getUserLocale() )){
            return true;
        }else{
            return false;
        }
    } 
    
    
     /**
     *  US#660 Add Account Owner filter to tab .Method to append Account name with Video/Games /Video & Games 
     *  @name accountOwnerName
     *  @param String isGames ,Id ownerId, String accName, List<String> picklistValues, List<CRM_DataObjects.PicklistOption> options
     *  @throws None
     */
    public void accountOwnerName(String isGames ,Id ownerId, String accName, List<String> picklistValues, List<CRM_DataObjects.PicklistOption> options){
        
        if(isGames == OWNERBOTH){
            options.add(new CRM_DataObjects.PicklistOption(ownerId+'',accName+' ('+Label.CRM_Games_Video+')'));
            picklistValues.add(accName+' ('+Label.CRM_Games_Video+')');
        }else if(isGames == OWNERVIDEO){
            options.add(new CRM_DataObjects.PicklistOption(ownerId+'',accName+' ('+Label.CRM_Video+')'));
            picklistValues.add(accName+' ('+Label.CRM_Video+')');
        }else if(isGames == OWNERGAMES){
            options.add(new CRM_DataObjects.PicklistOption(ownerId+'',accName+' ('+Label.CRM_Games+')'));
            picklistValues.add(accName+' ('+Label.CRM_Games+')');
        }
    }
    
    
    /**
    *  @Description - wrapper class
    *  @name  OpportunityLineItemWrapper 
    */
    global class OpportunityLineItemWrapper {
        public OpportunityLineItem lineItemRecord;
        public String validation='';
        public Id existingId;
        public boolean isRowModified=false;
        //US#630
        public Boolean isCoopClosed = false;
        public boolean isCommitted = false;
        //public boolean isRowRemoved=false;
        public boolean previouslySelectedForRemoval=false;
        public Integer rowIndex;
        // totalFailedRecords: Number of failed records during (insert/update/delete) operations to be displayed on VF page
        // totalFailedRecords will be taken from first wrapper record always by VF javascript 
        public Integer numFailedRecords;
         //US#598
        global Boolean isUnTargetedDealProd =false;
         //US : 994 
        public string recrodStatus='';
         
    }

    /**
     * Method to get logged in uSer Locale
     */
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        //System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        //system.debug('Profile Name -->'+profileName);
        //System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale);
        return currentUserLocale;
    }
    
     global String getUserLocaleLowerCase() {
        String currentUserLocale = UserInfo.getLocale();
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale.toLowerCase());
        return currentUserLocale.toLowerCase();
    }

    /**
     * Method to get logged in uSer Locale Language code
     */
    global String getUserLocaleLanguage() {
        return UserInfo.getLocale().split('_')[0];
    }
    
    /* 
    *  Defect#4283 : name getUserDateFormat: e.g. M/d/yyyy
    *  param none
    *  return string
    *  throw none
    */  
    global String getUserDateFormat(){
        return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
    }
    
    // Defect#4123 - Method to check if user is german    
    global Boolean getisgerman() {
        system.debug('CRM_Functional_Permissions__c.getInstance().Show_Additional_Fields_On_MassUdpate__c '+CRM_Functional_Permissions__c.getInstance().Show_Additional_Fields_On_MassUdpate__c);
        if(CRM_Functional_Permissions__c.getInstance().Show_Additional_Fields_On_MassUdpate__c){
            return true;
        }       
        else{
            return false;
        }
    }  
    
    /**
     *  Method to fetch the Deal Product from DealId  
     *  @name getOpportunityLineItems
     *  @param Id opportunityId
     *  @return CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper[]
     *  @throws None
     */
    @RemoteAction
     global static list<OpportunityLineItemWrapper> getOpportunityLineItems(CRM_DataObjects.SearchFilters filters,string searchBy,String productType,FilterWrapper filteredOwner) { 
        // Construct a list of Opportunity Line Items
        List<OpportunityLineItemWrapper> returnWrapperList = new List<OpportunityLineItemWrapper>();
        //Defect#4241 Null search text criteria included
        Id profileId = userinfo.getProfileId();
        //US#660
        Id userId =userInfo.getUserId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        String ProfilePermissions  = CRM_Functional_Permissions__c.getInstance().NRMassUpdateTerritoryCode__c;
        system.debug('ProfilePermissions  ::'+ProfilePermissions  );
        List<String> setSalesOrgs = getCustomSettingRecords('Sales_Orgs__c',ProfilePermissions);
        List<String> setCountryCodes = getCustomSettingRecords('Product_Country_Code__c',ProfilePermissions);
        List<String> setdigitalCountryCodes = getCustomSettingRecords('Digital_Country_Code__c',ProfilePermissions);
        system.debug('Check :::::: '+setSalesOrgs+'---------'+setCountryCodes+'----------'+setdigitalCountryCodes);
        Boolean quickSearchTextEntered = (filters.text != null && filters.text.trim() != '') ? true : false;
        
        //US#660 Add Account Owner filter to tab start
        List<Account> lstOfAccounts =[SELECT OWNERId,OWNER.Name,Owner_Games__c,Owner_Games__r.name FROM Account WHERE OWNERId!=null AND (Sales_Organization__c IN: setSalesOrgs OR Digital_Country_Code__c IN: setdigitalCountryCodes)];
        Set<Id> setOwnerIds =new Set<Id>();
        for(Account accRec:lstOfAccounts ){
            setOwnerIds.add(accRec.OWNERId);
            if(accRec.Owner_Games__c!=null){
                setOwnerIds.add(accRec.Owner_Games__c);
            }  
        }
        //US#660 Add Account Owner filter to tab end
        
        // Find what products are in the Deal
        try{
                Date currentDate = system.today();
               /* date firstDate = currentDate.toStartOfMonth();
                Date dtThreeMthsLater = currentDate +92;
                string FirstdateOfMonth = DateTime.newInstance(firstDate.year(),firstDate.month(),firstDate.day()).format('yyyy-MM-dd');
                string threemonthslater = DateTime.newInstance(dtThreeMthsLater.year(),dtThreeMthsLater.month(),dtThreeMthsLater.day()).format('yyyy-MM-dd');*/
                string FirstdateOfMonth = DateTime.newInstance(Date.Today().toStartOfMonth(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                string threemonthslater = DateTime.newInstance(Date.Today().toStartOfMonth().addMonths(3), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');

                Set<Id> recordIds; //Defect#4123 - added account billing street,city and product format in query
                string query = 'SELECT Name,Opportunity.Account.OwnerId,Opportunity.Account.Owner_Games__c,Promoted_Price__c,Account_Price__c,Material_Street_Date__c,Opportunity.RecordTypeId,Opportunity.Account.BillingStreet,Opportunity.Account.BillingCity,Product2.Product_Format__c,ListPrice__c,'+
                         ' Opportunity.Account.Name,Initial_Quantity__c,product2.Street_Date__c,Opportunity.Account_Number__c,Product2.External_Id__c,Opportunity.StageName,Opportunity.Sales_Organisation__c,'+
                         ' product2.ProductCode,Target_Quantity__c,product2.Universal_Picture_Code__c,Opportunity.AccountId,Reason__c,Co_op_Requested_Amount__c,Opportunity.Co_op_Closed__c,Actual_Revenue__c,POS_Revenue__c,Total_Quantity__c,'+ //US#598
                         ' Replen_Quantity__c,Actual_Quantity__c,Product2.Name,ProductCode,Opportunity.Deal_Code__c,toLabel(Format__c)'+
                         ' FROM OpportunityLineItem where NR__c = true and Opportunity.RecordtypeId != \''+CRM_RecordTypeUtil.RT_DEAL_ACTUALS+'\' and Opportunity.RecordtypeId != \''+CRM_RecordTypeUtil.RT_DEAL_POS_ACTUALS+'\'';
                /*DEF#4319 Added Condition Deal !=Actuals*/            
               if(productType !=null && productType=='Physical'){
                   query += ' AND Product2.RecordtypeId =\''+CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT+'\'';
               }
               if(productType !=null && productType=='Digital'){
                   query += ' AND Product2.RecordtypeId =\''+CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL+'\'';
               }   
               //US#660 Add Account Owner filter to tab start
               if(filteredOwner !=null ){
                  
                    Set<String> setAccOwner = getPicklistValueSet(filteredOwner.accOwnerEntered);
                     system.debug('setAccOwner----------'+setAccOwner);
                    List<String> accOwner =new List<String>();
                    accOwner.addAll(setAccOwner);
                    if(!accOwner.isEmpty()){
                        if(accOwner[0] == 'myAccount') {
                            query += ' AND (Opportunity.Account.OwnerId =: userId OR Opportunity.Account.Owner_Games__c =: userId )'; 
                        }else if(accOwner[0] == 'allAccount') {
                            query += ' AND (Opportunity.Account.OwnerId IN: setOwnerIds OR Opportunity.Account.Owner_Games__c IN: setOwnerIds )'; 
                        }else{ 
                            query += ' AND (Opportunity.Account.OwnerId IN: accOwner OR Opportunity.Account.Owner_Games__c IN: accOwner )'; 
                        }
                    }
               }
               //US#660 Add Account Owner filter to tab end 
               
               if(filters.streetDateFrom != null){
                   system.debug('filters.streetDateFrom : '+filters.streetDateFrom);
                   String strDateFrom = DateTime.newInstance(filters.streetDateFrom.year(),filters.streetDateFrom.month(),filters.streetDateFrom.day()).format('yyyy-MM-dd');
                   query += ' AND product2.Street_Date__c >= '+strDateFrom+'';
               } 
               if(filters.streetDateTo != null){
                   system.debug('filters.streetDateTo : '+filters.streetDateTo);
                   String strDateTo = DateTime.newInstance(filters.streetDateTo.year(),filters.streetDateTo.month(),filters.streetDateTo.day()).format('yyyy-MM-dd');
                    query += ' AND product2.Street_Date__c <= '+strDateTo+'';
               }
               else if(filters.streetDateFrom == null && filters.streetDateFrom == null){
                 query += ' AND product2.Street_Date__c >= '+FirstdateOfMonth+' AND product2.Street_Date__c <= '+threemonthslater+'';    
               }
               if(searchBy == 'Account'){
                    if(quickSearchTextEntered){ 
                      recordIds = getAccountOrProductIds(filters.text,searchBy,setSalesOrgs,setCountryCodes,setdigitalCountryCodes);
                      query += ' AND Opportunity.AccountId IN :recordIds';
                    }else{  //Defect#4241 Null search text criteria included
                      query += ' AND (Opportunity.Account.Sales_Organization__c IN: setSalesOrgs OR Opportunity.Account.Digital_Country_Code__c IN: setdigitalCountryCodes)';
                    }
                    query += ' order by Opportunity.Account.Name asc';
                    //system.debug('record Ids -->'+recordIds.size());
                    //query += ' AND (Opportunity.Account.Name LIKE '+'\'%'+filters.text+'%\' OR Opportunity.Account.AccountNumber LIKE '+'\'%'+filters.text+'%\') order by Opportunity.Account.Name asc';//AND product2.Street_Date__c IN 
               }
               if(searchBy == 'Product'){
                    if(quickSearchTextEntered){
                      recordIds = getAccountOrProductIds(filters.text,searchBy,setSalesOrgs,setCountryCodes,setdigitalCountryCodes);
                      query += ' AND Product2Id IN :recordIds';
                    }else{  //Defect#4241 Null search text criteria included
                      query += ' AND (Product2.SAP_Sales_Org__c IN: setSalesOrgs OR Product2.Country_Code__c IN: setdigitalCountryCodes)';
                    }
                    query += ' order by Opportunity.Account.Name asc';
                    //system.debug('record Ids -->'+recordIds.size());
                    //query += ' (Product2.Name LIKE '+'\'%'+filters.text+'%\' OR ProductCode LIKE '+'\'%'+filters.text+'%\' OR product2.Universal_Picture_Code__c LIKE '+'\'%'+filters.text+'%\' ) order by Product2.Name asc';  
               }
       
               query += ' LIMIT 10000';
               system.debug('query formed -->'+query);
               List<OpportunityLineItem> listLineItems = new List<OpportunityLineItem>();
               listLineItems = Database.query(query);
            system.debug('listLineItems : '+listLineItems.size());
               for(OpportunityLineItem lineItem : listLineItems) {
                   OpportunityLineItemWrapper lineItemWrapper = new OpportunityLineItemWrapper();
                   lineItemWrapper.existingId = lineItem.id;
                   lineItemWrapper.lineItemRecord = lineItem;
                   lineItemWrapper.recrodStatus = ''; //US : 994
                   //lineItemWrapper.validation = '';
                   if(lineItem.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED || lineItem.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_AWAITING_APPROVAL){
                        lineItemWrapper.isCommitted = true;
                   }
                   if(lineItem.Opportunity.Co_op_Closed__c == true){ //US#630
                    lineItemWrapper.isCoopClosed = true;
                   }
                   //US#598 starts
                    if((lineItem.Actual_Revenue__c == 0 || lineItem.Actual_Revenue__c == NULL) &&
                         (lineItem.POS_Revenue__c == 0 || lineItem.POS_Revenue__c == NULL) && 
                         (lineItem.Target_Quantity__c == 0 || lineItem.Target_Quantity__c == NULL) &&
                         (lineItem.Total_Quantity__c == 0 || lineItem.Total_Quantity__c == NULL)){
                           lineItemWrapper.isUnTargetedDealProd = true; 
                    }
                    //US#598 end
                   returnWrapperList.add(lineItemWrapper);
               }
        }
        catch(Exception e) {
                logException(e);
                throw new CRM_ProductPricingHandler.CRM_Exception(e.getMessage());
        }
        return returnWrapperList;
    }
    
    public static void logException(Exception e){
                    CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                    //errorLog.recordId = oppId;
                    // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
                    errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DEALS;
                    errorLog.lineNumber = String.valueOf(e.getLineNumber());
                    errorLog.errorMessage = e.getMessage();
                    errorLog.stackTrace = e.getStackTraceString();
                    
                    // Call the logError method which will insert all errors into CRM_Error_Log__c object
                    CRM_ErrorLogger.logError(errorLog);
    }
    /*
     *  Method to get productIds or AccountIds containing the search text.  
     *  @name getAccountOrProductIds
     *  @param search text, and search criteria(by product or by account)
     *  @return set of Ids containing search text.
     *  @throws None
    */
    //Defect#4241 Null search text criteria included 
    public static set<Id> getAccountOrProductIds(string quickSearchText,string searchBy,List<String> setSalesOrgs,List<String> setCountryCodes,List<String> setdigitalCountryCodes){
   
        Set<Id> setMtachingRecordIds = new Set<Id>();
        String QUERY_PRODUCT;
        String sosl_search;
        
        if(quickSearchText != null && quickSearchText.trim() != ''){
            quickSearchText = String.escapeSingleQuotes(quickSearchText);
            
            sosl_search = quickSearchText;
            sosl_search = sosl_search.replace(':', '\\:');
            sosl_search = sosl_search.replace('-', '\\-');
            sosl_search = sosl_search.replace('+', '\\+');
            sosl_search = sosl_search.replace('&', '\\&');
            sosl_search = sosl_search.replace('!', '\\!');
            sosl_search = sosl_search.replace('^', '\\^');
            //String QUERY_PRODUCT;
            system.debug('search text value --> '+sosl_search);
            system.debug('Check :::::: '+setSalesOrgs+'---------'+setCountryCodes+'----------'+setdigitalCountryCodes);
          if(searchBy =='Account'){
              system.debug('by account');
              QUERY_PRODUCT = 'FIND {'+sosl_search+'} IN ALL FIELDS RETURNING Account(Id,AccountNumber,Name,Sales_Organization__c,Digital_Country_Code__c WHERE Sales_Organization__c IN: setSalesOrgs OR Digital_Country_Code__c IN: setdigitalCountryCodes)';
          }
          if(searchBy =='Product'){
              system.debug('by Product');
              QUERY_PRODUCT = 'FIND {'+sosl_search+'} IN ALL FIELDS RETURNING Product2(Id,ProductCode,Universal_Picture_Code__c,Name,Country_Code__c,SAP_Sales_Org__c WHERE SAP_Sales_Org__c IN: setSalesOrgs OR Country_Code__c IN: setCountryCodes)';
          }
          
          system.debug('Query formed in SOSL -->'+QUERY_PRODUCT);
            List<List<SObject>> searchResult = Search.query(QUERY_PRODUCT);
            
            for(Sobject[] listObj : searchResult) {
                for(sobject sobj : listObj) {
                   if(searchBy =='Product'){    
                       //system.debug('By Product if');
                       string productCode = (string)sobj.get('ProductCode') !=null? (string)sobj.get('ProductCode') :'';
                       string UniversalCode = (string)sobj.get('Universal_Picture_Code__c') !=null ? (string)sobj.get('Universal_Picture_Code__c') : '';
                       string productName = (string)sobj.get('Name') !=null ? (string)sobj.get('Name') : '';

                       if((productCode.containsIgnoreCase(quickSearchText) || UniversalCode.containsIgnoreCase(quickSearchText) || productName.containsIgnoreCase(quickSearchText))){
                         setMtachingRecordIds.add((Id)sobj.get('Id'));
                         //system.debug('not matching record ids -->'+sobj.get('Id'));
                       }
                    } 
                    if(searchBy =='Account'){ 
                        //system.debug('By Account if');
                        string AccountNumber = (string)sobj.get('AccountNumber') !=null ? (string)sobj.get('AccountNumber') :'';
                        string Name = (string)sobj.get('Name') !=null ? (string)sobj.get('Name') : '';
               
        
                        if((AccountNumber.containsIgnoreCase(quickSearchText) || Name.containsIgnoreCase(quickSearchText))){
                            setMtachingRecordIds.add((Id)sobj.get('Id'));
                        }
                    }           
                }
            }
        }
        system.debug('setMtachingRecordIds : '+setMtachingRecordIds.size());
        return setMtachingRecordIds;
    }
    
  /**
   *  Method to get Custom Setting Records
   *  @name getCustomSettingRecords
   *  @param fieldAPIName, ProfilePermissions 
   *  @return List<String> - Custom setting records list
   *  @throws None
   *  Defect#4241 Null search text criteria included
   */
    private static List<String> getCustomSettingRecords(String fieldAPIName, String ProfilePermissions){
      
        List<String> lstCSRecords = new List<String>();
        String csRecord;
        if(fieldAPIName == 'Sales_Orgs__c'){
            csRecord  = CRM_Profile_Based_Country_Identification__c.getInstance(ProfilePermissions).Sales_Orgs__c;
        }else if(fieldAPIName == 'Product_Country_Code__c'){
            csRecord  = CRM_Profile_Based_Country_Identification__c.getInstance(ProfilePermissions).Product_Country_Code__c;
        }else if(fieldAPIName == 'Digital_Country_Code__c'){
            csRecord  = CRM_Profile_Based_Country_Identification__c.getInstance(ProfilePermissions).Digital_Country_Code__c;
        }
        if(csRecord != null){                              
            lstCSRecords = csRecord.split(',');            
            system.debug('lstCSRecords -->'+lstCSRecords);
        }
        return lstCSRecords;
    }
    
    /**
     *  Method to update success/failure result on the record after dml-insert/update  
     *  @name updateDMLResult
     *  @param results, actual list on which dml is performed and string
     *  @return None
     *  @throws None
     */
     
    global static void updateDMLResult(list<Database.SaveResult> results, list<OpportunityLineItemWrapper> dmlList,String successResultString) {
            // set of Ids of inserted/updated records
            set<Id> recordIdSet = new set<Id>();
            system.debug('===============dmlList================'+dmlList);
            
            for(Integer i=0;i<results.size();i++){
                    OpportunityLineItemWrapper lineItemWrapper = dmlList.get(i);
                    //lineItemWrapper.lineItemRecord = dmlList.get(i);
                    lineItemWrapper.isRowModified =false;    
                       
                    if (results.get(i).isSuccess()){
                        lineItemWrapper.existingId = results.get(i).getId();
                        lineItemWrapper.validation = successResultString;
                        lineItemWrapper.recrodStatus = CRM_AppConstants.SUCCESS_MSG; //US : 994
                        
                        recordIdSet.add(lineItemWrapper.existingId);
                    }
                    else if (!results.get(i).isSuccess()){
                        // DML operation failed
                        Database.Error error = results.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        lineItemWrapper.validation = failedDML;
                        lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                        totalFailedRecords++;
                        
                        system.debug('Failed ID'+dmlList.get(i));
                        lineItemWrapper.existingId = dmlList.get(i).lineItemRecord.Id;
                        
                       /* DEF#4855 US#989 994 if(lineItemWrapper.existingId!=null) {
                            recordIdSet.add(lineItemWrapper.existingId);
                        }*/
                    }
                    //returnWrapperList.add(lineItemWrapper);
            }
            
            // fetch all modified lineItems from database with populated formula fields
            //ER-002938
            map<Id,OpportunityLineItem> lineItems = 
            new map<Id,OpportunityLineItem>([SELECT Name,Opportunity.Account.Name, 
                                             Initial_Quantity__c,Product2.Street_Date__c,Opportunity.AccountId,Opportunity.Account_Number__c,Opportunity.Account.BillingStreet,
                                             Opportunity.Account.BillingCity,Product2.Product_Format__c,ListPrice__c,
                                             product2.ProductCode,Replen_Quantity__c,POS_Quantity__c,Product2.External_Id__c,Actual_Quantity__c,
                                             Product2Id, Product2.Name, Target_Quantity__c,toLabel(Format__c),
                                             OpportunityId,ProductCode,Promoted_Price__c,Co_op_Requested_Amount__c,Reason__c,Opportunity.Deal_Code__c,
                                             Opportunity.StageName,Opportunity.Co_op_Closed__c,Account_Price__c,P_L_Quantity__c,Material_Street_Date__c
                                             FROM OpportunityLineItem
                                             WHERE Id IN: recordIdSet
                                             ORDER BY Product2.Name]); 
            //Defect#4123 - added field in query- Opportunity.Account.BillingStreet,Opportunity.Account.BillingCity,Product2.Product_Format__c
            //system.debug('LineItems key set --->'+lineItems.keyset());
                                          
            for(OpportunityLineItemWrapper wrapper:dmlList) {
                if(lineItems.containsKey(wrapper.existingId)) {
                    wrapper.lineItemRecord = lineItems.get(wrapper.existingId);
                }
            }
    }
  


     /**
     *  Method to fetch user input and perform insert/update operation on modified records  
     *  @name setOpportunityLineItems
     *  @param CRM_UploadDealProductsController.OpportunityLineItemWrapper[] and Opportunity Id
     *  @return sorted CRM_UploadDealProductsController.OpportunityLineItemWrapper[]
     *  @throws None
     */
   @RemoteAction
    global static list<OpportunityLineItemWrapper> setOpportunityLineItems(List<OpportunityLineItemWrapper> lineItemWrapperList) {
        
        totalFailedRecords = 0;
        // set the index for each line item
        for(Integer i=0; i< lineItemWrapperList.size(); i++) {
            lineItemWrapperList[i].rowIndex = i;
        }
        //system.debug('Inside the save records');
 
        List<OpportunityLineItemWrapper> listLiWrappersToUpdate = new List<OpportunityLineItemWrapper>();
        List<OpportunityLineItem> listLineItemsToUpdate = new List<OpportunityLineItem>(); // For making DML operation

        
        try{

                OpportunityLineItem objLineItem = new OpportunityLineItem();
                Map<String, String> setReasonPicklistValues = getReasonPicklistValues();
                for (OpportunityLineItemWrapper wrapper : lineItemWrapperList) {
                         system.debug('Inside the save records for loop');
                        if(wrapper.isRowModified == true) {
                            if(setReasonPicklistValues != null && wrapper != null && wrapper.lineItemRecord != null && ((wrapper.lineItemRecord.Reason__c != null && setReasonPicklistValues.containsKey(wrapper.lineItemRecord.Reason__c)) || wrapper.lineItemRecord.Reason__c == null)){
                                wrapper.lineItemRecord.Reason__c = setReasonPicklistValues.get(wrapper.lineItemRecord.Reason__c);
                                listLiWrappersToUpdate.add(wrapper);
                                listLineItemsToUpdate.add(wrapper.lineItemRecord);
                            }                               
                            else {
                                wrapper.validation = Label.CRM_Upload_Message_Incorrect_Reason;
                                wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                totalFailedRecords++;
                            }
                        }

                }
                
                
                if(!listLineItemsToUpdate.isEmpty()) {
                    // update changed rows
                    list<Database.SaveResult> updateResults = Database.update(listLineItemsToUpdate,false);
                    system.debug('====listLiWrappersToUpdate===========lineItems================'+listLiWrappersToUpdate);
                    
                    updateDMLResult(updateResults,listLiWrappersToUpdate,Label.CRM_Upload_Message_Updated);
                }
                
        }        
        catch(Exception e) {
            logException(e);
            throw e;
        }
        
        if(!lineItemWrapperList.isEmpty()) {
            lineItemWrapperList[0].numFailedRecords = totalFailedRecords;
        }
        system.debug('totalFailedRecords---------->'+totalFailedRecords);
        return lineItemWrapperList;
    } 
    
    //added as a part of US916
    global static Map<String,String> getReasonPicklistValues(){
        Map<String,String> setReasonsMap = new Map<String,String>();
        
        Schema.DescribeFieldResult fieldResult = Opportunity.Reason__c.getDescribe();
        List<Schema.PicklistEntry> pleReasons = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry pleReason: pleReasons){
            setReasonsMap.put(pleReason.getLabel(), pleReason.getValue());
        }
        return setReasonsMap;
    }
    /**
    *  Description-Wrapper to store the Deal and DealProduct information
    *  @name-DealWrapper 
    */
    public class DealWrapper {
        public Id dealId;
        public Id accountId;
        public String dealCurrency;
        public Id pricebookId;
        public Date dealStartDate;
        public Date dealEndDate;
        
        // Optional to provide
        public string productFormat; //rmn
        
        //Optional to provide
        public string retailerProductId; //rmn
        

    }
     /**
     *  US#660 Add Account Owner filter to Multi Deal planning 
     *  Description-Wrapper to store the Picklist Values for account Owner 
     *  @name-PicklistVal 
    */ 
    global class PicklistVal{
        List<String> picklist = new List<String>();
        List<CRM_DataObjects.PicklistOption> filterPicklist = new List<CRM_DataObjects.PicklistOption>();
        
        public picklistVal(List<String> picklist,List<CRM_DataObjects.PicklistOption> filterPicklist){
            this.picklist = picklist;
            this.filterPicklist = filterPicklist;
        }
    }
    
   /**
    *  US#660 Add Account Owner filter to Multi Deal planning 
    *  Description-Wrapper to return page with filtered Account Owner values
    *  @name-DealWrapper 
   */
    global class FilterWrapper {
        global CRM_DataObjects.PicklistOption[] accOwnerEntered;
    }
     
     /**
     *  US#660 Add Account Owner filter to Multi Deal planning .Method to fill picklist set with values.
     *  @name getPicklistValueSet
     *  @param CRM_DataObjects.PicklistOption[] picklistOptions
     *  @return set of String containing picklist values.
     *  @throws None
    */
    //US#975  start
    public static set<String> getPicklistValueSet(CRM_DataObjects.PicklistOption[] picklistOptions){
        Set<String> picklistValSet = new Set<String>();
        if(picklistOptions != null){
            for(CRM_DataObjects.PicklistOption po : picklistOptions){
                picklistValSet.add(po.value);
            }
        }
        return picklistValSet;
    }
    
    public class CRM_Exception extends Exception {}
}