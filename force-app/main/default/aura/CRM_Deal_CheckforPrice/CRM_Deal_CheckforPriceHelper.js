({
	getOpptDetails :  function(component, event, helper) {
		var action = component.get("c.getNewPriceDetails");
        action.setParams({
            oppId : component.get("v.objectId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var responseDetails = JSON.parse(response.getReturnValue());
                console.log('responseDetails = ' + JSON.stringify(responseDetails));               
                component.set("v.opportunity", responseDetails.dealRecord);
                component.set("v.filterData", responseDetails.dealProductsWrapper);
                component.set("v.futurePriceList", responseDetails.dealProductsWrapper);
                console.log('futurePriceList = ' + JSON.stringify(component.get("v.futurePriceList")));
                component.set("v.futurePriceExist", responseDetails.futurePricingExists);
                component.set("v.msgSeverity", responseDetails.msgSeverity);
                component.set("v.msgText", responseDetails.msgText);
                component.set("v.spinner", false);
                if(responseDetails.dealProductsWrapper!=null && responseDetails.dealProductsWrapper.length>0){
                    var cmpfind = component.find("ser");
                    cmpfind.onchange();
                }
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