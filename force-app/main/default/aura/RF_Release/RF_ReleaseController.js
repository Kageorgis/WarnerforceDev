({
    doInit : function(component, event, helper) {
        component.set("v.isOpen", true);  
        helper.getCountry(component);
        helper.getRecordType(component);
       
        var mpmRecordId = component.get("v.recordId");
         //alert('MPM RCRD ID IS: '+mpmRecordId);
        var action2 = component.get("c.getMPMShortDesc");
        action2.setParams({
            recordId: mpmRecordId
        });
        
        action2.setCallback(this, function(response) {
            // Getting the response state
            var state = response.getState();
            // Check if response state is success
            if(state === 'SUCCESS') {
                component.set("v.shortDesc", response.getReturnValue());
                console.log('v.shortDesc value:'+response.getReturnValue());
            }else {
                // Show an alert if the state is incomplete or error
                alert('Error in getting data');
            }
        });
        // Adding the action variable to the global action queue
        $A.enqueueAction(action2);
    },
     closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
         component.set("v.isOpen", false);
         
         $A.get('e.force:refreshView').fire();
         $A.get("e.force:closeQuickAction").fire(); 
   },
    createReleaseFromMPM: function(component, event, helper) {
        var mpmRecordId = component.get("v.recordId");
        var selectedLookUpRecord = component.get("v.selectedLookUpRecord").Id;
        console.log('selectedLookUpRecord:'+selectedLookUpRecord);
        var releaseName = component.get("v.simpleRecord.MPM_Short_Desc__c");
        console.log('releaseName:'+releaseName);
        if(releaseName==null){
            releaseName=component.get("v.shortDesc");
            if(releaseName==null){
                releaseName='';
            }
        }
        var countryName = component.find("InputSelectedCountry");
		
		if(countryName.get("v.value")!='USA'){
			var countryNameFinal= countryName.get("v.value");
			releaseName=releaseName+'_'+countryNameFinal;
		}
     
        console.log('countryName:'+countryName.get("v.value"));
     
     
        var recordTypeName = component.find("InputRecordType");
     
        var physicalStreetDate = component.find("inputPhysicalStreetDate");
        if(physicalStreetDate!=null){
            var physicalStreetFinalDate= physicalStreetDate.get("v.value");
        }
        var vodDate = component.find("inputVODDate");
        if(vodDate!=null){
          var vodFinalDate= vodDate.get("v.value");
        }
        var estDate = component.find("inputESTDate");
        if(estDate!=null){
             var estFinalDate= estDate.get("v.value");
        }
        //console.log('All fields:'+releaseName+countryNameFinal+recordTypeNameFinal+physicalStreetFinalDate+vodFinalDate+estFinalDate);        
        var action = component.get("c.createRelease");   
          action.setParams({
            "mpmId": mpmRecordId,
            "releaseName": releaseName,
            "countryName": countryName.get("v.value"),
            "recordTypeName":recordTypeName.get("v.value"),
            "streetDate":physicalStreetFinalDate,
            "vodDate":vodFinalDate,
            "estDate":estFinalDate,
            "studioId":selectedLookUpRecord
         });
        
         action.setCallback(this,function(response){
          
            var state = response.getState(); 
             var resultsToast = $A.get("e.force:showToast");            
         
                var state = response.getState();
                if(component.isValid() && state === "SUCCESS"){                       
                    var result = response.getReturnValue();
                    var releaseRecordId=response.getReturnValue();
                    console.log('releaseRecordId:'+releaseRecordId);
                    var navEvent = $A.get("e.force:navigateToSObject");
                     navEvent.setParams({
                          recordId: releaseRecordId,
                          slideDevName: "detail"
                     });
                     navEvent.fire(); 
                    if(mpmRecordId==releaseRecordId){
                     resultsToast.setParams({
                     "type": "error",
                     "title": "Error!",
                     "message": 'Cannot create Release for this user!'
                     });
                    }else{
                    resultsToast.setParams({
                     "type": "Success",
                     "title": "Success!",
                     "message": 'Release is successfully created from MPM!'
                     });
                    }
                    resultsToast.fire();
                    helper.hideSpinner(component);
                    component.set("v.isOpen", false);
                    $A.get('e.force:refreshView').fire();
               		$A.get("e.force:closeQuickAction").fire(); 
                   
                }else{
                   let errors= response.getError();
                   console.log('errors:'+errors);
                   let errorMessage= 'Unknown error';
             
					if(errors  && errors[0].message){
					 errorMessage= errors[0].message;
					 console.log('errorMessage:'+errorMessage);
					}else{
						errorMessage=response.getError()[0].pageErrors[0].message;
	                }
                  
                 resultsToast.setParams({
                 "type": "Error",
                 "title": "Cannot create Release!",
                 "message": errorMessage
                 });
         		resultsToast.fire();
             
                helper.hideSpinner(component);
			 }
            
        });       
        
        $A.enqueueAction(action);
      
   }
})