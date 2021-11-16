global with sharing class CRM_ProductSearchController {
    
    //US#W-017610 Start- to check logged in user's profile is JV profile or not
    public static boolean isJVProfile = false;
    global CRM_ProductSearchController() {
        Id profileId = UserInfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id =:profileId].Name;
        if(label.CRM_SDSJV_Profile_Values.contains(profileName)) {
            isJVProfile = true;
        }
    } //US#W-017610 end- to check logged in user's profile is JV profile or not
    
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        return currentUserLocale.toLowerCase();
    } 
    
    /*
    *  Method to get logged in uSer Locale Language code
    */
    global String getUserLocaleLanguage() {
        if(UserInfo.getLocale().split('_')[0] == 'en')
            return 'en-GB';
        return UserInfo.getLocale().split('_')[0];
    }
    
    /* US#317 (Japan)
    *  name getUserDateFormat: e.g. M/d/yyyy
    *  param none
    *  return string
    *  throw none
    */  
    global String getUserDateFormat(){
        return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
    }
    
    /**
     *  Public facing ip address for the user. Required by MARS as a basis for
     *  user authentication for asset (image) access.
     *  @name sourceIp
     *  @param None
     *  @return String clientIP
     *  @throws None
     */
    
    global String sourceIp {
        get {
            return CRM_ApplicationUtility.getClientSourrceIp();
        }
    }
    
    /**
     *  REST Image Service URL for url to display images.
     *  @name WB2BImageServiceUrl
     *  @param None
     *  @return String WB2BImageService__c
     *  @throws None
     */
    global WB2B_Details__c WB2BImageServiceSettings {
        get {
            // Fetch all the settings item in the custom setting for making request to B2B Images service
            //US#W-017610 Start- to fetch JV related custom setting for making reuest to B2B Image Service
            String csName = isJVProfile? 'SDSJV':'WB2B';
            WB2B_Details__c b2bSettings = WB2B_Details__c.getValues(csName);
            return b2bSettings; 
        }
    }
    
    
    /**
     *  This method will return picklist values
     *  @name getFilterPicklistValues
     *  @param String object_name, String field_name, String first_val
     *  @return CRM_DataObjects.PicklistOption[]
     *  @throws None
     */

    @RemoteAction 
    global static CRM_DataObjects.PicklistOption[] getFilterPicklistValues(String object_name, String field_name, String first_val) {
      return CRM_AddProductsHelper.getFilterPicklistValues(object_name, field_name, first_val);
    }
    
    @RemoteAction 
    global static CRM_DataObjects.PicklistOption[] getPricebooks() {
        List<CRM_DataObjects.PicklistOption> options = new List<CRM_DataObjects.PicklistOption>();        
        options.add(new CRM_DataObjects.PicklistOption('', '-- Select Pricebook --'));
        
        //US#W-017610 start- added Sales Organization Filter to display only SDS-JV price book to users having SDS JV profiles
        Id profileId = UserInfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id =:profileId].Name;
        if(label.CRM_SDSJV_Profile_Values.contains(profileName)) {
            for(Pricebook2 pb: [select Id, Name, Business_Unit__c from Pricebook2 where IsActive = true AND Country__c IN : doGetCountryCode() 
                                AND (Business_Unit__c = :CRM_AppConstants.TERRITORY_SDS_US_CODE OR Business_Unit__c = :CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)
                                order by Name ] ) {
                                    options.add(new CRM_DataObjects.PicklistOption(pb.Id, pb.Name));
                 }   
        }//US#W-017610 end- added Sales Organization Filter to display only SDS-JV price book to users having SDS JV profiles 
        //US#525 - added country code filter to display only relevant country's price book based on logged in user's profile.
        else { 
            for(Pricebook2 pb: [select Id, Name, Business_Unit__c from Pricebook2 where IsActive = true AND Country__c IN : doGetCountryCode() order by Name ] ) {
                options.add(new CRM_DataObjects.PicklistOption(pb.Id, pb.Name));         
            }
        }
        return (options);
    }
    
    /**
     * This methid returns country code for each profile name.
     * @Name : getPriceBookCountry
     * @Params : none
     * @Return : list<string> countryodes
     * @throws : none
     * @Createddate : 22/11/2017
     */
     global static list<string> doGetCountryCode(){
           
         if(string.isNotBlank(CRM_Functional_Permissions__c.getinstance(userinfo.getProfileId()).PB_CountryCode__c))
         return CRM_Functional_Permissions__c.getinstance(userinfo.getProfileId()).PB_CountryCode__c.split(',');
         return new list<string>();
     }
    
    /**
     *  This method returns deal related product 
     *  @name getProducts
     *  @param Id recordId (always be null), Id pricebookId, CRM_DataObjects.SearchFilters filters
     *  @return List<CRM_DataObjects.ProductItem>
     *  @throws None
     */
    
    @RemoteAction 
    global static CRM_DataObjects.ProductWrapper getProducts(String recordId, String pricebookId, CRM_DataObjects.SearchFilters filters) {
        CRM_DataObjects.ProductWrapper prodWrapper = new CRM_DataObjects.ProductWrapper();
        try{
            system.debug('recordId--->'+recordId);
            system.debug('pricebookId--->'+pricebookId);
            
            if(String.isBlank(pricebookId)) {
                throw new CRM_SearchProductException(label.CRM_Label_Error_for_No_Pricebook_Selected);
            }
            
            //US#1015 - Product language column: added Product_Type__c in query
            Pricebook2 pricebook = [select Id, Name, Business_Unit__c, CurrencyIsoCode, Product_Type__c from Pricebook2 where Id =: pricebookId limit 1];
            
            //CRM_DataObjects.ProductWrapper prodWrapper = new CRM_DataObjects.ProductWrapper();
            List<CRM_DataObjects.ProductItem> items = new List<CRM_DataObjects.ProductItem>();
            
            CRM_DataObjects.ParentRecord parentDetails = new CRM_DataObjects.ParentRecord();
            parentDetails.salesOrg = pricebook.Business_Unit__c;
            parentDetails.currencyCode = pricebook.CurrencyIsoCode;
            system.debug('>>>>>'+pricebook.CurrencyIsoCode);
            parentDetails.startDate = System.TODAY();
            parentDetails.endDate = System.TODAY();
            
            /*parentDetails.bundleId = null;
            parentDetails.accountId = null;
            parentDetails.recordType = null;
            parentDetails.dealRecord = null;*/
            
            items = CRM_AddProductsHelper.searchProducts(parentDetails, pricebookId, filters);
            system.debug('Items: '+items);
            
            prodWrapper.products = items; //dealProductFilterFlag ? filteredItems : items;
            prodWrapper.maxPageCount = CRM_AddProductsHelper.maxPageCount;
            prodWrapper.maxLimitExceeded = CRM_AddProductsHelper.showErrorMsg;
            //Start - US#1015:Product language column
            prodWrapper.isDigital = pricebook.Product_Type__c == 'Digital' ? True : False;
            //End - US#1015:Product language column
            System.debug('prodWrapper::::'+prodWrapper);
        }catch(SearchException ex){ //SINC1370739 filter added to display error message in japanese
            if(ex.getMessage().contains('search term must be longer than one character:')){
                throw new CRM_SearchProductException(Label.CRM_search_text_more_than_1);
            }
        }  
        return prodWrapper; 
    }
    
    /**
     *  Added For CRM-JV Product Search Images 
     *  @name getIsJVProfiles
     *  @return Boolen
     *  @throws None
     */
    global Boolean getIsJVProfiles(){
        return isJVProfile;
    }
    
    global class CRM_SearchProductException extends Exception {}
}