({
    getOpptDetails : function(component, event, helper){
           var action = component.get("c.getOpportunityDetails");
            action.setParams({
                oppId : component.get("v.objectId")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set("v.oppDetails", response.getReturnValue());
                    var opp = component.get("v.oppDetails");
                    // helper.getColumnNames (component, event, helper);
                    //--WBCTASK000316039-Disable in Cancelled deal--//
                    if(opp.StageName === $A.get("$Label.c.CRM_Status_Committed") || opp.StageName === $A.get("$Label.c.CRM_Status_Cancelled")){
                        component.set("v.disableUpload", true);
                    }else if(opp.StageName === "NR Default" && (opp.RecordType.Name == "Physical DFI Deal" || opp.RecordType.Name == "Physical Planning Deal" || opp.RecordType.Name == "Physical ADV/POS")
                                                            && (opp.Sales_Organisation__c=="9500" || opp.Sales_Organisation__c=="9403")){
                        component.set("v.disableUpload", true);//Added Check For CRM-JV NR-DEALS
                    }
                    var count =  Math.ceil(2024/250);
                    //--W-017642-Added if condition to check JV sales org and set JV related fieldset name for JV project-Start--//
                    helper.checkJVSalesOrg(component, event, helper);
                    //--W-017642-Added if condition to check JV sales org and set JV related fieldset name for JV project-End--//                   
                    helper.getPermissionDetails(component, event, helper);
                }
            });
           $A.enqueueAction(action);
    },
    validateExcel : function(component, event, helper, inputData){
       if(inputData.length > 0){
            var errorProductList = [];
            var keysList = [];
            var emptyFile=false;
            var fieldColumns = component.get("v.columns");
            var inputDataStr= JSON.stringify(inputData);
            var inputDataWrapper =[];
            var fieldnametype = new Map();
            var v = '';
            for( var i=0 ; i<fieldColumns.length;i++){
                if((fieldColumns[i].label).includes("$")){
                    v = fieldColumns[i].label;
                    v = v.replace(/\$/g, '\\$');
                    inputDataStr=inputDataStr.replace(new RegExp(v, "g"), fieldColumns[i].fieldName);
                }
                else{
                    inputDataStr=inputDataStr.replace(new RegExp('"'+fieldColumns[i].label+'"', "g"), '"'+fieldColumns[i].fieldName+'"');
                }
                if(inputDataStr.includes(fieldColumns[i].fieldName))
                    fieldnametype.set(fieldColumns[i].fieldName, fieldColumns[i].type);
            }
            inputData = JSON.parse(inputDataStr);
            var get_keys = fieldnametype.keys();
            var validationCheck = ["CURRENCY", "DOUBLE", "NUMBER"];
            for(var ele of get_keys)
                keysList.push(ele);
          for(var i=0; i< inputData.length; i++)
                {
                    for(var j= 0; j<keysList.length; j++){
                        if (validationCheck.includes(fieldnametype.get(keysList[j])) && (inputData[i][keysList[j]])!== undefined
                           && (inputData[i][keysList[j]]).trim()!== '' && isNaN(parseFloat((inputData[i][keysList[j]]).trim()) )){
                            var errorJson ='{"validation" : "'+ keysList[j]
                            +$A.get("$Label.c.CRM_Excel_Upload_Number_Validation_Error") +'", "record":'+JSON.stringify(inputData[i])+'}';
                            errorProductList.push(errorJson);
                            break;
                        }
                        if(fieldnametype.get(keysList[j])==="BOOLEAN"){
                            if ((inputData[i][keysList[j]]).toLowerCase()==="true"){
                                inputData[i][keysList[j]]="true";
                            }else{
                                  inputData[i][keysList[j]]="false";
                            }
                        }
                        if(fieldnametype.get(keysList[j])==="DATE"){
							//inputData[i][keysList[j]] = $A.localizationService.formatDate(inputData[i][keysList[j]], "yyyy-MM-dd");
                            var regExp = /^\d{4}[\-](0?[1-9]|1[012])[\-](0?[1-9]|[12][0-9]|3[01])$/g;
                            if((inputData[i][keysList[j]])!== undefined){
                                if((inputData[i][keysList[j]]).match(regExp)){
                                    var pdate = (inputData[i][keysList[j]]).split('-');
                                    var yy = parseInt(pdate[0]);
                                    var mm  = parseInt(pdate[1]);
                                    var dd = parseInt(pdate[2]);
                                    var ListofDays = [31,28,31,30,31,30,31,31, 30,31,30,31];
                                    if (mm==1 || mm>2){
                                        if (dd>ListofDays[mm-1]){
                                            var errorJson ='{"validation" : "'+ keysList[j]
                                            +$A.get("$Label.c.CRM_Invalid_Date_On_Upload") +'", "record":'+JSON.stringify(inputData[i])+'}';
                                            errorProductList.push(errorJson);
                                            break;
                                        }
                                    }
                                    if (mm==2){
                                        var lyear = false;
                                        if ( (!(yy % 4) && yy % 100) || !(yy % 400)) {
                                            lyear = true;
                                        }
                                        if ((lyear===false) && (dd>=29)){
                                            var errorJson ='{"validation" : "'+ keysList[j]
                                            +$A.get("$Label.c.CRM_Invalid_Date_On_Upload") +'", "record":'+JSON.stringify(inputData[i])+'}';
                                            errorProductList.push(errorJson);
                                            break;
                                        }
                                        if ((lyear===true) && (dd>29)){
                                            var errorJson ='{"validation" : "'+ keysList[j]
                                            +$A.get("$Label.c.CRM_Invalid_Date_On_Upload") +'", "record":'+JSON.stringify(inputData[i])+'}';
                                            errorProductList.push(errorJson);
                                            break;
                                        }
                                    }
                                }else{
                                    var errorJson ='{"validation" : "'+ keysList[j]
                                    +$A.get("$Label.c.CRM_Invalid_Date_On_Upload") +'", "record":'+JSON.stringify(inputData[i])+'}';
                                    errorProductList.push(errorJson);
                                    
                                    break;
                                }
                            }
                        }
                    }
                      var wrapperRecord ={
                         lineItem :inputData[i],
                         isRowModified :true,
                         isError:false
                    }
                    inputDataWrapper.push(wrapperRecord);
                }
            if(errorProductList.length > 0 || emptyFile){
              
                component.set("v.pageSpinner", false);
                component.set("v.value", 100);
                component.set("v.successCount", 0);
                 component.set("v.errorCount", 0);
                var msg = $A.get("$Label.c.CRM_Excel_Upload_Format_Validation_Error");
                component.set("v.message", msg);
                component.set("v.errorData", JSON.stringify(errorProductList));
            }else{
               helper.uploadObjects(component, event, helper, inputDataWrapper);
            }
        }
        else{
             component.set("v.pageSpinner", false);
            component.find('notifLib').showToast({
                "variant": "error",
                "title": "Upload Failed!",
                "message": $A.get("$Label.c.CRM_Excel_Upload_Empty_File_Error")
            });
        }
    },
    uploadObjects : function(component, event, helper, inputData) {
        var chunkstart = 0, chunkend = 100, chunk = 100;
        var count =  Math.ceil(inputData.length/chunk);
        var uploadList = [];
        for(var i = 0;i < count; i++){
            var slicearray = inputData.slice(chunkstart, chunkend);
            var uploadObject={};
            if (component.get("v.sObjectName") === $A.get("$Label.c.CRM_OpportunityLineItem_Name")){
                uploadObject ={
                    ObjectName__c :component.get("v.sObjectName"),
                    InputObjectData__c:JSON.stringify(slicearray),
                    DealId__c:component.get("v.objectId"),
                    status__c:'InProgress',
                    Total_Count__C:slicearray.length
                }
            }else{
                  uploadObject ={
                    ObjectName__c :component.get("v.sObjectName"),
                    InputObjectData__c:JSON.stringify(slicearray),
                    credit_Note_Id__c:component.get("v.objectId"),
                    status__c: $A.get("$Label.c.CRM_InProgressLabel"),
                    Total_Count__C:slicearray.length
                }
            }
            uploadList.push(uploadObject);
            chunkstart=chunkend;
            chunkend=chunkend+chunk;
        }
        var insertAction = component.get("c.uploadObjects");
        insertAction.setParams({
            uploadObjectList : JSON.stringify(uploadList),
            objectName:component.get("v.sObjectName"),
            dealId:component.get("v.objectId"),
            totalRecord:inputData.length
        });
        insertAction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.parentId", response.getReturnValue());
                if(inputData.length> $A.get("$Label.c.CRM_Excel_Batch_Input")){
                component.set("v.disableUpload", false);
                component.set("v.pageSpinner", false);
                component.find('notifLib').showToast({
                    "variant": "success",
                    "title": "Upload Success!",
                    "message": $A.get("$Label.c.CRM_Excel_Upload_File_Upload")
                });
                component.set("v.totalCount", inputData.length);
                }
            }
        });
        $A.enqueueAction(insertAction);
        if(inputData.length<= $A.get("$Label.c.CRM_Excel_Batch_Input")){
            component.set("v.pageSpinner", false);
            component.find('notifLib').showToast({
                "variant": "success",
                "title": "Upload Success!",
                "message": $A.get("$Label.c.CRM_Excel_Upload_File_Upload")
            });
            component.set("v.disableUpload", true);
            component.set("v.totalCount", inputData.length);
        	component.set("v.value", 5);
        	component.set("v.showRing", true);
        }
    },
    callBatchMethod : function(component, event, helper, parentId) {
        var opp = component.get("v.oppDetails");
        var recordType = opp!==null? opp.RecordType.Name :'';
        var action = component.get("c.callBatchClass");
        action.setParams({
            parentId:parentId,
            recordType: recordType
        });
        action.setCallback(this, function(response){
            var state = response.getState();
        });
        $A.enqueueAction(action);
    },
    increment : function(component, event, helper) {
        if(component.get("v.value") < 100){
            var action = component.get("c.getUploadProcessProgress");
            action.setParams({
                parentId:component.get("v.parentId")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var result = response.getReturnValue();
                    var progress = (result.Processed_Count__c/result.Total_Count__c)*100;
                    if(isNaN(progress)){
                        var value =component.get("v.value");
                        if (value<85){
                            progress=value+5;
                        }else{
                            progress=value;
                        }
                    }
                    component.set("v.value", progress);
                    if(progress>=100){
                        component.set("v.showRing", false);
                        component.set("v.disableUpload", false);
                        component.set("v.successCount", result.Success_Count__c);
                        if(result.Success_Count__c < result.Total_Count__c){
                            var errorCount = result.Total_Count__c-result.Success_Count__c;
                            component.set("v.errorCount", errorCount);
                            var msg = $A.get("$Label.c.CRM_Excel_Upload_Validation_Error");
                            msg = msg.replace("<errorCount>", errorCount);
                            msg = msg.replace("<totalCount>", result.Total_Count__c);
                            component.set("v.message", msg);
                           // component.set("v.errorData", result.Comment__c);
                        }else{
                            var msg = $A.get("$Label.c.CRM_Excel_Upload_Success");
                            msg = msg.replace("<successCount>", result.Success_Count__c);
                            msg = msg.replace("<totalCount>", result.Total_Count__c);
                            component.set("v.errorCount", 0);
                            component.set("v.message", msg);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
   convertArrayOfObjectsToCSV : function(component, helper, result) {
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if (result === null || !result.length) {
            return null;
        }
        columnDivider = ',';
        lineDivider =  '\n';
        var tablecol = component.get("v.columns");
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
        var opp = component.get("v.oppDetails");
        var recordType = opp!== null? opp.RecordType.Name :"POSCreditNoteItem";
        //--W-017642-Added if condition to check JV sales org and set JV related fieldset name for JV project-Start--//
         var fieldSet = '';
        if(opp!== null && component.get("v.isJVSalesOrg")){
            fieldSet = recordType.replace('/','').split(" ").join("") + "_JV_fieldSetName";
        }else{
            fieldSet = recordType.replace('/','').split(" ").join("") + "_fieldSetName";
        }
        //--W-017642-Added if condition to check JV sales org and set JV related fieldset name for JV project-End--//        
        var action = component.get("c.getExportFieldSet");
        action.setParams({
            sObjectName : component.get("v.sObjectName"),
            fieldSetName : fieldSet
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.columns", JSON.parse(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },
    getPermissionDetails : function(component, event, helper){
        var action = component.get("c.getPermissionDetails");
        var permissionObjectName="";
        if (component.get("v.sObjectName") === $A.get("$Label.c.CRM_OpportunityLineItem_Name")){
            permissionObjectName= "Opportunity";
        }else{
            permissionObjectName= "Credit_Note__c";
        }
        action.setParams({
            SObjectName: permissionObjectName
        });
        action.setCallback(this, function(response){
            var state1 = response.getState();
            if(state1 === "SUCCESS"){
                var perm = response.getReturnValue();
                // component.set("v.permissionDetails",response.getReturnValue());
                if(perm[0].PermissionsCreate === false && perm[0].PermissionsEdit === false){
                    component.set("v.disableUpload", true);
                }
                helper.getColumnNames (component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    //--W-017642-Added if condition to check JV sales org and set JV related fieldset name for JV project-Start--//
    checkJVSalesOrg : function(component, event, helper){
        var action = component.get("c.isJVSalesOrgForUpload");
        action.setParams({
            dealSalesOrg: component.get("v.oppDetails").Sales_Organisation__c
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