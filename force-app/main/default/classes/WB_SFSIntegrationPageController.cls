public with sharing class WB_SFSIntegrationPageController {

    public SelectOption[] availableOptionsForSF {get;set;}
    public SelectOption[] selectedOptionsForSF {get;set;}
    public String storeFrontID {get;set;}
     public  Agreement__c storefrontRec;
    
    public WB_SFSIntegrationPageController (ApexPages.StandardController controller) {
        
       availableOptionsForSF = new List<SelectOption>();
       selectedOptionsForSF = new List<SelectOption>();
        
       storeFrontID = ApexPages.currentPage().getParameters().get('ID');
       storefrontRec = [Select Id,Content_Type__c,Channel_Picklist__c,Format__c,Selected_Combination__c,SFS_Integration__c FROM Agreement__c WHERE ID =: storeFrontID];
       if(storefrontRec.Selected_Combination__c!=null){
            for(String str:storefrontRec.Selected_Combination__c.split(' , ')){               
                availableOptionsForSF.add(new SelectOption(str,str));
            }
       }
   
       if(storefrontRec.SFS_Integration__c!=null){
           for(String str:storefrontRec.SFS_Integration__c.split(' , ')){               
                selectedOptionsForSF.add(new SelectOption(str,str));
            }
        }
        availableCombinations();
    }
    
    public void availableCombinations(){
        
        Set<SelectOption> availableCombinationSet = new Set<SelectOption>();
        Set<SelectOption> selectedCombinationSet = new Set<SelectOption>();
        
        if(storefrontRec.SFS_Integration__c != null){
           for(String value : storefrontRec.SFS_Integration__c.split(',')){
               value = value.trim();
               selectedOptionsForSF.add(new SelectOption(value,value));
               
            }
            selectedCombinationSet.addAll(selectedOptionsForSF);
            selectedOptionsForSF.clear();
            selectedOptionsForSF.addAll(selectedCombinationSet);
          
        }
        
        if(selectedOptionsForSF != null && selectedOptionsForSF.size()>0){
           Set<SelectOption> finalAvailableCombinationSet = new Set<SelectOption>();
            
            selectedCombinationSet.addAll(selectedOptionsForSF);
            finalAvailableCombinationSet.addAll(availableOptionsForSF);
            
            finalAvailableCombinationSet.removeAll(selectedCombinationSet); 
            availableOptionsForSF.clear();
            availableOptionsForSF.addAll(finalAvailableCombinationSet);
            availableOptionsForSF.sort(); 
            
        }
    }
    
    public void updateStoreFrontSFS(){
        
        Set<SelectOption> selectedCombinationSet = new Set<SelectOption>();
        
        selectedCombinationSet.addAll(selectedOptionsForSF);
        selectedOptionsForSF.clear();
        selectedOptionsForSF.addAll(selectedCombinationSet);
        Agreement__c storefrontRecord = new Agreement__c();
        
        //update the selected COmbination value on Storefront with the selected values
        if(selectedOptionsForSF != null){
             String SelectedCombinationValue;
             storefrontRecord.SFS_Integration__c = '';
            
             for(SelectOption val: selectedOptionsForSF){
                 if(SelectedCombinationValue == null)
                    SelectedCombinationValue = val.getValue();
                 else 
                    SelectedCombinationValue = SelectedCombinationValue +' , '+val.getValue();
             }
             
             storefrontRecord.Id = storefrontRec.Id;
             storefrontRecord.SFS_Integration__c = SelectedCombinationValue;
             update storefrontRecord;
         }
         
    }
    
    
}