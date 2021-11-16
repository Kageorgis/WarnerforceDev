/******* 
WB_TriggerHandlerPhysicalAllocation
Creation Date- 27 Apr 2015
Description- This class is to check for duplictaes in physical Allocation    
Author- Harika Bondalapati
*******/
public with sharing class WB_TriggerHandlerPhysicalAllocation{

  public static void checkPhysicalDuplicates(List<EC_Title_Allocation__c> listnew,Boolean operation){
  List<Id> mpmIds = new List<Id>();
  List<Id> TitleIds = new List<Id>();
  List<Id> EcIds = new List<Id>();
  Map<Id,Decimal> VVandPLMId = new Map<Id,Decimal>();
      for(EC_Title_Allocation__c ect2:listnew){
          mpmIds.add(ect2.MPM__c);
          TitleIds.add(ect2.Title__c);
          EcIds.add(ect2.EC_Piece__c);
      }
      system.debug('mpmIds----->>>'+mpmIds);
      system.debug('TitleIds----->>>'+TitleIds);
      system.debug('EcIds----->>>'+EcIds);
    List<EC_Title_Allocation__c> ectlist = [select MPM__c,Title__c,EC_Piece__c,checkedbox__c,PLM_ID__c from EC_Title_Allocation__c
                                            where MPM__c IN:mpmIds AND Title__c IN:TitleIds AND EC_Piece__c IN:EcIds];
    List<EC_Title_Allocation__c> ectlist2 = [select MPM__c,Title__c,EC_Piece__c,checkedbox__c,PLM_ID__c from EC_Title_Allocation__c
                                             where Title__c IN:TitleIds];       //Query modified on 21-Dec-2016 for ER-870
    system.debug('ectlist----->>>'+ectlist);
    system.debug('operation----->>>'+operation);
    if(operation == true){
        for(Id vv:TitleIds){
            Decimal highnumber = 0;
            for(EC_Title_Allocation__c ect3:ectlist2){
            system.debug('highnumber----->>>'+highnumber);
            system.debug('vv----->>>'+vv);
            system.debug('ect3.Title__c----->>>'+ect3.Title__c);
                if(highnumber < ect3.PLM_ID__c && vv == ect3.Title__c){
                   system.debug('highnumber----->>>'+highnumber);
                   highnumber = ect3.PLM_ID__c;
                }
            }
            system.debug('highnumber----->>>'+highnumber);
            VVandPLMId.put(vv,highnumber);
        }
    }    
    for(EC_Title_Allocation__c ect:listnew){
      Boolean exists = false;
      for(EC_Title_Allocation__c ect2:ectlist){
          if(ect2.MPM__c == ect.MPM__c && ect2.Title__c == ect.Title__c && ect2.EC_Piece__c == ect.EC_Piece__c && ect2.Id != ect.Id){
            exists = true;
          }     
      }
      if(exists == true){
        ect.addError('This allocation record already exists. Please select another Video Version or EC.');
      }else if(operation == true){
         system.debug('VVandPLMId.get(ect.Title__c)----->>>'+VVandPLMId.get(ect.Title__c));
         ect.PLM_ID__c= VVandPLMId.get(ect.Title__c) + 1; 
         VVandPLMId.remove(ect.Title__c);
         system.debug('ect.PLM_ID__c----->>>'+ect.PLM_ID__c);
         VVandPLMId.put(ect.Title__c,ect.PLM_ID__c);
         system.debug('VVandPLMId.get(ect.Title__c)----->>>'+VVandPLMId.get(ect.Title__c));
      }
   }
  }
  
}