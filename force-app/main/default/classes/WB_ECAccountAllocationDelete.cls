/******* 
WB_ECAccountAllocationDelete
Creation Date- 05 July 2019
Description- This class is to delete EC Account Allocation on related list button 'Delete Allocation' of EC Pieces.
Author- Shubham Agrawal
*******/

public class WB_ECAccountAllocationDelete 
{
    public ApexPages.StandardSetController setCon{get;set;}
    public string ECPieceId {get;set;}
    public integer ECAllocationListSize{get;set;}
    public List<EC_Account_Allocation__c> ECAllocationList;
   
    public WB_ECAccountAllocationDelete(ApexPages.StandardSetController controller)
    {
        setCon = controller;
        ECPieceId = ApexPages.currentPage().getParameters().get('id');
        ECAllocationList = new List<EC_Account_Allocation__c>();
        
        ECAllocationList = [SELECT Id FROM EC_Account_Allocation__c where EC_Piece__c =:ECPieceId];
        ECAllocationListSize = ECAllocationList.size();
    }
    
    public PageReference delECAllocation()
    {
        if(ECPieceId !=null){
            List<EC_Account_Allocation__c> ECAllocationList = [SELECT Id FROM EC_Account_Allocation__c where EC_Piece__c =:ECPieceId];
            if(ECAllocationList.size() > 0){
                delete ECAllocationList;
            }
        }
        
        PageReference ECPDetailPage = new PageReference('/' + ECPieceId);
        return ECPDetailPage; 
    }
    
    public PageReference redirectToECP()
    {
       PageReference ECPDetailPage = new PageReference('/' + ECPieceId);
       return ECPDetailPage; 
    }
    
    @AuraEnabled
    public static void deleteECAllocation(string ECPId1)
    {
      if(ECPId1 != null){
          List<EC_Account_Allocation__c> ECAllocationList = [SELECT Id FROM EC_Account_Allocation__c where EC_Piece__c =:ECPId1];
          if(ECAllocationList.size() > 0){
              delete ECAllocationList;
           }
       }
    }
}