/**
 * Created by XMMORENO on 5/21/2020.
*/

({
    buildGrid : function(cmp,evt,rowData){
        var spinner = cmp.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var files = rowData;
        var valueSets = cmp.get("v.valSets");
        var defaultLicensee = valueSets[0].defaultLicensee;
        if(defaultLicensee){
            for(var f in files){
                files[f].Licensee_Name = defaultLicensee;
            }
        }
        cmp.set("v.rowCount",files.length);
        cmp.set("v.gridData",files);
        var gridRef = cmp.get("v.gridRef");
        gridRef.gridOptions.api.setRowData([]);
        gridRef.gridOptions.api.applyTransaction({add:files});
        cmp.set("v.gridRef",gridRef);
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    saveRecords : function(cmp,evt){
        var gridRef = cmp.get("v.gridRef");
        var gridData = cmp.get("v.gridData");
        var rows = []
        gridRef.gridOptions.api.forEachNode(function(rowNode, index){
            rows.push(rowNode.data);
        });
        var action = cmp.get("c.saveProducts");
        action.setParams({productWrapperTableData:rows})
        action.setCallback(this, function(response){
            var state = response.getState();
            var failedRecs = [];
            var blankRow = {
                'Validation':"",
                'Licensee Name':"",
                'Country':"",
                'GTIN (UPC/ISBN)':"",
                'MPN':'',
                'Retailer':'',
                'Retailer SKU (ASIN,Prime)':"",
                'Licensed Property':"",
                'Item Description':"",
                'Sub-Category':"",
                'Buyer Name':"",
                'RSP ($)':"",
                'Gender':"",
                'Demo':"",
                'Size':"",
                'Set Date':"",
                'Retired Date':"",
                'Product Status':"",
                'Flow-Through':"",
                'FT Start Date':"",
                'FT End Date':"",
                'Promotional':"",
                'PM Start Date':"",
                'PM End Date':""
            }
            if(state === "SUCCESS"){
                var spinner = cmp.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                var dbResults = response.getReturnValue();
                var starRecs = [];
                var succRecs =[];
                var totalSuceessRec = 0;
                for(var i =0;i<dbResults.length;i++){
                    var flag = false;
                    if(dbResults[i].errorOccured && (dbResults[i].Validation.includes('Record is duplicating with CP Product:'))){
                        totalSuceessRec += 1;
                    }else if(dbResults[i].Validation != 'Product created successfully, But UPC not present in starlab' && dbResults[i].Validation != 'Product created successfully'){
                        failedRecs.push(dbResults[i]);
                        flag = true;
                    }
                    if(dbResults[i].Validation == 'Product created successfully, But UPC not present in starlab'){
                        starRecs.push(dbResults[i])
                    }
                    if(dbResults[i].Validation == 'Product created successfully'){
                        succRecs.push(dbResults[i]);  
                    }                    
                    if(flag){
                        if(dbResults[i].Validation.includes('missing: [Licensee')){
                            dbResults[i].Validation = dbResults[i].Licensee_Name +' was not found. Please check Spelling or use Licensee Lookup.'
                        }
                        if(dbResults[i].Validation.includes('WBCP Country')){
                            dbResults[i].Validation = dbResults[i].Country +' was not found. Please spell out the country(ie.United States)'
                        }
                        if(dbResults[i].Validation.includes('Retailer Description')){
                            dbResults[i].Validation = dbResults[i].Retailer +' was not found. Please check the spelling or pick from the dropdown.'
                        }
                        if(dbResults[i].Validation.includes('missing: [Licensed Property')){
                            dbResults[i].Validation = dbResults[i].Licensed_Property +' was not found. Please check Spelling or use Property Lookup.'
                        }
                    }
                }                
                totalSuceessRec = totalSuceessRec + starRecs.length + succRecs.length;
                cmp.set('v.failedRecords', failedRecs.length);
                cmp.set('v.starLabsRecords',starRecs.length);                
                cmp.set('v.savedRecords', totalSuceessRec);
                var pendingRec = rows.length - totalSuceessRec;
                cmp.set('v.rowCount', pendingRec);
                gridRef.gridOptions.api.setRowData(failedRecs);
                cmp.set(('v.gridData'),dbResults);
                if(pendingRec == 0){
                    var newRow = [];
                    newRow.push(blankRow);
                    gridRef.gridOptions.api.applyTransaction({add:newRow});
                }
            }else if(state === "INCOMPLETE"){
                // do something
            }else if(state === "ERROR"){
            	var errors = response.getError();
                if(errors){
              		if(errors[0] && errors[0].message) {
                    	var spinner = cmp.find("mySpinner");
                        $A.util.toggleClass(spinner, "slds-hide");
                        this.openErrorModal(cmp,evt,errors[0].message);
                    }
                 }else{
                 	console.log("Unknown error");
                 }
            }
        });
        $A.enqueueAction(action);
    },
    
    copyTextHelper : function(component,event,text){
        var hiddenInput = document.createElement("input");
        hiddenInput.setAttribute("value", text);
        document.body.appendChild(hiddenInput);
        hiddenInput.select();
        document.execCommand("copy");
        document.body.removeChild(hiddenInput);
        var orignalLabel = event.getSource().get("v.label");
        event.getSource().set("v.iconName" , 'utility:check');
        event.getSource().set("v.label" , 'copied');
        setTimeout(function(){
            event.getSource().set("v.iconName" , 'utility:copy_to_clipboard');
            event.getSource().set("v.label" , orignalLabel);
        }, 700);
    },
    
    openErrorModal:function(cmp,evt, msg){
        if(msg == 'No Data Entered'){
            var gridVal = true
        }else{
            var gridVal = false
        }
        $A.createComponent(
            "c:cp_errorModal",
            {
                "aura:id": "errMod",
                "isOpen": true,
                "errorMessage": msg,
                "noGridData": gridVal
            },
            function(newButton, status, errorMessage){
                if(status === "SUCCESS"){
                    var body = cmp.get("v.body");
                    body.push(newButton);
                    cmp.set("v.body", body);
                }else if(status === "INCOMPLETE"){
                    console.log("No response from server or client is offline.")
                }else if(status === "ERROR"){
                    console.log("Error: " + errorMessage);
                }
            });
    }
});