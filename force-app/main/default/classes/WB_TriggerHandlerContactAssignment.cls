/******* 
WB_TriggerHandlerContactAssignment
Creation Date- 19 Feb 2015
Description- This class is to update Role Field value for the trigger UpdateRolefromContact 
Author- Harika Bondalapati
*******/
public with sharing class WB_TriggerHandlerContactAssignment{

  public static void updateRole(List<Contact_Assignment__c> listnew){
  
      system.debug('listnew---->>>'+listnew);
      List<Id> contctIds = new List<Id>();
      List<Contact> caList = new List<Contact>();
      for(Contact_Assignment__c ln2:listnew){
          contctIds.add(ln2.Contact__c);
      }
      caList = [select Id,Role__c from Contact where Id IN:contctIds];
      for(Contact_Assignment__c ln:listnew){
          if(ln.Contact__c!=null && (ln.Role__c == null || ln.Role__c == '')){
             for(Contact ct:caList){
                 if(ln.Contact__c == ct.Id){
                   ln.Role__c = ct.Role__c;
                 }
             }
          }
          system.debug('ln--->>>'+ln);
      }
  }
}