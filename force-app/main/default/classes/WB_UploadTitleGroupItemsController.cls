global with sharing class WB_UploadTitleGroupItemsController {
    
    public static Integer totalFailedRecords;
    public String recordType{get;set;}
    
    private static final String RECORD_TYPE_MPM = 'MPM'; 
    private static final String RECORD_TYPE_VV  = 'Video_Version';
    private static final String RECORD_TYPE_EEIDR  = 'Edit_EIDR';
	
    global WB_UploadTitleGroupItemsController(ApexPages.StandardController stdController) {
        recordType = getRecordTypeName(stdController.getId());
    } 
    
    global class TitleGroupItemWrapper {
        public Title_Group_Item__c titleGroupItem;
        public String title;
        public String videoVersionOrMPM;
        public String validation='';
        
        public String existingId;
        public boolean isRowModified=false;
        public boolean isRowRemoved=false;
        public boolean previouslySelectedForRemoval=false;
        public Integer rowIndex;
        
        // totalFailedRecords: Number of failed records during (insert/update/delete) operations to be displayed on VF page
        // totalFailedRecords will be taken from first wrapper record always by VF javascript 
        public Integer numFailedRecords;
        
        public String oldValue;
    }
    
    @TestVisible
    private static String getRecordTypeName(Id titleGroupId){
    	Title_Group__c titleGroup = [Select Id,Name,RecordTypeId from Title_Group__c where Id=:titleGroupId];
    	RecordType recType = [Select Id,Name,DeveloperName From RecordType  Where SobjectType = 'Title_Group__c' and Id=:titleGroup.RecordTypeId Limit 1];
    	return recType.DeveloperName;
    }
    
    @RemoteAction
    global static list<TitleGroupItemWrapper> getTitleGroupItems(Id titleGroupId) {
        List<TitleGroupItemWrapper> returnWrapperList = new List<TitleGroupItemWrapper>();
        String recordTypeName = getRecordTypeName(titleGroupId);
        Map<String,TitleGroupItemWrapper> editEDRTGI = new Map<String,TitleGroupItemWrapper>();
        try{
            for(Title_Group_Item__c titleGroupItem: [SELECT Id,Name,Title__c,Local_Title__r.Title__r.Name,Local_Title__c,Local_Title__r.Name,Local_Title__r.Global_Title__c,Local_Title__r.Edit_EIDR_2D__c,Local_Title__r.Edit_EIDR_3D__c,/*Local_Title__r.Version_EIDR__c,*/Local_Title__r.Country__r.Name,Title__r.Video_Version__c,Title__r.Name,MPM__c,MPM__r.MPM_Number__c,MPM__r.MPM_Short_Desc__c
                     									FROM Title_Group_Item__c  WHERE Title_Group__c = :titleGroupId]) 
            {
                     
                TitleGroupItemWrapper lineItemWrapper = new TitleGroupItemWrapper();
                lineItemWrapper.existingId = titleGroupItem.Id;
                lineItemWrapper.titleGroupItem = titleGroupItem;
                
                if(recordTypeName == RECORD_TYPE_VV){
                	lineItemWrapper.videoVersionOrMPM = titleGroupItem.Title__r.Video_Version__c;
                	lineItemWrapper.title = titleGroupItem.Title__r.Name;
                	System.debug('Video Version' + lineItemWrapper.videoVersionOrMPM +' '+lineItemWrapper.title);
                }else if(recordTypeName == RECORD_TYPE_EEIDR){
                	if((editEDRTGI.get(titleGroupItem.Local_Title__r.Edit_EIDR_2D__c) == null) && (editEDRTGI.get(titleGroupItem.Local_Title__r.Edit_EIDR_3D__c) == null)){
                	    
                		String version_EIDR_Value;
                		
                		if(titleGroupItem.Local_Title__r.Edit_EIDR_2D__c != null)
                    		version_EIDR_Value = titleGroupItem.Local_Title__r.Edit_EIDR_2D__c;
                		else if(titleGroupItem.Local_Title__r.Edit_EIDR_3D__c != null)
                		    version_EIDR_Value = titleGroupItem.Local_Title__r.Edit_EIDR_3D__c;
                		    
                        lineItemWrapper.videoVersionOrMPM = version_EIDR_Value;
                		lineItemWrapper.title = titleGroupItem.Local_Title__r.Global_Title__c;
                		if(lineItemWrapper.title == null)
                			lineItemWrapper.title = titleGroupItem.Local_Title__r.Title__r.Name;
                			
                		lineItemWrapper.oldValue = version_EIDR_Value;
                		lineItemWrapper.existingId = 'ExistingEditEIDR';
                	//	lineItemWrapper.country = titleGroupItem.Local_Title__r.Country__r.Name;
                		editEDRTGI.put(version_EIDR_Value,lineItemWrapper);
                	}
                }else{
                	lineItemWrapper.videoVersionOrMPM = titleGroupItem.MPM__r.MPM_Number__c;
                	lineItemWrapper.title = titleGroupItem.MPM__r.MPM_Short_Desc__c;
                	System.debug('MPM' +lineItemWrapper.videoVersionOrMPM +' '+lineItemWrapper.title);
                }
				
                
                lineItemWrapper.validation = '';
                returnWrapperList.add(lineItemWrapper);
                
            }
        }catch(Exception ex) {
        	System.debug(ex.getMessage());
        	throw ex;
        //   logException(titleGroupId,e);
        //   throw new CRM_ProductPricingHandler.CRM_Exception(e.getMessage());
        }
        
        if(recordTypeName == RECORD_TYPE_EEIDR){
        	returnWrapperList = editEDRTGI.values();
        }
        
        return returnWrapperList;
        
    }
    
    @RemoteAction
    global static List<TitleGroupItemWrapper> saveTitleGroupItems(List<TitleGroupItemWrapper> titleGroupItemWrapperList,Id titleGroupId) {
        
        totalFailedRecords = 0;
        // set the index for each line item
        for(Integer i=0; i< titleGroupItemWrapperList.size(); i++) {
            titleGroupItemWrapperList[i].rowIndex = i;
         //   System.debug(titleGroupItemWrapperList[i].titleGroupItem);
         //   System.debug(titleGroupItemWrapperList[i].videoVersionOrMPM +' '+titleGroupItemWrapperList[i].title);
        }
        
        //return null;
          
        List<TitleGroupItemWrapper> listItemWrappersToInsert = new List<TitleGroupItemWrapper>();
        List<TitleGroupItemWrapper> listItemWrappersToUpdate = new List<TitleGroupItemWrapper>();
        List<TitleGroupItemWrapper> listItemWrappersToDelete = new List<TitleGroupItemWrapper>();
          
        try{
                for (TitleGroupItemWrapper wrapper : titleGroupItemWrapperList) {
                    // if any change is made then only consider it for update/insert, else leave it as it is
                    if(wrapper.isRowRemoved!=null && wrapper.isRowRemoved == true){
                       listItemWrappersToDelete.add(wrapper);
                    } else if(wrapper.isRowModified == true) {
                       // Exiting record getting updated
                        if (wrapper.existingId != null ) {
                            listItemWrappersToUpdate.add(wrapper);
                        } else {
                            listItemWrappersToInsert.add(wrapper);
                        }
                    } else { // no modification done to existing rows
                        wrapper.validation = '';
                    }
                }
                
                // update changed rows
                if(!listItemWrappersToUpdate.isEmpty()) {
                    
                    List<Title_Group_Item__c> listLineItemsToUpdate = queryTitlesOrMPM(listItemWrappersToUpdate,false,titleGroupId); // For making DML operation
                    if(listLineItemsToUpdate.size() > 0){
                    	List<Database.SaveResult> updateResults = Database.update(listLineItemsToUpdate,false);
                 		updateDMLResult(updateResults,listItemWrappersToUpdate,Label.CRM_Upload_Message_Updated);
                    }
                }
                
                // for new records
                if(!listItemWrappersToInsert.isEmpty()) {
                    List<Title_Group_Item__c> listLineItemsToInsert = queryTitlesOrMPM(listItemWrappersToInsert,true,titleGroupId); // For making DML operation
                    system.debug('listLineItemsToInsert size ---------------------'+listLineItemsToInsert.size());
                    system.debug('listLineItemsToInsert ---------------------'+listLineItemsToInsert);
                    if(listLineItemsToInsert.size() > 0){ 
                    	list<Database.SaveResult> insertResults = Database.insert(listLineItemsToInsert,false);
                 		updateDMLResult(insertResults,listItemWrappersToInsert,Label.CRM_Upload_Message_Created);
                    }
                }
                
                 // delete records
                if(!listItemWrappersToDelete.isEmpty()) {
                   Integer[] lstRowIndexToRemove = deleteTitleGroupItems(listItemWrappersToDelete,titleGroupId);
                   for(Integer i= lstRowIndexToRemove.size()-1; i >=0; i--) {
                       Integer indexToRemove = lstRowIndexToRemove[i];
                       titleGroupItemWrapperList.remove(indexToRemove);
                   }
                }
        }catch(Exception ex) {
         	System.debug(ex.getMessage());
            throw ex;
        }
        
        if(!titleGroupItemWrapperList.isEmpty()) {
            titleGroupItemWrapperList[0].numFailedRecords = totalFailedRecords;
        }
        system.debug('titleGroupItemWrapperList ---------------'+titleGroupItemWrapperList);
        system.debug('totalFailedRecords---------->'+totalFailedRecords);
        return titleGroupItemWrapperList;
    }
    
    @TestVisible
    private static List<Title_Group_Item__c> queryTitlesOrMPM(List<TitleGroupItemWrapper> itemWrapperList,Boolean isInsert,Id titleGroupId){
    	List<Title_Group_Item__c> groupItemsListForDML = new List<Title_Group_Item__c>();
    	List<Integer> wrapperIndexToRemoveFromList = new List<Integer>();
    	Integer removeindex = 0;
    	String recordTypeName = getRecordTypeName(titleGroupId);
    	
    	List<String> vvMPMList = new List<String>();
    	for(Integer index=0;index<itemWrapperList.size();index++){
    		vvMPMList.add(itemWrapperList[index].videoVersionOrMPM);
    	}
    	system.debug('recordTypeName ---------------'+recordTypeName);
    	if(recordTypeName == RECORD_TYPE_MPM){
    		List<MPM__c> mpmList = [Select Id,Name,MPM_Number__c,MPM_Short_Desc__c from MPM__c where MPM_Number__c in :vvMPMList];
    		Map<String,MPM__c> mpmNumMap = new Map<String,MPM__c>();
    		for(MPM__c mpm:mpmList){
    			mpmNumMap.put(mpm.MPM_Number__c,mpm);
    		}
    		for(TitleGroupItemWrapper itemWrapper:itemWrapperList){
    			if(mpmNumMap.get(itemWrapper.videoVersionOrMPM) != null){
    				if(isInsert)
    					itemWrapper.titleGroupItem = new Title_Group_Item__c(Title_Group__c=titleGroupId);
    					
    				itemWrapper.titleGroupItem.MPM__c = mpmNumMap.get(itemWrapper.videoVersionOrMPM).Id;
    				itemWrapper.title = mpmNumMap.get(itemWrapper.videoVersionOrMPM).MPM_Short_Desc__c;
    				itemWrapper.validation ='';
    				groupItemsListForDML.add(itemWrapper.titleGroupItem);
    			}else{
    				itemWrapper.validation = 'No match found for this MPM#.';
    				wrapperIndexToRemoveFromList.add(removeindex); 
    				//SINC1646097  - counter for failed records added.
    				totalFailedRecords++;
    			}
    			removeindex++;
    		}
    		
    	}else if(recordTypeName == RECORD_TYPE_EEIDR){
    		
    		List<Local_Title__c> localTitleList = [Select Id,Name,Edit_EIDR_2D__c, Edit_EIDR_3D__c,Country__c,Country__r.Name,Global_Title__c,Title__r.Name from Local_Title__c where (Edit_EIDR_2D__c in :vvMPMList OR Edit_EIDR_3D__c in :vvMPMList) AND External_Company__c = Null];
    		Map<String,Set<Local_Title__c>> localTitleEEIDRMap = new Map<String,Set<Local_Title__c>>();
    		for(Local_Title__c lTitle:localTitleList){
    			if((localTitleEEIDRMap.get(lTitle.Edit_EIDR_2D__c) == null) && (localTitleEEIDRMap.get(lTitle.Edit_EIDR_3D__c) == null)){
    			    
    			    if(lTitle.Edit_EIDR_2D__c != null)
    			        localTitleEEIDRMap.put(lTitle.Edit_EIDR_2D__c,new Set<Local_Title__c>());
                    else if(lTitle.Edit_EIDR_3D__c != null)
                        localTitleEEIDRMap.put(lTitle.Edit_EIDR_3D__c,new Set<Local_Title__c>());
    			}
    			
    			if(lTitle.Edit_EIDR_2D__c != null)
    			    localTitleEEIDRMap.get(lTitle.Edit_EIDR_2D__c).add(lTitle);
                else if(lTitle.Edit_EIDR_3D__c != null)
        			localTitleEEIDRMap.get(lTitle.Edit_EIDR_3D__c).add(lTitle);
    		}
			
			Map<String,String> eidrTitleMap = new Map<String,String>();
			Map<String,List<Title_Group_Item__c>> finalinsertMap = new Map<String,List<Title_Group_Item__c>>();
			List<TitleGroupItemWrapper> validList = new List<TitleGroupItemWrapper>();    	
    		for(TitleGroupItemWrapper itemWrapper:itemWrapperList){
    			if(localTitleEEIDRMap.get(itemWrapper.videoVersionOrMPM) != null){
    				validList.add(itemWrapper);
    				for(Local_Title__c localTitle:localTitleEEIDRMap.get(itemWrapper.videoVersionOrMPM)){
    					Title_Group_Item__c newTGItem = new Title_Group_Item__c(Title_Group__c=titleGroupId);
        		        newTGItem.Local_Title__c = localTitle.Id;
        		        eidrTitleMap.put(itemWrapper.videoVersionOrMPM,localTitle.Global_Title__c!=null?localTitle.Global_Title__c:localTitle.Title__r.Name);
        		        if(finalinsertMap.get(itemWrapper.videoVersionOrMPM) == null){
        		        	finalinsertMap.put(itemWrapper.videoVersionOrMPM,new List<Title_Group_Item__c>());
        		        }
        		        finalinsertMap.get(itemWrapper.videoVersionOrMPM).add(newTGItem);
    				}
    			}else{
    				itemWrapper.validation = 'No match found for this EDIT EIDR#.';
    				wrapperIndexToRemoveFromList.add(removeindex); 
    				//SINC1646097  - counter for failed records added.
    				totalFailedRecords++;
    			}
    			removeindex++;
    		}
    		
    		if(finalinsertMap.size() > 0){
    			
	    		if(!isInsert){
	    			List<String> tobeDeletedEIDR = new List<String>(); 
	    			for(Integer index=0;index<validList.size();index++){
	    				if(validList[index].oldValue != null)
	    					tobeDeletedEIDR.add(itemWrapperList[index].oldValue);
	    			}
	    			List<Title_Group_Item__c> exitingTGIList = [Select Id,Name,Local_Title__r.Edit_EIDR_2D__c,Local_Title__r.Edit_EIDR_3D__c,/*Local_Title__r.Version_EIDR__c,*/Local_Title__c From Title_Group_Item__c Where Local_Title__c != null AND (Local_Title__r.Edit_EIDR_2D__c in :tobeDeletedEIDR OR Local_Title__r.Edit_EIDR_3D__c in :tobeDeletedEIDR)];
	    			delete exitingTGIList;
	    		}
				
				List<Title_Group_Item__c> finalInsertList = new List<Title_Group_Item__c>();
    			for(List<Title_Group_Item__c> tgList:finalinsertMap.values()){
    				finalInsertList.addAll(tgList);
    			}
				List<Database.SaveResult> insertResults = Database.insert(finalInsertList,true);
				//If Errors populate otherwise set oldvalue and validation	    		
	    		for(Integer index=0;index<validList.size();index++){
	    			validList[index].oldValue = validList[index].videoVersionOrMPM;
	    			validList[index].validation = isInsert?Label.CRM_Upload_Message_Created:Label.CRM_Upload_Message_Updated;
	    			validList[index].title = eidrTitleMap.get(validList[index].videoVersionOrMPM);
	    		}
    		}
    		    
    		
    	} else{
    		List<Title__c> titleList = [Select Id,Name,Video_Version__c from Title__c where Video_Version__c in :vvMPMList];
    		Map<String,Title__c> titleVVMap = new Map<String,Title__c>();
    		for(Title__c title:titleList){
    			titleVVMap.put(title.Video_Version__c,title);
    		}
    		
    		
    		for(TitleGroupItemWrapper itemWrapper:itemWrapperList){
    			if(titleVVMap.get(itemWrapper.videoVersionOrMPM) != null){
    				if(isInsert)
    					itemWrapper.titleGroupItem = new Title_Group_Item__c(Title_Group__c=titleGroupId);
    					
    				itemWrapper.titleGroupItem.Title__c = titleVVMap.get(itemWrapper.videoVersionOrMPM).Id;
    				itemWrapper.title = titleVVMap.get(itemWrapper.videoVersionOrMPM).Name;
    				groupItemsListForDML.add(itemWrapper.titleGroupItem);
    			}else{
    				itemWrapper.validation = 'No match found for this Video Version#.';
    				wrapperIndexToRemoveFromList.add(removeindex);
    				//SINC1646097  - counter for failed records added.
    				totalFailedRecords++;
    			}
    			removeindex++;
    		}
    		
    	}
    	
    	/*SINC1646097  - changed the code snippet to avoid list index out of bound error */
    	for(Integer index = wrapperIndexToRemoveFromList.size() - 1; index >= 0; index--){
            itemWrapperList.remove(wrapperIndexToRemoveFromList.get(index));
        }

    	return groupItemsListForDML;
    }
    
    private static void updateDMLResult(list<Database.SaveResult> results, list<TitleGroupItemWrapper> dmlList,String successResultString) {
        for(Integer i=0;i<results.size();i++){
            TitleGroupItemWrapper lineItemWrapper = dmlList.get(i);
            lineItemWrapper.isRowModified =false;    
            if (results.get(i).isSuccess()){
                lineItemWrapper.existingId = results.get(i).getId();
                lineItemWrapper.validation = successResultString;
            }else if (!results.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = results.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                lineItemWrapper.validation = failedDML;
                lineItemWrapper.existingId = dmlList.get(i).titleGroupItem.Id;
                totalFailedRecords++;
            }
        }
    }
    
    private static Integer[] deleteTitleGroupItems(List<TitleGroupItemWrapper> lstItemsWrappersToDelete,Id titleGroupId) {
        
        List<Title_Group_Item__c> listItemsToRemove = new List<Title_Group_Item__c>();
        List<TitleGroupItemWrapper> listItemWrappersToRemove = new List<TitleGroupItemWrapper>();
        String recordTypeName = getRecordTypeName(titleGroupId);
        
        List<Integer> lstRowIndexToRemove = new List<Integer>();
        
        if(lstItemsWrappersToDelete!=null) {
            for (TitleGroupItemWrapper wrapper : lstItemsWrappersToDelete) {
                if (wrapper.existingId != null ) { // row is updated
                    wrapper.isRowRemoved =false;
                    wrapper.isRowModified =false;
                    
                    listItemWrappersToRemove.add(wrapper);                    
                    listItemsToRemove.add(wrapper.titleGroupItem);
                } else {
                    lstRowIndexToRemove.add(wrapper.rowIndex);
                }        
            }
        }
        
        try {
            list<Database.DeleteResult> deleteLiResults = Database.delete(listItemsToRemove,false);
            
            List<String> tobeDeletedEIDR = new List<String>();
            
            for(Integer i=0; i < deleteLiResults.size(); i++){
                TitleGroupItemWrapper lineItemWrapper = listItemWrappersToRemove.get(i);
                lineItemWrapper.isRowModified =false;
                lineItemWrapper.isRowRemoved =false;
                
                if (!deleteLiResults.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = deleteLiResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    system.debug('Failed ID remove -'+listItemWrappersToRemove.get(i));
                    
                    lineItemWrapper.existingId = listItemsToRemove.get(i).Id;
                    lineItemWrapper.validation = failedDML;
                    totalFailedRecords++;
                }else {
                    lstRowIndexToRemove.add(lineItemWrapper.rowIndex);
                    
                    tobeDeletedEIDR.add(lineItemWrapper.videoVersionOrMPM);
                }
            }
            
            if(tobeDeletedEIDR.size() > 0 && recordTypeName == RECORD_TYPE_EEIDR){
            	List<Title_Group_Item__c> exitingTGIList = [Select Id,Name,Local_Title__r.Edit_EIDR_2D__c,Local_Title__r.Edit_EIDR_3D__c,/*Local_Title__r.Version_EIDR__c,*/Local_Title__c From Title_Group_Item__c Where Local_Title__c != null AND (Local_Title__r.Edit_EIDR_2D__c in :tobeDeletedEIDR OR Local_Title__r.Edit_EIDR_2D__c in :tobeDeletedEIDR)];
	    		delete exitingTGIList;
            }
            
        }catch(Exception ex) {
        	System.debug(ex.getMessage());
            
            for(Integer i=0; i < listItemWrappersToRemove.size(); i++){
                TitleGroupItemWrapper lineItemWrapper = listItemWrappersToRemove[i];
                lineItemWrapper.isRowModified =false;
                lineItemWrapper.existingId = lineItemWrapper.titleGroupItem.Id;
                lineItemWrapper.validation = ex.getMessage();
                totalFailedRecords++;
            }
        }
        lstRowIndexToRemove.sort();
        return lstRowIndexToRemove;
    }
    
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale);
        return currentUserLocale;
    }
}