@isTest
public with sharing class CRM_RecordTypeUtil_Test {
    static testmethod void recordTypeTest(){
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_DEAL_DIGITAL);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_DEAL_PHYSICAL);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_DEAL_ACTUALS);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_DEAL_DC);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_DEAL_DIGITAL);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_DEAL_POS_ACTUALS);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_FILEDISCOUNT_FD);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_TARGET_BUNDLE);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_TARGET_MID_TERM_NR);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_TARGET_GROUP);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_TARGET_PRODUCT);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ORDER_STANDARD);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ORDER_RETURN);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_REVENUE_SHARE);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ORDER_REV_SHARE);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ORDER_HIGH_LEVEL_RETURN);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_Promotional_Assortment);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ASSORTMENT_SEASONAL);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_CONFIG_SBOM);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_CONFIG_VRAC);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_SELL_THROUGH);
    	system.assertNotEquals(null,CRM_RecordTypeUtil.RT_DEAL_RBA);
        
        system.assertNotEquals(null, CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL);
        system.assertNotEquals(null, CRM_RecordTypeUtil.RT_Physical_Planning_Deal);
        
    }
}