/**
   @Author: Cognizant Technology Solutions
   @name: CRM_ApplicationUtility
   @CreateDate: Mar 10, 2015
   @Description:  Helper class to to get the IP address of the client accessing the salesforce 
   @Version - 1.0
   @reference: None
  */
global without sharing class CRM_ApplicationUtility {

    public static List<User> runningUser = new List<User>();
    static Map<String,Double> mapConversionRates;
    public static Set<Id> clonedDealIds = new Set<Id>();
    public static Map<String, Opportunity> mapClonedDealsIdToInstance = new Map<String, Opportunity>();
    public static Boolean isInvokedByNRBatch = false;
    //--CPU Time Limit--Start--//
    public static boolean isPublishAssortmentDealsBatch = false;
    //--CPU Time Limit--End--//
    //Added for CRM-JV DecayCurveReforcastingBatch  
    public static boolean isDecayCurveReforcastingBatch = false;
    //--W-017677 Added for to skip calling deal trigger for NR batch--Start--//
    public static boolean isJVAutoPhysicalNRBatch = false;
    //--W-017677 Added for to skip calling deal trigger for NR batch--End--//
    //--ER-007269 - Added for skip to update admin status in cloneing deal on orginal deal--Start--//
    public static boolean isJVDealCloneBatch = false;
    //--ER-007269 - Added for skip to update admin status in cloneing deal on orginal deal--End--//
    
    static {
        if (runningUser.size() == 0 && runningUser.isEmpty()) {
            runningUser = [SELECT Id, Name, ByPassValidationRule__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
            System.debug('--runningUser query-->'+runningUser);
        }
    }
    
    //US : 905 : by pass deal trigger to Upload Trade Budgets 
    public static Boolean byPassDealTrigger = false;
    
    
    static Map<String,Double> getConversionRates() {
        if(mapConversionRates == null) {
            mapConversionRates = new Map<String,Double>();
            for(currencytype currType : [SELECT isocode, conversionrate FROM currencytype ]) {
                mapConversionRates.put(currType.isocode, currType.conversionrate);
            }
        }
        system.debug('mapConversionRates--->'+mapConversionRates);
        return mapConversionRates;
    }
    
    public static Decimal convertOrgCurrency(Decimal value, String isoCode) {
        Double conversionRate = getConversionRates().get(isoCode);
        if(conversionRate != null && value != null){
            value = value * conversionRate;
        }
        
        return value;
    }

    /**
    *  @Description - method to get the IP address of the client accessing the salesforce
    *  @name - getClientSourrceIp
    *  @return - ip address of the client
    */
    public static String getClientSourrceIp() {
        List<LoginHistory> lstLogHistory = [SELECT SourceIp
                                            FROM LoginHistory
                                            WHERE UserId = :Userinfo.getUserId()// AND LoginType = 'Application'
                                            ORDER BY loginTime desc limit 1];
        if (lstLogHistory != null && !lstLogHistory.isEmpty())   
            return lstLogHistory[0].SourceIp;
        else
            return null;
    }
    
    // method to update the street dates for digital products which is Start Date of StartDate of first PBEP where NR is true 
    // fields to be passed to wrappers {productId, productRecTypeId, pricebookId, dealCurrencyCode}
    public static void updateDigitalProductStreetDates(CRM_DataObjects.DealProdWrapper[] lstDealWrappers) {
        Map<Id,Date> mapProductStreetDates = new Map<Id,Date>();
        
        Set<Id> setProductIds = new Set<Id>();
        Set<Id> setPricebookIds = new Set<Id>();
        Set<String> setCurrencyCodes = new Set<String>();
        
        for(CRM_DataObjects.DealProdWrapper dw : lstDealWrappers) {
            if(dw.productRecTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                setProductIds.add(dw.productId);
                setPricebookIds.add(dw.pricebookId);
                setCurrencyCodes.add(dw.dealCurrencyCode);
                
                // first blank out the street date if it is a digital product
                dw.productStreetDate = null;
            }        
        }
        
        Map<String,Pricebook_Entry_Period__c> mapDigiStreetDates = new Map<String,Pricebook_Entry_Period__c>(); 
                            
        if(!setProductIds.isEmpty() && !setPricebookIds.isEmpty()) {
            
            
            for (Pricebook_Entry_Period__c PBEP : [select Id, Price_Book__c, Product__c, Product__r.RecordTypeId, CurrencyISOCode, Start_Date__c, End_Date__c, List_Price__c, Client_Avail__r.Local_Data_Category_Picklist__c
                            from Pricebook_Entry_Period__c
                            where Price_Book__c != null and Product__c != null and  Price_Book__c IN: setPricebookIds and Product__c IN: setProductIds and CurrencyISOCode IN: setCurrencyCodes 
                                and New_Release__c = true 
                                and isDuplicate__c = false
                            order by Price_Book__c, Product__c, CurrencyISOCode, Start_Date__c, CreatedDate]) {
                                
                String recKey = (PBEP.Price_Book__c+'-'+PBEP.Product__c+'-'+PBEP.CurrencyISOCode).toLowercase();
                
                if(!mapDigiStreetDates.containsKey(recKey)) {
                    mapDigiStreetDates.put(recKey, PBEP);
                }
            }
        }
        system.debug('mapDigiStreetDates-->'+mapDigiStreetDates);
        for(CRM_DataObjects.DealProdWrapper dw : lstDealWrappers) {
            String dwKey = (dw.pricebookId+'-'+dw.productId+'-'+dw.dealCurrencyCode).toLowercase();
            Pricebook_Entry_Period__c streetDts = mapDigiStreetDates.get(dwKey);
            System.debug('streetDt-->'+dwKey);
            
            if(dw.productRecTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL && streetDts != null) {
                // first blank out the street date if it is a digital product
                dw.productStreetDate = streetDts.Start_Date__c;
                dw.productNREndDate = streetDts.End_Date__c;
                dw.releaseCatgory = streetDts.Client_Avail__r.Local_Data_Category_Picklist__c;
            }
        }
    }
    
    public static Boolean isDigitalProduct(Product2 product) {
        if(product.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
            return true;
        }
        return false;
    }
    
    public static Boolean isPhysicalProduct(Product2 product) {
        if(product.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
            return true;
        }
        return false;
    }
    public static Boolean isValidAccount(Account acc){
        if(acc.Planning_Customer__c == false ||(acc.Status__c!=CRM_AppConstants.ACCOUNT_STATUS_ACTIVE && acc.Status__c!=CRM_AppConstants.ACCOUNT_STATUS_EXPLANNING))
            {
               return false;
            }
        return true;    
    }        
    
    /* Returns a map of user locale | datetime format for that locale
    *  name name getLocaleToDateTimeFmtMap 
    *  param none
    *  return string
    *  throw none
    */
    public static String getLocaleToDateTimeFmtMap (String userLocale) {
    	Map<String,String> localeToDateTimeFmtMap  = new Map<String,String> {
                'ar'            => 'dd/MM/yyyy hh:mm a',
                'ar_AE'         => 'dd/MM/yyyy hh:mm a',
                'ar_BH'         => 'dd/MM/yyyy hh:mm a',
                'ar_JO'         => 'dd/MM/yyyy hh:mm a',
                'ar_KW'         => 'dd/MM/yyyy hh:mm a',
                'ar_LB'         => 'dd/MM/yyyy hh:mm a',
                'ar_SA'         => 'dd/MM/yyyy hh:mm a',
                'bg_BG'         => 'yyyy-M-d H:mm',
                'ca'            => 'dd/MM/yyyy HH:mm',
                'ca_ES'         => 'dd/MM/yyyy HH:mm',
                'ca_ES_EURO'    => 'dd/MM/yyyy HH:mm',
                'cs'            => 'd.M.yyyy H:mm',
                'cs_CZ'         => 'd.M.yyyy H:mm',
                'da'            => 'dd-MM-yyyy HH:mm',
                'da_DK'         => 'dd-MM-yyyy HH:mm',
                'de'            => 'dd.MM.yyyy HH:mm',
                'de_AT'         => 'dd.MM.yyyy HH:mm',
                'de_AT_EURO'    => 'dd.MM.yyyy HH:mm',
                'de_CH'         => 'dd.MM.yyyy HH:mm',
                'de_DE'         => 'dd.MM.yyyy HH:mm',
                'de_DE_EURO'    => 'dd.MM.yyyy HH:mm',
                'de_LU'         => 'dd.MM.yyyy HH:mm',
                'de_LU_EURO'    => 'dd.MM.yyyy HH:mm',
                'el_GR'         => 'd/M/yyyy h:mm a',
                'en_AU'         => 'd/MM/yyyy HH:mm',
                'en_B'          => 'M/d/yyyy h:mm a',
                'en_BM'         => 'M/d/yyyy h:mm a',
                'en_CA'         => 'dd/MM/yyyy h:mm a',
                'en_GB'         => 'dd/MM/yyyy HH:mm',
                'en_GH'         => 'M/d/yyyy h:mm a',
                'en_ID'         => 'M/d/yyyy h:mm a',
                'en_IE'         => 'dd/MM/yyyy HH:mm',
                'en_IE_EURO'    => 'dd/MM/yyyy HH:mm',
                'en_NZ'         => 'd/MM/yyyy HH:mm',
                'en_SG'         => 'M/d/yyyy h:mm a',
                'en_US'         => 'M/d/yyyy h:mm a',
                'en_ZA'         => 'yyyy/MM/dd hh:mm a',
                'es'            => 'd/MM/yyyy H:mm',
                'es_AR'         => 'dd/MM/yyyy HH:mm',
                'es_BO'         => 'dd-MM-yyyy hh:mm a',
                'es_CL'         => 'dd-MM-yyyy hh:mm a',
                'es_CO'         => 'd/MM/yyyy hh:mm a',
                'es_CR'         => 'dd/MM/yyyy hh:mm a',
                'es_EC'         => 'dd/MM/yyyy hh:mm a',
                'es_ES'         => 'd/MM/yyyy H:mm',
                'es_ES_EURO'    => 'd/MM/yyyy H:mm',
                'es_GT'         => 'd/MM/yyyy hh:mm a',
                'es_HN'         => 'MM-dd-yyyy hh:mm a',
                'es_MX'         => 'd/MM/yyyy hh:mm a',
                'es_PE'         => 'dd/MM/yyyy hh:mm a',
                'es_PR'         => 'MM-dd-yyyy hh:mm a',
                'es_PY'         => 'dd/MM/yyyy hh:mm a',
                'es_SV'         => 'MM-dd-yyyy hh:mm a',
                'es_UY'         => 'dd/MM/yyyy hh:mm a',
                'es_VE'         => 'dd/MM/yyyy hh:mm a',
                'et_EE'         => 'd.MM.yyyy H:mm',
                'fi'            => 'd.M.yyyy H:mm',
                'fi_FI'         => 'd.M.yyyy H:mm',
                'fi_FI_EURO'    => 'd.M.yyyy H:mm',
                'fr'            => 'dd/MM/yyyy HH:mm',
                'fr_BE'         => 'd/MM/yyyy H:mm',
                'fr_CA'         => 'yyyy-MM-dd HH:mm',
                'fr_CH'         => 'dd.MM.yyyy HH:mm',
                'fr_FR'         => 'dd/MM/yyyy HH:mm',
                'fr_FR_EURO'    => 'dd/MM/yyyy HH:mm',
                'fr_LU'         => 'dd/MM/yyyy HH:mm',
                'fr_MC'         => 'dd/MM/yyyy HH:mm',
                'hr_HR'         => 'yyyy.MM.dd HH:mm',
                'hu'            => 'yyyy.MM.dd. H:mm',
                'hy_AM'         => 'M/d/yyyy h:mm a',
                'is_IS'         => 'd.M.yyyy HH:mm',
                'it'            => 'dd/MM/yyyy H.mm',
                'it_CH'         => 'dd.MM.yyyy HH:mm',
                'it_IT'         => 'dd/MM/yyyy H.mm',
                'iw'            => 'HH:mm dd/MM/yyyy',
                'iw_IL'         => 'HH:mm dd/MM/yyyy',
                'ja'            => 'yyyy/MM/dd H:mm',
                'ja_JP'         => 'yyyy/mm/dd H:mm',
                'kk_KZ'         => 'M/d/yyyy h:mm a',
                'km_KH'         => 'M/d/yyyy h:mm a',
                'ko'            => 'yyyy. M. d a h:mm',
                'ko_KR'         => 'yyyy. M. d a h:mm',
                'lt_LT'         => 'yyyy.M.d HH.mm',
                'lv_LV'         => 'yyyy.d.M HH:mm',
                'ms_MY'         => 'dd/MM/yyyy h:mm a',
                'nl'            => 'd-M-yyyy H:mm',
                'nl_BE'         => 'd/MM/yyyy H:mm',
                'nl_NL'         => 'd-M-yyyy H:mm',
                'nl_SR'         => 'd-M-yyyy H:mm',
                'no'            => 'dd.MM.yyyy HH:mm',
                'no_NO'         => 'dd.MM.yyyy HH:mm',
                'pl'            => 'yyyy-MM-dd HH:mm',
                'pt'            => 'dd-MM-yyyy H:mm',
                'pt_AO'         => 'dd-MM-yyyy H:mm',
                'pt_BR'         => 'dd/MM/yyyy HH:mm',
                'pt_PT'         => 'dd-MM-yyyy H:mm',
                'ro_RO'         => 'dd.MM.yyyy HH:mm',
                'ru'            => 'dd.MM.yyyy H:mm',
                'sk_SK'         => 'd.M.yyyy H:mm',
                'sl_SI'         => 'd.M.y H:mm',
                'sv'            => 'yyyy-MM-dd HH:mm',
                'sv_SE'         => 'yyyy-MM-dd HH:mm',
                'th'            => 'M/d/yyyy h:mm a',
                'th_TH'         => 'd/M/yyyy, H:mm ?.',
                'tr'            => 'dd.MM.yyyy HH:mm',
                'ur_PK'         => 'M/d/yyyy h:mm a',
                'vi_VN'         => 'HH:mm dd/MM/yyyy',
                'zh'            => 'yyyy-M-d ah:mm',
                'zh_CN'         => 'yyyy-M-d ah:mm',
                'zh_HK'         => 'yyyy-M-d ah:mm',
                'zh_TW'         => 'yyyy/M/d a h:mm'
            };
            
        if (userLocale != null && localeToDateTimeFmtMap.containsKey(userLocale))
            return localeToDateTimeFmtMap.get(userLocale);    
        return 'mm/dd/yyyy hh:mm a';
    }
    
    public static Boolean isDigitalAssortment(Bundle__c assortment) {
    	 if(assortment.Price_Book__r.Product_Type__c.equals(CRM_AppConstants.DIGITAL_INITIALS))
            return true;
        
        return false;
    }
}