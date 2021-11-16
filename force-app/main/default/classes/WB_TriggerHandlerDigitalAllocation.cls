/******* 
WB_TriggerHandlerDigitalAllocation
Creation Date- 27 Apr 2015
Description- This class is to check for duplictaes in Digital Allocation    
Author- Harika Bondalapati
ER1191 - Dennis Cho - Add logic to populate EC_UPC_HD__c on EC pieces for Film titles
*******/
public with sharing class WB_TriggerHandlerDigitalAllocation{

  public static void checkDigitalDuplicates(List<EC_Account_Allocation__c> listnew){
    List<Id> mpmIds = new List<Id>();
    List<Id> AccntIds = new List<Id>();
    List<Id> EcIds = new List<Id>();
    List<Id> titleIds = new List<Id>();
   for(EC_Account_Allocation__c ln2:listnew){
        mpmIds.add(ln2.MPM__c);
        AccntIds.add(ln2.Account__c);
        EcIds.add(ln2.EC_Piece__c);
        titleIds.add(ln2.Title__c);
   }
   List<EC_Account_Allocation__c> ecaLists = [select MPM__c,Account__c,EC_Piece__c,Format__c,Title__c from EC_Account_Allocation__c
                                              where  MPM__c IN:mpmIds AND Title__c IN :titleIds AND Account__c IN:AccntIds AND EC_Piece__c IN:EcIds];

// ER1191 - Create lists to populate EC UPC
   List<EC_Piece__c> ecs = [select EC_UPC_HD__c, EC_Tracker__c, EC_Tracker__r.Digital_UPC__c, EC_Tracker__r.EC_UPC_Counter__c
                            from EC_Piece__c where Id IN :EcIds 
                            and EC_Tracker__r.Digital_UPC__c != NULL
                 			and EC_UPC_HD__c = NULL
                            and (EC_Tracker__r.Release_Type__c != 'Franchise - TV' or EC_Tracker__r.Release_Type__c != 'Franchise - Family & Animation DTV (Episodic)')	
                            order by EC_Tracker__r.ID, Sequence__c];
   Set<EC_Tracker__c> SetTrackers = new Set<EC_Tracker__c>();
   List<EC_Tracker__c> lstTrackers = new List<EC_Tracker__c>();
   for (EC_Piece__c Piece:ecs){SetTrackers.add(Piece.EC_Tracker__r);
//                             system.debug('EC Piece ID  --->> ' + Piece.EC_Tracker__c);
                              }   
         
   for(EC_Account_Allocation__c ln:listnew){
      Boolean exists = false;
      for(EC_Account_Allocation__c eca2:ecaLists){
        //ER-252 Commented by shalini to allow EC Allocations with same account but different titles and EC Piece
        if(eca2.MPM__c == ln.MPM__c && eca2.Account__c == ln.Account__c && eca2.EC_Piece__c == ln.EC_Piece__c && eca2.Title__c == ln.Title__c  && eca2.Format__c == ln.Format__c && eca2.Id != ln.Id){
        //if(eca2.MPM__c == ln.MPM__c && eca2.Account__c == ln.Account__c && eca2.EC_Piece__c == ln.EC_Piece__c  &&  eca2.Format__c == ln.Format__c && eca2.Id != ln.Id){ 
            exists = true;
        }    
      }
      if(exists == true){
        ln.addError('This allocation record already exists. Please select another Digital Client or EC.');
      }
   }
// ER1191 - Populate EC UPC    
   if (ecs != null && ecs.size() > 0){
       for (EC_Piece__c Piece:ecs){
           for (EC_Tracker__c Tracker:SetTrackers){
               if (Piece.EC_Tracker__c == Tracker.ID){
                   Piece.EC_UPC_HD__c = Tracker.Digital_UPC__c + '_EC' + String.valueOf(Tracker.EC_UPC_Counter__c);
                   Tracker.EC_UPC_Counter__c = Tracker.EC_UPC_Counter__c + 1;
               }
           }
       }                
   } 
   update ecs;
   lstTrackers.addAll(SetTrackers);
   update lstTrackers;
  }
}