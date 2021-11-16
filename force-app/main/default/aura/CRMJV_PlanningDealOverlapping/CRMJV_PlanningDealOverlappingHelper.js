({
    getOpptDetails :  function(component, event, helper) {
        var action = component.get("c.getOpportunityDetails");
        action.setParams({
            oppId : component.get("v.objectId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var oppdetails = response.getReturnValue();
                component.set("v.opportunity", response.getReturnValue());
                var recType = oppdetails.RecordType.Name;
                component.set("v.isMoreThan10k", oppdetails.Deal_Overlap_Results_10k_Plus__c);
                component.set("v.recordCount", oppdetails.Deal_Overlap_Records_Queried__c);
                helper.getOverlappingDetails(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    getOverlappingDetails : function(component, event, helper){
        var action = component.get("c.getOverlapDeals");
        action.setParams({
            oppId : component.get("v.objectId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var dealWrapperDetails = JSON.parse(response.getReturnValue());
                component.set("v.raiseAlert", dealWrapperDetails.showMessage);
                component.set("v.lineItemsOverlapping", dealWrapperDetails.lstLineItemWrapper);
                component.set("v.validationCheck", dealWrapperDetails.showValidationCheck);
                component.set("v.isChecked", dealWrapperDetails.validationError);
                if(component.get("v.raiseAlert") === true && component.get("v.isChecked") == false){
                    component.set("v.msgSeverity", 'warning');
                }
                
                if((dealWrapperDetails.lstLineItemWrapper) !== null && component.get("v.validationCheck") === $A.get("$Label.c.CRM_Overlapped_Checked_Physical")){
                    var cmpfind = component.find("ser");
                    cmpfind.onchange();
                }  else if(component.get("v.raiseAlert") === false){
                    component.set("v.filterData", dealWrapperDetails.lstLineItemWrapper);
                    component.set("v.noOverlap", true);
                    component.set("v.msgSeverity", 'success');
                    component.set("v.msgText", $A.get('$Label.c.CRMJV_No_Overlap_Obtained_Msg'));                    
                } else if(component.get("v.raiseAlert") === true && component.get("v.isChecked") == true){
                        component.set("v.msgSeverity", 'error');
                        var msgValue = component.get("v.validationCheck");
                        component.set("v.msgText", msgValue);
                    }
                component.set("v.spinner", false);
            }else{
                component.set("v.msgSeverity", 'error');
                var msgValue = action.getError();
                component.set("v.msgText", msgValue[0].message);
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    redirectToDeal : function(component, event, helper){
        window.location.href = '/'+component.get("v.objectId");
    }
})