public with sharing class WB_MultiselectPage_Controller{

     public SelectOption[] selectedCombinationList { get; set; }
     public String storeFrontID {get;set;}
     public  Agreement__c storefrontRec;
     public Set<String> contentTypeSet = new Set<String>();
     public Set<String> channelSet = new Set<String>();
     public Set<String> formatSet = new Set<String>();
     public SelectOption[] availableCombinationList {get;set;}
    
     public WB_MultiselectPage_Controller() {
        
    }
    
    public WB_MultiselectPage_Controller(ApexPages.StandardController controller) {
         
       storeFrontID = ApexPages.currentPage().getParameters().get('ID');
       
       //Query to get all parameters of the storefront
        storefrontRec = [Select Id,Content_Type__c,Channel_Picklist__c,Format__c,Selected_Combination__c,SFS_Integration__c FROM Agreement__c WHERE ID =: storeFrontID];//SC to SFS change
       
       //Create ContentType Set
       if(storefrontRec.Content_Type__c != null){
           for(String value: storefrontRec.Content_Type__c.split(';')){
               contentTypeSet.add(value);
           }
       }
      
       //Create Channel Set
       if(storefrontRec.Channel_Picklist__c != null){
           for(String value: storefrontRec.Channel_Picklist__c.split(';')){
              channelSet.add(value);
           }
       }
       
       //Create Format Set
       if(storefrontRec.Format__c != null){
           for(String value: storefrontRec.Format__c.split(';')){
               formatSet.add(value);
           }
       }
   
       //Displaying the combination in available list
       availableCombinations();
    }
    
    //Any value either from ContentType ,Channel or Format is removed then it should be removed from the Selected Combination field as well.
    public void selectedCombinations(Map<Id,Agreement__c> oldMap,List<Agreement__c> storefrontNewList){
       
        for(Agreement__c sf : storefrontNewList){
            
            Agreement__c oldStorefront = oldMap.get(sf.Id);
            //If either of ContentType, Format or Channel is modified
            if(oldStorefront.Content_Type__c != sf.Content_Type__c || oldStorefront.Channel_Picklist__c != sf.Channel_Picklist__c || oldStorefront.Format__c != sf.Format__c){
               
                if(sf.Selected_Combination__c == null)
                    continue;
                    
               String newSelectedValue = '';
               
               //Content Type check of previous and new values
               if(oldStorefront.Content_Type__c != sf.Content_Type__c){
                  String selectedValue = sf.Selected_Combination__c;
                  String newContentTypeValue = sf.Content_Type__c;
                  String oldContentTypeValue = oldStorefront.Content_Type__c;
                  sf.Selected_Combination__c = removeOldValue(oldContentTypeValue,newContentTypeValue,selectedValue);
                  
               }//end of contentType check
               
               //Channel check of previous and new values
               if(oldStorefront.Channel_Picklist__c != sf.Channel_Picklist__c){
                  String selectedValue = sf.Selected_Combination__c;
                  String newChannelValue = sf.Channel_Picklist__c;
                  String oldChannelValue = oldStorefront.Channel_Picklist__c;
                  sf.Selected_Combination__c = removeOldValue(oldChannelValue,newChannelValue,selectedValue);
                  
               }//end of channel check
               
               //Format check of previous and new values
               if(oldStorefront.Format__c != sf.Format__c){
                  String selectedValue = sf.Selected_Combination__c;
                  String newFormatValue = sf.Format__c;
                  String oldFormatValue = oldStorefront.Format__c;
                  sf.Selected_Combination__c = removeOldValue(oldFormatValue,newFormatValue,selectedValue);
                
                
                  
               }//end of Format check
               
            }//end if
        }
    }//Method ends

    //Formatting the selected combination
   /* public String formatSelectedCombination(String selectedCombination){
        
        if(selectedCombination != null){
            selectedCombination = selectedCombination.trim();
            if(selectedCombination.contains(',,')){
                selectedCombination=selectedCombination.replace(',,',',');
            }
            if(String.isBlank(selectedCombination.substringAfterLast(','))){
                selectedCombination = selectedCombination.trim();
                selectedCombination = selectedCombination.removeEnd(',');
            }
            if(selectedCombination.indexOf(',', 0) == 0){
                selectedCombination = selectedCombination.substring(1, selectedCombination.length());  
            } 
        }
        
        return selectedCombination;
    }*/
    
    public void availableCombinations(){
        
        availableCombinationList = new List<SelectOption>();
        selectedCombinationList = new List<SelectOption>();
        
        
        
        Set<SelectOption> availableCombinationSet = new Set<SelectOption>();
        Set<SelectOption> selectedCombinationSet = new Set<SelectOption>();
       
        //if storefront selected combination has value then on reload available list should display these values
        if(storefrontRec.Selected_Combination__c != null){
           for(String value : storefrontRec.Selected_Combination__c.split(',')){
               value = value.trim();
               selectedCombinationList.add(new SelectOption(value,value));
               
            }
            selectedCombinationSet.addAll(selectedCombinationList);
            selectedCombinationList.clear();
            selectedCombinationList.addAll(selectedCombinationSet);
          
        }
        
        //Based on contentType,Channel and format create AVailable List for multiselect.
        for(String contentType : contentTypeSet){
            String stringCombination;
            
           // stringCombination = contentType ;
            for(String channel : channelSet){
                for(String format : formatSet){
                    String contentTypeChannel = contentType +'_'+ channel;
                    contentTypeChannel = contentTypeChannel+'_'+format;
                    stringCombination = contentTypeChannel;
                    availableCombinationList.add(new SelectOption(stringCombination,stringCombination));
                    contentTypeChannel = '';
                }
            }
        }
        
        availableCombinationSet.addAll(availableCombinationList);
        availableCombinationList.clear();
        availableCombinationList.addAll(availableCombinationSet);
        availableCombinationList.sort();
        
       
        //Onload if selected Combination fields contains value, then it should be displayed in sSelected List as well removed from Available list
        if(selectedCombinationList != null && selectedCombinationList.size()>0){
           Set<SelectOption> finalAvailableCombinationSet = new Set<SelectOption>();
            
            selectedCombinationSet.addAll(selectedCombinationList);
            finalAvailableCombinationSet.addAll(availableCombinationList);
            
            finalAvailableCombinationSet.removeAll(selectedCombinationSet); 
            availableCombinationList.clear();
            availableCombinationList.addAll(finalAvailableCombinationSet);
            availableCombinationList.sort(); 
            
        }
       
    }
    
    //Update Storeront record with selected combination
    public void updateStoreFrontRec(){
        
        Set<SelectOption> selectedCombinationSet = new Set<SelectOption>();
        Set<SelectOption> selectedCombinationSFS = new Set<SelectOption>();      //SC to SFS Changes Start
        Agreement__c storefrontRecord = new Agreement__c();
        List<SelectOption> SFSSOIntList = new List<SelectOption>();
        if(storefrontRec.SFS_Integration__c != null){
            for(String str:storefrontRec.SFS_Integration__c.split(' , ')){
                SFSSOIntList.add(new selectOption(str,str));
            }
        }
        
        selectedCombinationSFS.addAll(SFSSOIntList);
        selectedCombinationSFS.removeAll(availableCombinationList);
        SFSSOIntList.clear();
        SFSSOIntList.addAll(selectedCombinationSFS);
        if(SFSSOIntList != null){
            storefrontRecord.SFS_Integration__c = '';
            String SelectedCombinationValue1;
            for(SelectOption val: SFSSOIntList){
                
                if(SelectedCombinationValue1 == null){
                    SelectedCombinationValue1 = val.getValue();
                }
                else{ 
                    SelectedCombinationValue1 = SelectedCombinationValue1 +' , '+val.getValue(); 
                }
            }
            storefrontRecord.SFS_Integration__c = SelectedCombinationValue1;
        }   //SC to SFS change Ends
        selectedCombinationSet.addAll(selectedCombinationList);
        selectedCombinationList.clear();
        selectedCombinationList.addAll(selectedCombinationSet);
        //   Agreement__c storefrontRecord = new Agreement__c();  //SC to SFS Change
        
        //update the selected COmbination value on Storefront with the selected values
        if(selectedCombinationList != null){
             String SelectedCombinationValue;
             storefrontRecord.Selected_Combination__c = '';
            
             for(SelectOption val: selectedCombinationList){
                 if(SelectedCombinationValue == null)
                    SelectedCombinationValue = val.getValue();
                 else 
                    SelectedCombinationValue = SelectedCombinationValue +' , '+val.getValue();
             }
             
             storefrontRecord.Id = storefrontRec.Id;
             storefrontRecord.Selected_Combination__c = SelectedCombinationValue;
             update storefrontRecord;
         }
         
    }
    
    public String removeOldValue(String oldSFValue,String newSFValue,String selectedValue){

    	//String selectedValue = sf.Selected_Combination__c;
    	Set<String> newValueSet = new Set<String>();
    	if(newSFValue != Null){
    	    for(String newValue : newSFValue.split(';')){
                newValueSet.add(newValue);
            }
    	}
    	
    	if(oldSFValue != Null){
    	    for(String oldValue : oldSFValue.split(';')){
        		if(!newValueSet.contains(oldValue)){
        			Set<String> selectedSet = new Set<String>();
        			if(selectedValue != Null ){
        			    for(String existingString : selectedValue.split(',')){
                            selectedSet.add(existingString);
                        }
        			}
                    
                    Set<String> removeSet = new Set<String>();
                              
                    for(String value : selectedSet){
                        for(String val : value.split('_')){
                            val = val.trim();
                            if(val.equals(oldValue)){
                                removeSet.add(value);
                            }
                                    
                        }
                    }
                    String newSelected;
                    if(removeSet != null && removeSet.size()>0){
                        selectedSet.removeAll(removeSet);
                                    
                        for(String newVal : selectedSet){
                            if(newSelected == null || newSelected ==''){
                                newSelected = newVal;
                            }else if(newSelected != null){
                                newSelected = newSelected + ', '+newVal;
                            }
                                        
                        }
                                    
                    }
                              
                    selectedValue = newSelected;
        		
        		}
        	}
    	}
    	
    	
    	return selectedValue;
    
    }
    
    
   
}