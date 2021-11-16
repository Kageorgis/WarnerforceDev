({
	init : function(component, event, helper) {
        var pageRef = component.get("v.pageReference");
        var objId = pageRef!==null?pageRef.state.c__Id:component.get("v.objectId");
        var objName = pageRef!==null?pageRef.state.c__objectName:component.get("v.sObjectName");
        var creditNoteName = pageRef!==null?pageRef.state.c__pageName:component.get("v.creditNoteName");
        component.set("v.sObjectName", objName);
        component.set("v.objectId", objId);
        component.set("v.creditNoteName", creditNoteName);
        if (objName === $A.get("$Label.c.CRM_OpportunityLineItem_Name")){
            helper.getOpptDetails(component, event, helper);
        }else{
             helper.getColumnNames (component, event, helper);
        }
    },
     reInit : function(component, event, helper){
        $A.get('e.force:refreshView').fire();
        var a = component.get('c.init');
        $A.enqueueAction(a);
    },
  callBatchProcess: function(component, event, helper) {
       if(component.get("v.totalCount")<= $A.get("$Label.c.CRM_Excel_Batch_Input")){
          helper.callBatchMethod(component, event, helper, component.get("v.parentId"));
           // execute again after 5 sec each
          var inVar=  window.setInterval(
                $A.getCallback(function() {
                    if(component.get("v.value")===100){
                        window.clearInterval(inVar);
                    }
                    else{
                        helper.increment(component, event, helper);
                    }
                }), 10000
            );
        }
    },
    upload: function(component, event, helper) {
        var file = component.get("v.FileList");
        if(file[0].size >= $A.get("$Label.c.CRM_File_Upload_Size_Limit")){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: 'error',
                "message": $A.get("$Label.c.CRM_File_Upload_Limit_Error_Msg")
            });
            toastEvent.fire();
        }else{
        component.set("v.errorData", '');
        component.set("v.pageSpinner", true);
        event.stopPropagation();
        event.preventDefault();
        const reader = new FileReader();
        reader.onload = function (e) {
            var binary = "";
            var bytes = new Uint8Array(e.target.result);
            var length = bytes.byteLength;
            for(var i = 0; i < length; i++) {
                binary += String.fromCharCode(bytes[i]);
            }
            var workbook = XLSX.read(binary, {
                type: 'binary', cellDates:true, cellStyles:true
        });
            var sheet_name_list = workbook.SheetNames;
            var input = XLSX.utils.sheet_to_json(workbook.Sheets[$A.get("$Label.c.CRM_Upload_Sheet_Name_Deal_Products")]);
            helper.validateExcel(component, event, helper, input);
        };
        reader.readAsArrayBuffer(file[0]);
        }
},
    fireComponentEvent : function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
        cmp.set("v.value", 0);
    },
    exportErrorData : function(component, event, helper) {
        var action = component.get("c.getUploadObjects");
        action.setParams({
            uploadId : component.get("v.parentId"),
            status : "Failed"
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultList = response.getReturnValue();
                if(resultList !== null && resultList !== '' && resultList !== undefined)
                {
                    var csvDataList=[];
                    for(var i=0;i<resultList.length;i++){
                        csvDataList.push(JSON.parse(resultList[i]));
                    }
                    var csv = helper.convertArrayOfObjectsToCSV(component,helper, csvDataList);
                    if(csv === null){return;}
                    var hiddenElement = document.createElement('a');
                    hiddenElement.href = 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(csv);
                    hiddenElement.target = '_blank';
                    hiddenElement.download = "ErrorReport.csv";
                    document.body.appendChild(hiddenElement);
                    hiddenElement.click();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.CRM_SuccessLabel"),
                        type: 'success',
                        "message": "Error Report Downloaded."
                    });
                    toastEvent.fire();
                }
                
            }
        });
        $A.enqueueAction(action);
	
	},
    backToDeal: function(component, event, helper) {
        var labelName = event.getSource().get("v.label");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.objectId")
        });
        navEvt.fire();
    }
})