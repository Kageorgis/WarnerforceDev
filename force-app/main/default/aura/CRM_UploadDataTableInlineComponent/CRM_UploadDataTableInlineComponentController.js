({
    doInit : function(component, event, helper){
        var record = component.get("v.records");
        var col = component.get("v.columns");
        component.set("v.fieldName", col.fieldName);
        if((col.fieldName).includes(".")){
            var fieldNames = col.fieldName.split(".");
            component.set("v.fieldValue", record[fieldNames[0]][fieldNames[1]]);
        }
        else{
            component.set("v.fieldValue", record[col.fieldName]);
        }
        if(col.type === 'STRING')
            component.set("v.isTextField", true);
        else if(col.type === 'DATE')
            component.set("v.isDateField", true);
            else if(col.type === 'DATETIME')
                component.set("v.isDateField", true);
                else if(col.type === 'PICKLIST'){
                    component.set("v.editpickList", true);
                }
                    else{
                        component.set("v.isTextField", true);
                    }
        if(record["validation"]===null){
            var elem = component.find("colorChange");
            $A.util.removeClass(elem, 'clr-yellow');
        }
    },
    inlineEdit :function(component, event, helper){
        component.set("v.enableEdit", true);
        var elem = component.find("colorChange");
        $A.util.addClass(elem, 'clr-yellow');
        if(component.get("v.editpickList") === true){
            var fieldname = component.find("oppltReason").get("v.class");
            var action = component.get("c.getselectOptions");
            //ER-007552 - Added salesOrg parameter for this ER
            action.setParams({
                "objObject": component.get("v.objInfoForPicklistValues"),
                "fld": fieldname,
                "recordType": (component.get("v.opportunity")).RecordType.Name,
                "salesOrg": (component.get("v.opportunity")).Sales_Organisation__c
            });
            var options = [];
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var optionValues = response.getReturnValue();
                    if(optionValues !== undefined && optionValues.length > 0){
                        options.push({
                            class: "optionClass",
                            label: "--- None ---",
                            value: ""
                        });
                    }
                    for(var i = 0; i < optionValues.length; i++){
                        options.push({
                            class: "optionClass",
                            label: optionValues[i],
                            value: optionValues[i]
                        });
                    }
                    component.set("v.CoopReasonTaticList", options);
                    component.find("oppltReason").set("v.options", component.get("v.CoopReasonTaticList"));
                }
            });
            $A.enqueueAction(action);
        }
    },
    closeEditBox : function(component, event, helper){
        component.set("v.enableEdit", false);
    },
    onEditBox: function(component, event, helper){
        component.set("v.enableEdit", false);
        component.set("v.showSaveCancelBtn", true);
        var record = component.get("v.records");
        var fieldName = component.get("v.fieldName");
        if(component.get("v.columns").type === 'BOOLEAN'){
            record[fieldName] = (component.get("v.fieldValue")).toLowerCase();
        }
        else{
            record[fieldName] = component.get("v.fieldValue");
        }
        component.set("v.records", record);
        var editrecords = component.get("v.editedRecords");
        if(editrecords === null){
            editrecords = {};
        }
        editrecords[record.Id] = record;
        component.set("v.editedRecords", editrecords);
    },
    hideSpinner : function(component, event, handler){
        component.set("v.isSpinner", false);
    }
})