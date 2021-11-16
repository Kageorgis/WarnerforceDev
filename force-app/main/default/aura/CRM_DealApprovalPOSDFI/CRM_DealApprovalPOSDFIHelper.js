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
                             
                
                if(recType === 'Physical DFI Deal'){
                    component.set("v.isDFIDeal", true);
                }else{
                    component.set("v.isDFIDeal", false);
                }
                component.set("v.isMoreThan10k", oppdetails.Deal_Overlap_Results_10k_Plus__c);
                component.set("v.recordCount", oppdetails.Deal_Overlap_Records_Queried__c);
                //Added Check For CRM-JV NR-DEALS
                if(oppdetails.StageName === "NR Default" && (oppdetails.RecordType.Name == "Physical DFI Deal" || oppdetails.RecordType.Name == "Physical Planning Deal" || oppdetails.RecordType.Name == "Physical ADV/POS")
                                                            && (oppdetails.Sales_Organisation__c=="9500" || oppdetails.Sales_Organisation__c=="9403")){
                    component.set("v.msgSeverity", 'warning');
                    component.set("v.msgText", $A.get('$Label.c.CRMJV_Msg_NRDefault_Stage'));
                    component.set("v.spinner", false);
                }else{
                helper.getOverlappingDetails(component, event, helper);
                }    
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
                if(component.get("v.isDFIDeal") === true && component.get("v.raiseAlert") == true && component.get("v.isChecked") == false){
                    component.set("v.msgSeverity", 'error');
                }else if(component.get("v.raiseAlert") === true && component.get("v.isDFIDeal") === false && component.get("v.isChecked") == false){
                    component.set("v.msgSeverity", 'warning');
                }
                if((dealWrapperDetails.lstLineItemWrapper) !== null && component.get("v.validationCheck") === $A.get("$Label.c.CRM_Overlapped_Checked_Physical")){
                    var opp= component.get("v.opportunity");
                    if(!opp.IsDateMismatched__c){
                    var cmpfind = component.find("ser");
                    cmpfind.onchange();
                    }    
                }else if((component.get("v.raiseAlert") === false && component.get("v.isDFIDeal") === false)
                  || (component.get("v.raiseAlert") === false && component.get("v.isDFIDeal") === true)){
                    component.set("v.filterData", dealWrapperDetails.lstLineItemWrapper);
                    component.set("v.noOverlap", true);
                    component.set("v.msgSeverity", 'success');
                    component.set("v.msgText", $A.get('$Label.c.CRM_No_Overlap_Obtained_Msg'));
                }else if(component.get("v.raiseAlert") === true && component.get("v.isChecked") == true){
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
    sendToApproval : function(component, event, helper){
       component.set("v.spinner", true);
       var action = component.get("c.callStandardApprovalProcess");
        action.setParams({
            dealID : component.get("v.objectId")
        });
       action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'success',
                    "message": "Record Submitted For Approval."
                });
                toastEvent.fire();
                component.set("v.spinner", false);
                helper.redirectToDeal(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    redirectToDeal : function(component, event, helper){
       window.location.href = '/'+component.get("v.objectId");
    }
})