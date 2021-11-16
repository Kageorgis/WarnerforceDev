({
    init : function (component) {
        //debugger;
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        var inputVariables = [
            {name : "Var_CurrentDealId", type : "String", value : component.get("v.recordId")}
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("CRM_Clone_Deals_Deal_Product_Groups", inputVariables );
    },
    
    //Flow Status Change
    handleStatusChange : function (component, event, helper) {
        //debugger;
        if(event.getParam('status') === "FINISHED_SCREEN" || event.getParam("status") === "FINISHED") {
            $A.get("e.force:closeQuickAction").fire();
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                if(outputVar.name === "Var_NewDealId"){
                    window.setTimeout(
  						$A.getCallback(function() {
                            var editRecordEvent = $A.get("e.force:editRecord");
                            editRecordEvent.setParams({
                                "recordId": outputVar.value,
                            });
                            editRecordEvent.fire();
    					}), 2000
					); 

                    var urlEvent = $A.get("e.force:navigateToSObject");
                    urlEvent.setParams({
                        "recordId": outputVar.value,
                        "isredirect": "true"
                    });
                    urlEvent.fire();                    
                }
            }
        }
    }
})