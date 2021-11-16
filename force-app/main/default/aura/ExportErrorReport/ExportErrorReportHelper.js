({
    getUploadObject : function(component, event, helper){
        var action = component.get("c.getUploadObjects");
        action.setParams({
            uploadId : component.get("v.recordId"),
            status : component.get("v.status")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.fullData", result);
                helper.getColumnNames(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    convertArrayOfObjectsToCSV : function(component, result) {
        component.set("v.spinner", true);
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if (result === null || !result.length) {
            return null;
        }
        columnDivider = ',';
        lineDivider =  '\n';
        var tablecol = component.get("v.columnName");
        var fieldNames = new Set();
        for( var i=0 ; i<tablecol.length;i++){
            if(!fieldNames.has(tablecol[i].fieldName)) {
                fieldNames.add(tablecol[i].fieldName);
            }
        }
        fieldNames.add("validation");
        var fieldArry = [];
        fieldNames.forEach(j => fieldArry.push(j));
        var columnNames = new Set();
        for( var i=0 ; i<tablecol.length;i++){
            if(!columnNames.has(tablecol[i].label)) {
                columnNames.add(tablecol[i].label);
            }
        }
        columnNames.add("Validation");
        var columnArry = [];
        columnNames.forEach(j => columnArry.push(j));
        keys = fieldArry;
        csvStringResult = '';
        csvStringResult += columnArry;
        csvStringResult += lineDivider;
        for(var i=0; i < result.length; i++){
            var subResultList =result[i];
            for(var k=0;k<subResultList.length;k++){
                counter = 0;
                var recordJson = JSON.parse(subResultList[k]);
                var record = recordJson.record;
                if(record !== undefined){
                    for(var sTempkey in keys) {
                        var skey = keys[sTempkey];
                        if (skey==="validation"){
                            if(counter > 0){
                                csvStringResult += columnDivider;
                            }
                            csvStringResult += '"'+ recordJson.validation +'"';
                            counter++;
                        }else{
                            var array = (skey).split(".");
                            if(counter > 0){
                                csvStringResult += columnDivider;
                            }
                            if(array.length > 1 && typeof record[array[0]]==='object'){
                                csvStringResult+='"'+(record[array[0]][array[1]])+'"';
                                counter ++;
                            }
                            else{
                                var value = record[skey] === undefined || record[skey] === null ? '' : record[skey];
                                csvStringResult += '"'+ value +'"';
                                counter++;
                            }
                        }
                    }
                }
                csvStringResult += lineDivider;
            }
        }
        return csvStringResult;
    },
    getColumnNames : function(component, event, helper){
        var fieldSet="";
        var recordType = component.get("v.dealRecordType");
        //--ER-007269-Added if condition to check JV sales org and set JV related fieldset name for JV project-Start--//
        if(component.get("v.isJVSalesOrg")){
            fieldSet = recordType.replace('/','').split(" ").join("") + "_JV_fieldSetName";
        }else{
            fieldSet = recordType.replace('/','').split(" ").join("") + "_fieldSetName";
        }
        //--ER-007269-Added if condition to check JV sales org and set JV related fieldset name for JV project-End--//
        var action = component.get("c.getExportFieldSet");
        action.setParams({
            sObjectName : 'OpportunityLineItem',
            fieldSetName : fieldSet
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.columnName", JSON.parse(response.getReturnValue()));
                component.set("v.spinner", false);
                event.getSource().set("v.disabled", false);
            }
        });
        $A.enqueueAction(action);
    }
})