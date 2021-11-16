/**
   @Author: Cognizant Team
   @name CRM_GenerateAccountPlanTargetsCtrl
   @CreateDate 15/2/2016
   @Description: Controller to create target on account plan via button click. Button is on Country Plan.
   @Version 1.0
  */
global without sharing class CRM_GenerateAccountPlanTargetsCtrl {
    public Country_Plan__c countryPlan {get;set;}
    public Country_Plan__c[] countryPlans {get;set;}
    public static boolean doModifyRevAndUnit = true;
     /*
    *  @Description - constructor
    *  @name  CRM_GenerateAccountPlanTargetsCtrl
    */
    public CRM_GenerateAccountPlanTargetsCtrl(){}
    
    public CRM_GenerateAccountPlanTargetsCtrl(ApexPages.StandardController stdCon){
        //stdCon.addFields(new String[]{'Id', 'Name'});
        //this.countryPlan = (Country_Plan__c) stdCon.getRecord();
    }
    
    public CRM_GenerateAccountPlanTargetsCtrl(ApexPages.StandardSetController stdSetController){
      String countryPlanId = ApexPages.currentPage().getParameters().get('id');
      
      if(countryPlanId != null) {
        this.countryPlan = [select Id, Name from Country_Plan__c where Id =:countryPlanId ];
      }
      else {
        this.countryPlans = (Country_Plan__c[]) stdSetController.getSelected();
      }
    }
    
     /**
     *  Method to call the generate functionality and return to the error or the respective country plan standard page. 
     *  @name createTarget
     *  @param None
     *  @return list of failed country plans
     */
    @RemoteAction 
    global static CountryPlanError[] createTarget(String[] countryPlanIds){
       system.debug('countryPlanIds----->'+countryPlanIds); 
         List<Target__c> accountPlanTargetList = new List<Target__c>();
         List<Country_Plan__c> countryPlanList = new List<Country_Plan__c>();
         Map<Id, CountryPlanError> mapFailedCountryPlans = new Map<Id,CountryPlanError>();
         
        countryPlanList = [Select Id, Name, RecordType.DeveloperName,RecordTypeId,NR_Product__c,Product_Group1__c,NR_Product__r.Title_Country__c,Last_Auto_Allocated_Date__c,
        (Select Id,Name,End_Date__c,Start_Date__c,GL_Calendar__c,Stretch_Target__c,Target__c,Returns_Target__c,Billing_Adjustment_Target__c,Returns_Forecast__c,Billing_Adjustment_Forecast__c,Target_Quantity__c,Stretch_Target_Quantity__c From Country_Plan_Targets__r ORDER BY Start_Date__c),
        (Select Id,Name, RecordTypeId, CurrencyISOCode, Share__c,Total_Target__c,Target_Quantity__c,Product_Group__c,Customer__c,Returns_Share__c,Billing_Adjustment_Share__c,Country_Plan__r.Id,Country_Plan__r.Name,Country__c  From Account_Plans__r)// Where Country_Plan__c=:countryPlanId
        From Country_Plan__c Where Id IN : countryPlanIds]; //Country_Plan__r.Name,Country_Plan__r.Id  Added to fix stack error
        DateTime currentTime = system.now();
        /* START - US#530 : stamp the dateTime when 'Auto Allocate' button is clicked to see the time and date of last auto allocation */
        for(Country_Plan__c countryPlan : countryPlanList){
            countryPlan.Last_Auto_Allocated_Date__c = currentTime;          
        } 
        //update countryPlanList;
        Database.SaveResult[] resultCP = Database.Update(countryPlanList,false);
        for(Integer i=0; i < resultCP.size(); i++ ){
                if(!resultCP[i].isSuccess()){
                    Database.Error error = resultCP.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    System.debug('failedDML--->'+failedDML);
                    
                    Country_Plan__c failedCP = countryPlanList[i];
                    mapFailedCountryPlans.put(failedCP.Id, new CountryPlanError(failedCP, failedDML));
                }
        }
        
        if(mapFailedCountryPlans.values().size() > 0){
            return mapFailedCountryPlans.values();
        }
        
        /*STOP - US#530 */
        accountPlanTargetList = generateAccountTargetList(countryPlanList);
        
        //Defect : 4224 
        Set<Id> jobIds = new Set<Id>();
         if(accountPlanTargetList != null && accountPlanTargetList.size() > 0){
            List<Target__c> lstAPTarget = new List<Target__c>();
            integer tempChunkSize = CRM_Batch_Size__c.getInstance('UpsertAccountPlanTargets') != null ? Integer.valueOf(CRM_Batch_Size__c.getInstance('UpsertAccountPlanTargets').Batch_Size__c) : 150;
            integer chunkSize = accountPlanTargetList.size() < tempChunkSize ? accountPlanTargetList.size() : tempChunkSize;
            integer count = 0;
            for(Target__c apTarget : accountPlanTargetList){
                count++;
                if(count < chunkSize){
                    lstAPTarget.add(apTarget);
                }else{
                    lstAPTarget.add(apTarget);
                    Id jobId = System.enqueueJob(new CRM_UpsertTargets(lstAPTarget));
                    jobIds.add(jobId);
                    lstAPTarget = new List<Target__c>();
                    count = 0;
                }
             }
            if(lstAPTarget.size() > 0 && lstAPTarget.size() < chunkSize){
                Id jobId = System.enqueueJob(new CRM_UpsertTargets(lstAPTarget));
                jobIds.add(jobId);
            } 
        }
        CountryPlanError cpe = new CountryPlanError(jobIds);
        return new List<CountryPlanError>{cpe};
    }
    
    
    /**
     * method name : generateAccountTargetList
     * Description : US#962: This method is called from CRM_MoveCountryPlanTargetsService and is created to prevent SFDC batch user to modify revenue and units
     * 
     */
    public static List<Target__c> generateAccountTargetList(List<Country_Plan__c> countryPlanList,boolean doModifyRevAndUnit ){
        CRM_GenerateAccountPlanTargetsCtrl.doModifyRevAndUnit = doModifyRevAndUnit;
        return generateAccountTargetList(countryPlanList);
    }
    /**
     *  Method to fetch Country Plan Target and Account Plan and create a Account Plan target for each combination. 
     *  @name generateAccountTargetList
     *  @param List<Country_Plan__c>
     *  @return List<Target__c>
     */
    public static List<Target__c> generateAccountTargetList(List<Country_Plan__c> countryPlanList ){
    
        List<Target__c> accountPlanTargetList = new List<Target__c>();
        List<Country_Plan_Target__c> countryPlanTargetList = new List<Country_Plan_Target__c>();
        List<Account_Plan__c> accountPlanList = new List<Account_Plan__c>();
        Boolean isSFDCBatchUser = getLoginUserDetails(); //US#962
        Target__c accountPlanTarget;
        //Req: #456 - Create Targets for every Account Plan
        CRM_Default_Configuration__c defaultConfiguration = CRM_Default_Configuration__c.getInstance();
        List<GL_Calendar__c> lstGLCalender = [
            SELECT Name, Id,Start_Date__c,End_Date__c
            FROM GL_Calendar__c
            WHERE (Name =: defaultConfiguration.GL_Calender_for_New_Release_FR__c OR Name =: defaultConfiguration.GL_Calender_for_New_Release_JP__c OR Name =: defaultConfiguration.GL_Calender_for_New_Release_IT__c)
            ORDER BY CreatedDate
        ];
        Map<String, GL_Calendar__c> mapCountryToGLCalendar = new Map<String, GL_Calendar__c>();
        for (GL_Calendar__c glCalendar : lstGLCalender) {
            if (!mapCountryToGLCalendar.containskey(glCalendar.Name)) {
                mapCountryToGLCalendar.put(glCalendar.Name, glCalendar);
            }
        }
        
        for(Country_Plan__c countryPlan : countryPlanList){
          //Req: #456 - Create Targets for every Account Plan
            if(
                    countryPlan.RecordType.DeveloperName == CRM_AppConstants.Country_Plan_TYPE_NEW_RELEASE &&
                    countryPlan.NR_Product__c != null &&
                    (
                        countryPlan.NR_Product__r.Title_Country__c == CRM_AppConstants.FRANCE_COUNTRY ||
                        countryPlan.NR_Product__r.Title_Country__c == CRM_AppConstants.JAPAN_COUNTRY ||
                        countryPlan.NR_Product__r.Title_Country__c == CRM_AppConstants.ITALY_COUNTRY
                    ) &&
                    !lstGLCalender.isEmpty() && mapCountryToGLCalendar.size() > 0 &&
                    defaultConfiguration != null &&
                    defaultConfiguration.GL_Calender_for_New_Release_FR__c != null &&
                    defaultConfiguration.GL_Calender_for_New_Release_JP__c != null &&
                    defaultConfiguration.GL_Calender_for_New_Release_IT__c != null
            ) {
                if (mapCountryToGLCalendar.containsKey(defaultConfiguration.GL_Calender_for_New_Release_FR__c) && countryPlan.NR_Product__r.Title_Country__c == CRM_AppConstants.FRANCE_COUNTRY) {
                    List<Target__c> accountPlanTargetListTemp = createTargetsWithAccountPlan(countryPlan, mapCountryToGLCalendar.get(defaultConfiguration.GL_Calender_for_New_Release_FR__c));
                    accountPlanTargetList.addAll(accountPlanTargetListTemp);
                } else if (mapCountryToGLCalendar.containsKey(defaultConfiguration.GL_Calender_for_New_Release_JP__c) && countryPlan.NR_Product__r.Title_Country__c == CRM_AppConstants.JAPAN_COUNTRY) {
                    List<Target__c> accountPlanTargetListTemp = createTargetsWithAccountPlan(countryPlan, mapCountryToGLCalendar.get(defaultConfiguration.GL_Calender_for_New_Release_JP__c));
                    accountPlanTargetList.addAll(accountPlanTargetListTemp);
                } else if (mapCountryToGLCalendar.containsKey(defaultConfiguration.GL_Calender_for_New_Release_IT__c) && countryPlan.NR_Product__r.Title_Country__c == CRM_AppConstants.ITALY_COUNTRY) {
                    List<Target__c> accountPlanTargetListTemp = createTargetsWithAccountPlan(countryPlan, mapCountryToGLCalendar.get(defaultConfiguration.GL_Calender_for_New_Release_IT__c));
                    accountPlanTargetList.addAll(accountPlanTargetListTemp);
                }
            }
            else{
                for(Country_Plan_Target__c countryPlanTarget : countryPlan.Country_Plan_Targets__r){
                    for(Account_Plan__c accountPlan : countryPlan.Account_Plans__r){
                      accountPlanTarget = new Target__c();
                      accountPlanTarget.StartDate__c = countryPlanTarget.Start_Date__c;
                      accountPlanTarget.End_Date__c = countryPlanTarget.End_Date__c;
                      accountPlanTarget.GL_Calendar__c = countryPlanTarget.GL_Calendar__c;
                      accountPlanTarget.CurrencyISOCode = accountPlan.CurrencyISOCode;
                      
                      //US#962 - start
                      //if(countryPlanTarget.Country_Plan__r.Country__c == CRM_AppConstants.CRM_COUNTRY_UK && isSFDCBatchUser){ 
                      if((countryPlan.NR_Product__r.Title_Country__c != CRM_AppConstants.UK_COUNTRY 
                      && countryPlan.NR_Product__r.Title_Country__c != 'Ireland') 
                              || !isSFDCBatchUser || CRM_GenerateAccountPlanTargetsCtrl.doModifyRevAndUnit){ 
                          
                          //US842 - set Target_Maintained_As__c based on the value whether it is revenue or units.
              if(countryPlanTarget.Target_Quantity__c != null){
                          accountPlanTarget.Target_Maintained_As__c = CRM_AppConstants.TARGET_MAINTAINED_AS_QUANTITY ;
                          
                         }
                         else if(countryPlanTarget.Target__c != null)
                         accountPlanTarget.Target_Maintained_As__c = CRM_AppConstants.TARGET_MAINTAINED_AS_REVENUE ;
                         //US842 - ENDS
                     
                          if(accountPlanTarget.Target_Maintained_As__c == CRM_AppConstants.TARGET_MAINTAINED_AS_REVENUE && accountPlan.Share__c != null && countryPlanTarget.Stretch_Target__c != null )
                           accountPlanTarget.Target__c = (accountPlan.Share__c * countryPlanTarget.Stretch_Target__c) / 100;
                          
                          if(accountPlanTarget.Target_Maintained_As__c == CRM_AppConstants.TARGET_MAINTAINED_AS_QUANTITY && accountPlan.Share__c !=null && countryPlanTarget.Target_Quantity__c != null)
                          accountPlanTarget.Target_Units__c = (accountPlan.Share__c * countryPlanTarget.Stretch_Target_Quantity__c) / 100;
                         //US842 ends
                         
                      }
                      //US#962 - end
                   
                   accountPlanTarget.Account__c = accountPlan.Customer__c;
                   accountPlanTarget.Account_Plan_Lookup__c = accountPlan.Id; // LHS Changed by Hrushikesh
                   accountPlanTarget.Account_Plan_Lookup__r = accountPlan;
                   //accountPlanTarget.Account_Plan_Lookup__r.Country_Plan__r = countryPlan; //Commented to fix stack error
                   accountPlanTarget.Account_Plan_Lookup__r.Country_Plan__c = countryPlan.id; //Added to fix stack error

                   accountPlanTarget.Unique_Key__c = countryPlanTarget.Name + accountPlan.Name;
                   if(countryPlanTarget.Returns_Target__c != null && accountPlan.Returns_Share__c != null){
                       accountPlanTarget.Returns_Target__c = (countryPlanTarget.Returns_Target__c * accountPlan.Returns_Share__c) / 100;
                   }
                   if(countryPlanTarget.Returns_Forecast__c != null && accountPlan.Returns_Share__c != null){
                       accountPlanTarget.Returns_Forecast__c = (countryPlanTarget.Returns_Forecast__c * accountPlan.Returns_Share__c) / 100;
                   }
                   if(countryPlanTarget.Billing_Adjustment_Target__c != null && accountPlan.Billing_Adjustment_Share__c != null){
                       accountPlanTarget.Billing_Adjustment_Target__c = (countryPlanTarget.Billing_Adjustment_Target__c * accountPlan.Billing_Adjustment_Share__c) / 100;
                   }
                   if(countryPlanTarget.Billing_Adjustment_Forecast__c != null && accountPlan.Billing_Adjustment_Share__c != null){
                       accountPlanTarget.Billing_Adjustment_Forecast__c = (countryPlanTarget.Billing_Adjustment_Forecast__c * accountPlan.Billing_Adjustment_Share__c) / 100;
                   }
               
                   if(countryPlan.RecordType.DeveloperName == CRM_AppConstants.Country_Plan_TYPE_NEW_RELEASE){
                       if(countryPlan.NR_Product__c != null){
                          accountPlanTarget.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
                          accountPlanTarget.Product__c = countryPlan.NR_Product__c;
                          accountPlanTargetList.add(accountPlanTarget);
                       }
                   }
                   else if(countryPlan.RecordType.DeveloperName == CRM_AppConstants.Country_Plan_TYPE_CATALOG){   
                       if(countryPlan.Product_Group1__c != null){        
                           accountPlanTarget.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_GROUP;
                           accountPlanTarget.Product_Group__c = countryPlan.Product_Group1__c;
                           accountPlanTargetList.add(accountPlanTarget);
                       }
                   }                 
               }
             }
      }      
       }
        system.debug('accountPlanTargetList***** ' + accountPlanTargetList);
         return accountPlanTargetList;
    }
    
    //Req: #456 - Create Targets for every Account Plan
    public static List<Target__c> createTargetsWithAccountPlan(Country_Plan__c countryPlan, GL_Calendar__c glCalender){
      Target__c accountPlanTarget;
      List<Target__c> accountPlanTargetList = new List<Target__c>();
      
      for(Account_Plan__c accountPlan : countryPlan.Account_Plans__r){
      accountPlanTarget = new Target__c();
      accountPlanTarget.StartDate__c = glCalender.Start_Date__c;
      accountPlanTarget.End_Date__c = glCalender.End_Date__c;
      accountPlanTarget.GL_Calendar__c = glCalender.Id;
      accountPlanTarget.CurrencyISOCode = accountPlan.CurrencyISOCode;
      //accountPlanTarget.Target__c =0;
      //US#596 starts Japan and France Territory changes 
      if(countryPlan.NR_Product__r.Title_Country__c == CRM_AppConstants.JAPAN_COUNTRY){ 
        if(accountPlan.Target_Quantity__c  != null && accountPlan.Target_Quantity__c > 0){
           accountPlanTarget.Target_Units__c = accountPlan.Target_Quantity__c ;
           accountPlanTarget.Target_Maintained_As__c = CRM_AppConstants.TARGET_MAINTAINED_AS_QUANTITY;
        }  
        else if(accountPlan.Total_Target__c  != null && accountPlan.Total_Target__c > 0 ){
            accountPlanTarget.Target__c = accountPlan.Total_Target__c;
            if (accountPlan.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_SELL_THROUGH) {
                accountPlanTarget.Target_Maintained_As__c = CRM_AppConstants.TARGET_MAINTAINED_AS_REVENUE;
            }
        }
     }
     else if(countryPlan.NR_Product__r.Title_Country__c == CRM_AppConstants.FRANCE_COUNTRY || countryPlan.NR_Product__r.Title_Country__c == CRM_AppConstants.ITALY_COUNTRY){
        accountPlanTarget.Target_Units__c = accountPlan.Target_Quantity__c ;
        accountPlanTarget.Target_Maintained_As__c = CRM_AppConstants.TARGET_MAINTAINED_AS_QUANTITY;
     }
     //US#596 ends Japan and France Territory changes
      accountPlanTarget.Account__c = accountPlan.Customer__c;
      accountPlanTarget.Account_Plan_Lookup__c = accountPlan.Id;
      accountPlanTarget.Account_Plan_Lookup__r = accountPlan;
      //accountPlanTarget.Account_Plan_Lookup__r.Country_Plan__r = countryPlan; //Commented to fix stack error
      accountPlanTarget.Account_Plan_Lookup__r.Country_Plan__c = countryPlan.id; //Added to fix stack error
      accountPlanTarget.Unique_Key__c = countryPlan.Name + accountPlan.Name;
      accountPlanTarget.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
      accountPlanTarget.Product__c = countryPlan.NR_Product__c;
      accountPlanTargetList.add(accountPlanTarget);
    }
    return accountPlanTargetList;
    }
    
    @RemoteAction 
    global static Integer watchAPTargetsQueueableJobs(String[] jobIds){
        Integer numOfNonCompletedJobs = [SELECT Count() From AsyncApexJob Where Id IN :jobIds AND Status != 'Completed' AND Status != 'Aborted'];
        return numOfNonCompletedJobs;
    }
    
    @RemoteAction 
    global static CountryPlanError[] getLoggedErrorReocrds(String[] jobIds){
        List<CountryPlanError> lstFailedTargetRecord = new List<CountryPlanError>();
        for(CRM_Error_Log__c cel : [SELECT Id,Message__c From CRM_Error_Log__c Where Error_Record_Id__c IN :jobIds AND Functional_Module__c = :CRM_AppConstants.FUNCTIONAL_MODULE_AUTOALLOCATE_TARGETS]){
            List<String> tempList = cel.Message__c.split(' :: ');
            CountryPlanError cpe = new CountryPlanError(tempList[0],tempList[1],tempList[2]);
            lstFailedTargetRecord.add(cpe);
        }
        return lstFailedTargetRecord;
    }
    
    global class CountryPlanError {
        global String id;
        global String name;
        global String error;
        global Set<Id> jobIds;
        global CountryPlanError(String id,String name,String error){
            this.id = id;
            this.name = name;
            this.error = error;
        }
        global CountryPlanError(Set<Id> jobIds){
            this.jobIds = jobIds;
        }
        global CountryPlanError(Country_Plan__c cp, String errMsg){
          this.id = cp.Id;
          this.name = cp.Name;
          this.error = errMsg;
        }
    }
    
    /**
     *  Defect : 4224 : Queueable Class to upsert Taregts in Chunk 
     *  @name CRM_UpsertTargets
     */
    global class CRM_UpsertTargets implements Queueable {
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        List<Target__c> accountPlanTargetList = new List<Target__c>();
        List<Target__c> lstFailedTargetsLocal = new List<Target__c>();
        global CRM_UpsertTargets(List<Target__c> accountPlanTargetList){
            this.accountPlanTargetList = accountPlanTargetList;
        }
        public void execute(QueueableContext context) {
            system.debug('accountPlanTargetList--'+accountPlanTargetList);
             Database.UpsertResult[] result = Database.Upsert(accountPlanTargetList, Target__c.Unique_Key__c, false);
             for(Integer i=0; i < result.size(); i++ ){
                if(!result[i].isSuccess()){
                    //defect#4570 - parameter changed from Country_Plan__c to Account_Plan__c
                    ////List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList = logAnException(result[i].getErrors(),accountPlanTargetList[i].Account_Plan_Lookup__r,context.getJobId());
                    //List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList = logAnException(result[i].getErrors(),accountPlanTargetList[i].Account_Plan_Lookup__r.Country_Plan__r,context.getJobId());
                    List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList;
                    for(Database.Error err : result[i].getErrors()){
                        errorLogInstanceList = new List<CRM_ErrorLogger.ErrorLog>();
                        if(String.valueOf(err.getStatusCode()).contains('UNABLE_TO_LOCK_ROW')){
                            lstFailedTargetsLocal.add(accountPlanTargetList[i]);
                           system.debug('lstFailedTargetsLocal--------------->'+accountPlanTargetList[i]);
                        }else{
							errorLogInstanceList = logAnException(result[i].getErrors(),accountPlanTargetList[i].Account_Plan_Lookup__r,context.getJobId());
						}
                        if(errorLogInstanceList != null && errorLogInstanceList.size() > 0){
                            listErrorLog.addAll(errorLogInstanceList);
                        }
                    }
                }
             }
             system.debug('lstFailedTargetsLocal Size--------------->'+lstFailedTargetsLocal.size());
             if(lstFailedTargetsLocal != null && lstFailedTargetsLocal.size() > 0){
                    Id jobId = System.enqueueJob(new CRM_UpsertTargets(lstFailedTargetsLocal));
             }
             //lstFailedTargets.addAll(lstFailedTargetsLocal);
             //system.debug('lstFailedTargets in queueable-------------->'+lstFailedTargets.size());
             if(!listErrorLog.isEmpty())
                CRM_ErrorLogger.logError(listErrorLog);
        }
    }
    
    /** 
    *  @description: - This method is used to add Exception log for Deal product
    *  @name: logAnException
    *  @return: void
    */
    //defect#4570 - display target link when validation error appar instead of Country plan link. so parameter is changed from Country_Plan__c to Account_Plan__c 
    public static List<CRM_ErrorLogger.ErrorLog> logAnException(List<Database.Error> errors, Account_Plan__c ap, Id currentJobId){
        List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList = new list<CRM_ErrorLogger.ErrorLog>();
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        for(Database.Error err : errors){
            errorLogInstance.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_AUTOALLOCATE_TARGETS;
            errorLogInstance.recordId = String.valueOf(currentJobId);
            errorLogInstance.className = 'CRM_GenerateAccountPlanTargetsCtrl';
            errorLogInstance.lineNumber = '';
            String errormsg = ap.Id+' :: '+ap.Name+' :: '+err.getMessage();
            
            //String errormsg = countryPlan.Id+' :: '+countryPlan.Name+' :: '+err.getMessage();
            errorLogInstance.errorMessage = errormsg.length() > 255 ? errormsg.substring(0, 255) : errormsg;
            errorLogInstance.stackTrace = ' Error Code: ' + String.valueOf(err.getStatusCode());
            errorLogInstanceList.add(errorLogInstance);
        }
        return errorLogInstanceList;
    }
    
    /** 
    *  @description: - This method is used check if login user is 'SFDC_Batch_User'
    *  @name: getLoginUserDetails
    *  @return: void
    */
  //US# 962
  public static Boolean getLoginUserDetails(){
    //List<User> runningUser = [SELECT Id,Profile.Name,Profile.Id,Name from User where Id =: UserInfo.getUserId() LIMIT 1];
    String runningUser = UserInfo.getName();
    Boolean sfdcBatchUser = false;
    if (runningUser != null){
      if(runningUser == CRM_AppConstants.SFDC_Batch_User){
        sfdcBatchUser = true;
      }
    }
    return sfdcBatchUser;
  }
}