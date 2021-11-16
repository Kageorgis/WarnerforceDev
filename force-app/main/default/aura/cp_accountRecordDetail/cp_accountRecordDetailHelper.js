({

    createProperties:function(cmp,evt){
        var recordId = cmp.get("v.recordId");
       // console.log("Creating Properties --->"+recordId);
        var eventFields = evt.getParam("fields");
        eventFields.Id = recordId;
    //    console.log("Event fields --->"+JSON.stringify(eventFields));
        var catValues = cmp.get("v.values");
        var subValues = cmp.get("v.subvalues");
        eventFields.Category_Licensee__c = catValues;
        eventFields.Sub_Category__c = subValues;
        var selProps = cmp.get("v.selectedLookUpRecords");
        var existingProps = cmp.get("v.relProps");
        var selRetailers = cmp.get("v.selectedAccountRecords");
        var action = cmp.get("c.createProperties");
        var recTypeId = cmp.get("v.recordTypeId");
      //console.log("Existing Props --->"+JSON.stringify(existingProps));
        var propitems = [];
        for (var i = 0; i < existingProps.length; i++) {

            var propitem = {
                "Id": existingProps[i].Property__c,
                "Name": existingProps[i].Property__r.Name
            };
            propitems.push(propitem);
        }
        console.log("The old Option List -->"+JSON.stringify(selProps,null,2));

        for( var i=selProps.length - 1; i>=0; i--){
            for( var j=0; j<propitems.length; j++){
                if(selProps[i] && (selProps[i].Id === propitems[j].Id)){
                    selProps.splice(i, 1);
                }
            }
        }
        console.log("The new Option List -->"+JSON.stringify(selProps,null,2));

        action.setParams({
            "acc" : eventFields,
            "propIds": selProps,
            "recTypeId": recTypeId,
            "retIds": selRetailers

        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            //    cmp.set("v.layoutSections", response.getReturnValue() );
                $A.get('e.force:refreshView').fire();
              //  alert(JSON.stringify(response.getReturnValue()));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The  info has been updated.",
                    "type": "success"
                });
                toastEvent.fire();
                var recordId = response.getReturnValue();

                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": recordId,
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log( JSON.stringify(errors) );

            }
        });

        $A.enqueueAction(action);


    },
    getLayouts:function (component,event,recTypeId) {
        var action = component.get("c.getPageLayoutFields");
        action.setParams({
            "recTypeId":recTypeId
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.layoutSections", response.getReturnValue() );


            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log( JSON.stringify(errors) );

            }

        });

        $A.enqueueAction(action);



    },
    getCategories:function(component,event,recId){

        var pickvar = component.get("c.getCategories");
       // console.log("Source:Get Categories --> recordId = "+recId);
        if (recId){
            pickvar.setParams({
                "accountId":recId
            })
        }
        pickvar.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var list = response.getReturnValue();
                var items = [];
                for (var i = 0; i < list.catValuesList.length; i++) {

                    var item = {
                        "label": list.catValuesList[i],
                        "value": list.catValuesList[i]
                    };
                    items.push(item);
                }
                component.set("v.options", items);

                var subitems = [];
                for (var i = 0; i < list.subcatValuesList.length; i++) {

                    var subitem = {
                        "label": list.subcatValuesList[i],
                        "value": list.subcatValuesList[i]
                    };
                    subitems.push(subitem);
                }
                component.set("v.suboptions", subitems);
                var propitems = [];
                if(component.get("v.recordId")){
                    var oldCat = component.get("v.accountRecord.cp_Category_Licensee__c");
                    var oldSub = component.get("v.accountRecord.cp_Sub_Category__c");
                    console.log(JSON.stringify(oldCat));
                    if(oldCat != null ){
                        var selCatVals = oldCat.split(';');
                        console.log('SPLIT -->'+JSON.stringify(oldCat.split(';')));
                        component.set("v.values",selCatVals);
                    }
                    if(oldSub != null ){
                        var selSubVals = oldSub.split(';');
                        component.set("v.subvalues",selSubVals);
                    }

                    if(list.propertiesList != null){
                        console.log("NOT NILL");
                        for (var i = 0; i < list.propertiesList.length; i++) {

                            var propitem = {
                                "Id": list.propertiesList[i].Property__c,
                                "Name": list.propertiesList[i].Property__r.Name
                            };
                            propitems.push(propitem);
                        }
                        component.set("v.relProps",list.propertiesList);
                        if(list.retailersList != null) {
                            var retitems = [];
                            for (var i = 0; i < list.retailersList.length; i++) {

                                var retitem = {
                                    "Id": list.retailersList[i].Retailer_Description__c,
                                    "Name": list.retailersList[i].Retailer_Description__r.Name
                                };
                                retitems.push(retitem);
                            }
                            component.set("v.relRets", retitems);
                        }
                    }
                    

                }

            }
            else if(state === 'ERROR'){
                //var list = response.getReturnValue();
                //component.set("v.picvalue", list);
                alert('ERROR OCCURED.');
            }
        })
        $A.enqueueAction(pickvar);
    },
    getRecordTypeId:function (component,evt) {

        var action = component.get("c.getRecordTypeId");
        var recordId = component.get("v.recordId");
      //  console.log("Source: getRecordTypeId --- recordId = "+recordId);
        action.setParams({
            "accId":component.get("v.recordId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var recTypeId = response.getReturnValue();

                component.set("v.recordTypeId");

                this.getLayouts(component,evt,recTypeId);
                this.getCategories(component,evt,recordId);
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log( JSON.stringify(errors) );

            }

        });

        $A.enqueueAction(action);
    },
    openRecordTypeModal:function (cmp,evt) {
        $A.createComponent(
            "c:cp_recordTypeModal",
            {
                "aura:id": "recordTypeModal",
                "isOpen": true,
            },
            function(newModal, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = cmp.get("v.body");
                    body.push(newModal);
                    cmp.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );

    }
});