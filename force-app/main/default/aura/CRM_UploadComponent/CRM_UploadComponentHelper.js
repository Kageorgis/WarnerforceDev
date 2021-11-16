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
                // helper.getFieldSet(component, event, helper);
                //--WBCTASK000316039-Disable in Cancelled deal--//
                if(oppdetails.StageName === $A.get("$Label.c.CRM_Status_Committed") || oppdetails.StageName === $A.get("$Label.c.CRM_Status_Cancelled")){
                    component.set("v.disableDelete", true);
                //Added Check For CRM-JV NR-DEALS
                }else if(oppdetails.StageName === "NR Default" && (oppdetails.RecordType.Name == "Physical DFI Deal" || oppdetails.RecordType.Name == "Physical Planning Deal" || oppdetails.RecordType.Name == "Physical ADV/POS")
                                                            && (oppdetails.Sales_Organisation__c=="9500" || oppdetails.Sales_Organisation__c=="9403")){
                    component.set("v.disableDelete", true);
                }
                 //--W-017642-Added if condition to check JV sales org and set JV related fieldset name for JV project-Start--//
                helper.checkJVSalesOrg(component, event, helper);
                //--W-017642-Added if condition to check JV sales org and set JV related fieldset name for JV project-End--//
                helper.getPermissions(component, event, helper);
            }
        });
        $A.enqueueAction(action);
	},
    getFieldSet : function(component, event, helper) {
        component.set("v.spinner", true);
        var recType = (component.get("v.opportunity")).RecordType.Name;
        //--W-017642-Added if condition to check JV sales org and set JV related fieldset name for JV project-Start--//
        var fieldSet = '';
        if(component.get("v.isJVSalesOrg")){
            fieldSet = recType.replace('/','').split(" ").join("") + "_JV_fieldSetName";
        }else{
            fieldSet = recType.replace('/','').split(" ").join("") + "_fieldSetName";
        }
        //--W-017642-Added if condition to check JV sales org and set JV related fieldset name for JV project-End--//
        
        component.set("v.fieldSetName", fieldSet);
        var action = component.get("c.getFieldSet");
        action.setParams({
            sObjectName : component.get("v.sObjectName"),
            fieldSetName : component.get("v.fieldSetName")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var oppdetails=component.get("v.opportunity");
                var resJson = JSON.parse(response.getReturnValue());
                //Added Check For CRM-JV NR-DEAL
                //--WBCTASK000316039-Disable editing in COmmitted/Cancelled deal--//
                if((oppdetails.StageName === "NR Default" && 
                        (oppdetails.RecordType.Name == "Physical DFI Deal" || oppdetails.RecordType.Name == "Physical Planning Deal" || oppdetails.RecordType.Name == "Physical ADV/POS") && 
                            (oppdetails.Sales_Organisation__c=="9500" || oppdetails.Sales_Organisation__c=="9403")) || 
                        (oppdetails.StageName === $A.get("$Label.c.CRM_Status_Committed") || oppdetails.StageName === $A.get("$Label.c.CRM_Status_Cancelled"))){
                    for( var k = 0; k < resJson.length; k++ ) {
                         resJson[k]["editable"] = false;
                    }
                }
                component.set("v.columns", resJson);
                helper.getdata(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    getdata : function(component, event, helper){
        component.set("v.spinner", true);
        var action1 = component.get("c.getdata");
        var tablecol = component.get("v.columns");
        var fieldNames = new Set();
        for(var i=0 ; i<tablecol.length;i++){
            if(!fieldNames.has(tablecol[i].fieldName)) {
                fieldNames.add(tablecol[i].fieldName);
            }
        }
        var fieldArry = [];
        fieldNames.forEach(j => fieldArry.push(j));
        component.set("v.queryFieldName", fieldArry);
        action1.setParams({
            sObjectName: component.get("v.sObjectName"),
            fieldNameJson: JSON.stringify(fieldArry),
            oppId :component.get("v.objectId")
        });
        action1.setCallback(this, function(response){
            var state1 = response.getState();
            if(state1 === "SUCCESS"){
                //--W-017642-Added logic to make replen field as non editable if new replen is in for JV project-Start--//
                var oppltData = response.getReturnValue();
                for(var i=0; i < oppltData.length; i++){
                    if(oppltData[i].New_Replen_Ship_Fcst__c != null){
                        for(var j=0; j < tablecol.length; j++){
                            if(tablecol[j].fieldName == $A.get("$Label.c.CRMJV_Replen_Ship_Fcst_Field_API")) {
                                tablecol[j].editable = false;
                                break;
                            }
                        }
                    }
                    break;
                }
                //--W-017642-Added logic to make replen field as non editable if new replen is in for JV project-End--//

                component.set("v.data", (response.getReturnValue()));
                component.set("v.fullData", response.getReturnValue());
                component.set("v.length", component.get("v.data").length);
                if(component.get("v.data").length > 0){
                    var cmpfind = component.find("ser");
                    cmpfind.onchange();
                }else{
                    component.set("v.filterData", response.getReturnValue());
                    component.set("v.checklength", true);
                    component.set("v.disableDelete", true);
                }
                component.set("v.spinner", false);
                component.set("v.dataRefresh", true);
            }
        });
        $A.enqueueAction(action1);
    },
    getPermissions : function(component, event, helper){
        var action = component.get("c.getPermissionDetails");
        action.setParams({
            SObjectName: 'Opportunity'
        });
        action.setCallback(this, function(response){
            var state1 = response.getState();
            if(state1 === "SUCCESS"){
                var perm = response.getReturnValue();
                component.set("v.permissionDetails", response.getReturnValue());
                if(perm[0].PermissionsCreate === false && perm[0].PermissionsEdit === false && perm[0].PermissionsDelete === false){
                    component.set("v.disableDelete", true);
                }
                helper.getFieldSet(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
	deleteRecords : function(component, event, helper, dataDeletedList){
            var action = component.get("c.delSelectedRecords");
            action.setParams({
                delList : JSON.stringify(dataDeletedList),
				dealId : component.get("v.objectId")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(response.getState() === "SUCCESS"){
                    var result =JSON.parse(response.getReturnValue());
                    var errorMap = new Map();
                    for(var i=0;i<result.length;i++){
                        if(result[i].isError){
                            errorMap.set(result[i].lineItem.Id, result[i].validation);
                        }
                    }
                    if(errorMap.size>0){
                        var data= component.get("v.filterData");
                        for(var i=0;i<data.length;i++){
                            if(errorMap.get(data[i].Id)!==null){
                                data[i].validation=errorMap.get(data[i].Id);
                            }
                        }
                        component.set("v.deleteCancel", true);
						component.set("v.filterData", data);
                        component.set("v.spinner", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": $A.get("$Label.c.CRM_Validation_Errors_Label"),
                            type: 'error',
                            "message": $A.get("$Label.c.CRM_Record_Could_Not_Delete")
                        });
                        toastEvent.fire();
					}else{
                       helper.getdata(component, event, helper);
                        component.set("v.deleteCancel", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": $A.get("$Label.c.CRM_SuccessLabel"),
                            type: 'success',
                            "message": $A.get("$Label.c.CRM_Records_Deleted_Successfully")
                        });
                        toastEvent.fire();
                    }
				}
            });
            $A.enqueueAction(action);
	},
	saveRecords : function(component, event, helper, dataupdatedList) {
		var action = component.get("c.saveData");
            action.setParams({
                opplt : JSON.stringify(dataupdatedList),
                dealId : component.get("v.objectId")
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var result =JSON.parse(response.getReturnValue());
                    var errorMap = new Map();
                    for(var i=0;i<result.length;i++){
                        if (result[i].isError){
                            errorMap.set(result[i].lineItem.Id, result[i].validation);
                        }
                    }
                    if(errorMap.size>0){
                        var data= component.get("v.filterData");
                        for(var i=0;i<data.length;i++){
                            if(errorMap.get(data[i].Id)!==null){
                                data[i].validation=errorMap.get(data[i].Id);
                            }
                        }
                        component.set("v.filterData", data);
                        component.set("v.spinner", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": $A.get("$Label.c.CRM_Validation_Errors_Label"),
                            type: 'error',
                            "message": $A.get("$Label.c.CRM_Records_Could_Not_Update")
                        });
                        toastEvent.fire();
                    }else{
                       helper.getdata(component, event, helper);
                        component.set("v.showSaveCancelBtn", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": $A.get("$Label.c.CRM_SuccessLabel"),
                            type: 'success',
                            "message": $A.get("$Label.c.CRM_Records_Updated_Successfully")
                        });
                        toastEvent.fire();
                    }
                }else{
                    helper.getdata(component, event, helper);
                    component.set("v.showSaveCancelBtn", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.CRM_Validation_Errors_Label"),
                        type: 'error',
                        "message": $A.get("$Label.c.CRM_Records_Could_Not_Update")
                    });
                    toastEvent.fire();
                }
            });
             $A.enqueueAction(action);
    },
    //--W-017642-Added if condition to check JV sales org and set JV related fieldset name for JV project-Start--//
    checkJVSalesOrg : function(component, event, helper){
        var action = component.get("c.isJVSalesOrg");
        action.setParams({
            dealSalesOrg: component.get("v.opportunity").Sales_Organisation__c
        });
        action.setCallback(this, function(response){
            var state1 = response.getState();
            if(state1 === "SUCCESS"){
                component.set("v.isJVSalesOrg", response.getReturnValue());                           
            }
        });
        $A.enqueueAction(action);
    }
    //--W-017642-Added if condition to check JV sales org and set JV related fieldset name for JV project-End--//
})