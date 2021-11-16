({
    getTemplates : function (cmp,evt){
        var action = cmp.get("c.fetchContentDocument");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set('v.lstContentDoc', response.getReturnValue());
            }else if(state === "INCOMPLETE"){
                // do something
            }else if(state === "ERROR"){
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error message: " + errors[0].message);
                    }
                }else{
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getValSets : function(cmp,evt){
        var action = cmp.get("c.getLookupValues");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                const storeResponse = response.getReturnValue();
                cmp.set("v.valSets",storeResponse);
                this.generateGrid(cmp,evt);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"warning",
                    "title": "RELOAD Table",
                    "message": "The Product Table is still loading. Refresh the page if it does not appear. "
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    getFieldSet : function(cmp,evt){
        var action = cmp.get("c.getFieldSet");
        action.setParams({
            sObjectName:'CP_Product__c'
        })
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                const storeResponse = response.getReturnValue();
                cmp.set("v.fieldSetList",storeResponse);
            }else{
            }
        });
        $A.enqueueAction(action);
    },
    
    generateGrid : function(cmp,evt){
        cmp.set("v.body", []);
        $A.createComponent(
            "c:cp_prodUploaderGrid",
            {
                "aura:id": "prdGrid",
                "panelOpen": cmp.get("v.panelOpen"),
                "valSets": cmp.get("v.valSets"),
                "fieldSetList": cmp.get("v.fieldSetList"),
                "parsedData": cmp.get("v.parsedData"),
                "lstContentDoc": cmp.get("v.lstContentDoc")
            },
            function(newButton, status, errorMessage){
                if(status === "SUCCESS"){
                    var body = cmp.get("v.body");
                    body.push(newButton);
                    cmp.set("v.body", body);
                    var spinner = cmp.find("gridSpinner");
                    $A.util.toggleClass(spinner, "slds-hide");
                }else if(status === "INCOMPLETE"){
                    console.log("No response from server or client is offline.")
                }else if(status === "ERROR"){
                    console.log("Error: " + errorMessage);
                    cmp.reInit();
                }
            }
        );
    }
});