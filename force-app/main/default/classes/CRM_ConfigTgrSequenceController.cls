/**
   @Author Cognizant
   @name CRM_ConfigTgrSequenceController
   @CreateDate 8 June 2016
   @Description class to be used as a sequence controller for various trigger operations
   @Version <1.0>
*/
public with sharing class CRM_ConfigTgrSequenceController {
    
    /* auto-actions to be performed for all before insert events on Config__c record */
    public static void beforeInsert(Config__c[] newConfigs){
        clearConfigNumber(newConfigs);
    }
    
    /* auto-actions to be performed for all after insert events on Config__c record */
	public static void afterInsert(Config__c[] oldConfigs, Config__c[] newConfigs){
		autoAddRemoveConfigProducts(oldConfigs, newConfigs);
    }
    
    /* auto-actions to be performed for all after update events on Config__c record */
	public static void afterUpdate(Config__c[] oldConfigs, Config__c[] newConfigs){
		autoAddRemoveConfigProducts(oldConfigs, newConfigs);
    }
    
    
    
    /**************** HANDLER METHODS ****************/
    static void autoAddRemoveConfigProducts(Config__c[] oldConfigs, Config__c[] newConfigs) {
    	/* Create/Remove Config Products automatically */
        Set<Id> setImpactedAssortments = new Set<Id>();
        Config__c[] listImpactedConfigs = new Config__c[]{};

        for(Integer i=0; i< newConfigs.size(); i++){
        	if(trigger.isInsert) {
	            // check if the record type of the config is VRAC
	            if(newConfigs[i].RecordTypeId == CRM_RecordTypeUtil.RT_CONFIG_VRAC){
	                setImpactedAssortments.add(newConfigs[i].Assortment__c);
	            }
        	}
        	
        	if((trigger.isInsert && newConfigs[i].SBOM_Product__c != null) ||
        		(trigger.isUpdate && newConfigs[i].SBOM_Product__c != oldConfigs[i].SBOM_Product__c)) {
	            // check if the record type of the config is SBOM
	            if(newConfigs[i].RecordTypeId == CRM_RecordTypeUtil.RT_CONFIG_SBOM){
	                setImpactedAssortments.add(newConfigs[i].Assortment__c);
	                listImpactedConfigs.add(newConfigs[i]);
	            }
        	}
        }

        // Invoke product sync action if the set is not empty
        if(!setImpactedAssortments.isEmpty()) {
            CRM_SyncConfigProductsHelper.syncVRACProducts(setImpactedAssortments);
            
            if(!listImpactedConfigs.isEmpty()) {
            	CRM_SyncConfigProductsHelper.syncSBOMConfigProducts(listImpactedConfigs);
            }
        }
    }
    
    /**
    *  @Description - Method to clear out the field "Config_Number_Txt__c" for cloned configs i.e. not created by migration users
    *  @name - clearConfigNumber
    *  @return - void
    */
    public static void clearConfigNumber(Config__c[] newConfigs) {
        CRM_Default_Configuration__c defConfig = CRM_Default_Configuration__c.getOrgDefaults();
        
        if (CRM_ApplicationUtility.runningUser != null && CRM_ApplicationUtility.runningUser.size() > 0 ) {
            User currentUser = CRM_ApplicationUtility.runningUser[0];
            
            Boolean isInformaticaUser = (defConfig != null && ((Id) defConfig.Informatica_User_Id__c) == currentUser.Id);
            Boolean isDataMigrationUser =  (currentUser.Name.equalsIgnoreCase('Siebel Data Migration'));

            for (Config__c config : newConfigs) {

                // update Config Number Text field for all the configs expect deal coming from informatica/Siebel with Config Number. 
                if (!( (isInformaticaUser || isDataMigrationUser) && config.Config_Number_Txt__c != null)) {
                    // Blank out the Config Number so that workflow can update it with Config_Number__c (AutoNumber Field) 
                    config.Config_Number_Txt__c = null;
                }
            }
        }
    }
}