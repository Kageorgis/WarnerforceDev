/**
   @Author Cognizant
   @name CRM_RecordTypeUtil
   @CreateDate 19 Jan 2016
   @Description This class is used to fetch all record type details
   @Version <1.0>
*/
public class CRM_RecordTypeUtil {

    //public static Id RT_DEAL_DEAL {get{ return getRecordTypeId('Opportunity-Deal');}}
    public static Id RT_DEAL_DIGITAL {get{ return getRecordTypeId('Opportunity-Digital_Deal');}}
    public static Id RT_DEAL_PHYSICAL {get{ return getRecordTypeId('Opportunity-Physical_Deal');}}
    public static Id RT_DEAL_ACTUALS {get{ return getRecordTypeId('Opportunity-Actuals');}}
    public static Id RT_DEAL_DC {get{ return getRecordTypeId('Opportunity-DC_Deals');}}
    public static Id RT_DEAL_HIGH_LEVEL {get{ return getRecordTypeId('Opportunity-High_Level');}}
    public static Id RT_DEAL_POS_ACTUALS {get{ return getRecordTypeId('Opportunity-POS_Actuals');}}
    public static Id RT_DEAL_TRADE_SPEND {get{ return getRecordTypeId('Opportunity-Trade_Spend');}}
    public static Id RT_ACCOUNT_SOLD_TO {get{ return getRecordTypeId('Account-Sold_To');}}
    public static Id RT_ACCOUNT_SHIP_TO {get{ return getRecordTypeId('Account-Ship_To');}}
    public static Id RT_ACCOUNT_DIGITAL_CLIENT {get{ return getRecordTypeId('Account-Digital_Client');}}
    public static Id RT_FILEDISCOUNT_FD {get{ return getRecordTypeId('File_Discount__c-File_Discount');}}
    public static Id RT_PRODUCT_PRODUCT {get{ return getRecordTypeId('Product2-Product');}}
    public static Id RT_PRODUCT_DIGITAL {get{ return getRecordTypeId('Product2-Digital_Product');}}
    public static Id RT_PRODUCT_SBOM {get{ return getRecordTypeId('Product2-S_BOM');}}
    public static Id RT_PRODUCT_PHYSICAL {get{ return getRecordTypeId('Product2-Product');}}
    public static Id RT_TARGET_BUNDLE {get{ return getRecordTypeId('Target__c-Bundle');}}
    public static Id RT_TARGET_MID_TERM_NR {get{ return getRecordTypeId('Target__c-Mid_Term_NR');}}
    public static Id RT_TARGET_GROUP {get{ return getRecordTypeId('Target__c-Group');}}
    public static Id RT_TARGET_PRODUCT {get{ return getRecordTypeId('Target__c-Product');}}
    public static Id RT_BUNDLE_NEW_RELEASE {get{ return getRecordTypeId('Bundle__c-New_Release_Bundle');}}
    public static Id RT_ORDER_STANDARD {get{return getRecordTypeId('Order-Standard');}}
    public static Id RT_ORDER_RETURN {get{return getRecordTypeId('Order-Return');}}
    public static Id RT_ORDER_MULTI_ORDER {get{return getRecordTypeId('Order-Multi_Order');}}
    public static Id RT_ORDER_MULTI_ORDER_RETURN {get{return getRecordTypeId('Order-Multi_Order_Return');}}
    public static Id RT_ORDER_MULTI_ORDER_REVENUE_SHARE {get{return getRecordTypeId('Order-Multi_Order_Revenue_Share');}}
    public static Id RT_ORDER_REV_SHARE {get{return getRecordTypeId('Order-Rev_Share_Order');}}
    public static Id RT_ORDER_HIGH_LEVEL_RETURN {get{return getRecordTypeId('Order-High_Level_Return');}}
    public static Id RT_COUNTRY_PLAN_NEW_RELEASE {get{return getRecordTypeId('Country_Plan__c-New_Release');}}
    public static Id RT_ASSORTMENT_CAMPAIGN {get{ return getRecordTypeId('Bundle__c-Campaign_Assortment');}}
    public static Id RT_Promotional_Assortment {get{ return getRecordTypeId('Bundle__c-Promotional_Assortment');}}
    public static Id RT_ASSORTMENT_SEASONAL {get{ return getRecordTypeId('Bundle__c-Seasonal_Bundle');}}
    public static Id RT_CONFIG_SBOM {get{return getRecordTypeId('Config__c-SBOM');}}
    public static Id RT_CONFIG_VRAC {get{return getRecordTypeId('Config__c-VRAC');}}
    public static Id RT_ACCOUNT_PLAN_RENTAL {get{ return getRecordTypeId('Account_Plan__c-Rental');}}
    public static Id RT_ACCOUNT_PLAN_SELL_THROUGH {get{ return getRecordTypeId('Account_Plan__c-Sell_Through');}}
    public static Id RT_ACCOUNT_SPLIT_RENTAL {get{ return getRecordTypeId('Account_Split__c-Rental');}}
    public static Id RT_ACCOUNT_SPLIT_SELL_THROUGH {get{ return getRecordTypeId('Account_Split__c-Sell_Through');}}
    public static Id RT_DEAL_RBA {get{ return getRecordTypeId('Opportunity-RBA');}}    
    public static Id RT_CREDIT_NOTE_REVERSE {get{ return getRecordTypeId('Credit_Note__c-Reverse');}}    
    public static Id RT_CREDIT_NOTE_STANDARD {get{ return getRecordTypeId('Credit_Note__c-Standard');}}
    public static Id RT_CREDIT_NOTE_PHYSICAL_REVERSE {get{ return getRecordTypeId('Credit_Note__c-Physical_Reverse');}}
    public static Id RT_CREDIT_NOTE_PHYSICAL {get{ return getRecordTypeId('Credit_Note__c-Physical');}}
    public static Id RT_Physical_POS_Deal {get{ return getRecordTypeId('Opportunity-Physical_POS_Deal');}}
    public static Id RT_Physical_DFI_Deal {get{ return getRecordTypeId('Opportunity-Physical_DFI_Deal');}}
	public static Id RT_Physical_Planning_Deal {get{ return getRecordTypeId('Opportunity-Physical_Planning_Deal');}}        
    

    private static Map<String,Id> mapRecordTypes;

    private static Id getRecordTypeId(String objWithRectypeName){
        if(mapRecordTypes == null) {
            loadRecordTypes();
        }
        return mapRecordTypes.get(objWithRectypeName);
    }

    public static void loadRecordTypes(){
        mapRecordTypes = new Map<String,Id>();
        Set<String> setObjNames = new Set<String>{'Opportunity', 'File_Discount__c', 'Account', 'Product2', 'Bundle__c', 'Target__c','Order','Country_Plan__c', 'Config__c', 'Account_Plan__c', 'Credit_Note__c', 'Account_Split__c'};

        for(RecordType rt : [select Id, Name, SobjectType, DeveloperName from RecordType where SobjectType in: setObjNames]) {
            mapRecordTypes.put(rt.SobjectType+'-'+rt.DeveloperName, rt.Id);
        }
        system.debug('mapRecordTypes-->'+mapRecordTypes);
    }
}