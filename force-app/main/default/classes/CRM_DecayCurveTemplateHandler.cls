public with sharing class CRM_DecayCurveTemplateHandler {
  
  //Update DCT version Number
  public static void updateVersionNumber(Map<Id,Decay_Curve_Template__c> mapOldDecayCurveTemplates, List<Decay_Curve_Template__c> lstNewDecayCurveTemplates){
    
    boolean isInsert = mapOldDecayCurveTemplates == null ? true : false;
    map<String,List<Decimal>> mapDCTNameToVersionNumbers = new map<String,List<Decimal>>();
    map<String,List<Decay_Curve_Template__c>> mapNewDCTNameToDCT= new map<String,List<Decay_Curve_Template__c>>();
    Set<String> setActiveDCTNames = new Set<String>();
    Set<String> setDCTNames = new Set<String>();
    
    for(Decay_Curve_Template__c dct : lstNewDecayCurveTemplates){
      String strKey = dct.Name+'-'+dct.CurrencyIsoCode;
      if(isInsert){
            setDCTNames.add(dct.Name);
            if(!mapNewDCTNameToDCT.containsKey(strKey)){
                mapNewDCTNameToDCT.put(strKey,new List<Decay_Curve_Template__c>{dct});
            }else{
                mapNewDCTNameToDCT.get(strKey).add(dct);
            }
      }else{
        if(dct.Name != mapOldDecayCurveTemplates.get(dct.Id).Name || (dct.Status__c != mapOldDecayCurveTemplates.get(dct.Id).Status__c && dct.Status__c == CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE)){
            setDCTNames.add(dct.Name);
            if(!mapNewDCTNameToDCT.containsKey(strKey)){
                mapNewDCTNameToDCT.put(strKey,new List<Decay_Curve_Template__c>{dct});
            }else{
                mapNewDCTNameToDCT.get(strKey).add(dct);
            }
        }
      }
    }
    
    if(!setDCTNames.isEmpty() && mapNewDCTNameToDCT.keySet().size() > 0){
        for(Decay_Curve_Template__c dct : [SELECT Id,Name,Version_Number__c,CurrencyIsoCode,Status__c
                           FROM Decay_Curve_Template__c 
                           WHERE Name IN :setDCTNames ORDER BY Version_Number__c DESC NULLS LAST]){
          
            String strKey = dct.Name+'-'+dct.CurrencyIsoCode;
            if(!mapDCTNameToVersionNumbers.containsKey(strKey)){
                mapDCTNameToVersionNumbers.put(strKey,new List<Decimal>{dct.Version_Number__c});
            }else{
                mapDCTNameToVersionNumbers.get(strKey).add(dct.Version_Number__c);
            }
            
            if(!isInsert && dct.Status__c == CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE){
                setActiveDCTNames.add(strKey);
            }
        }
        
        for(String strKey : mapNewDCTNameToDCT.keySet()){
            integer counterOfVN = 0;
            for(Decay_Curve_Template__c dct : mapNewDCTNameToDCT.get(strKey)){
                counterOfVN++;
                if(!isInsert && dct.Status__c != mapOldDecayCurveTemplates.get(dct.Id).Status__c && dct.Status__c == CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE){
                    if(setActiveDCTNames.contains(strKey))
                        dct.addError(system.label.CRM_DCT_Active_Validation_Msg);
                }
                
                if((!isInsert && dct.Name != mapOldDecayCurveTemplates.get(dct.Id).Name) || isInsert){
                    if(mapDCTNameToVersionNumbers.containsKey(strKey)){
                        dct.Version_Number__c = mapDCTNameToVersionNumbers.get(strKey).get(0) + counterOfVN;
                    }else{
                        dct.Version_Number__c = (counterOfVN-1);
                    }
                }
            }
        }
    }
  }
  
  //Restrict to delete DCT if DCT is Active/Archived
  public static void restrictToDeleteActiveOrArchivedDCT(List<Decay_Curve_Template__c> lstOldDecayCurveTemplates){
    
    CRM_Functional_Permissions__c CRMFP = CRM_Functional_Permissions__c.getInstance(userinfo.getProfileId());
    
    for(Decay_Curve_Template__c dct : lstOldDecayCurveTemplates){
      if(dct.Status__c == CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE || 
         dct.Status__c == CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ARCHIVED){
           if(!CRMFP.Delete_Decay_Curve_Template_Permission__c)
          dct.addError(System.Label.CRM_DCT_Restrict_To_Delete_ActiveOrArchived_DCT);
      }
    }
  }
}