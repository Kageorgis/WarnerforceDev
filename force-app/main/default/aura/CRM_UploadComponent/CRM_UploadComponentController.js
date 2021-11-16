({
    init : function(component, event, helper) {
        component.set("v.spinner", true);
        var myRef = component.get("v.pageReference");
        var myid = myRef.state.c__Id;
        var mySON = myRef.state.c__sON;
        var patt = /\W/g;
        var finalSON = mySON!==null? mySON.replace(patt, ''):$A.get("$Label.c.CRM_OpportunityLineItem_Name");
        component.set("v.sObjectName", finalSON);
        if(myid!==null){
            component.set("v.objectId", myid);
        }
        helper.getOpptDetails(component, event, helper);
    },
    reInit : function(component, event, helper){
        $A.get('e.force:refreshView').fire();
        var a = component.get('c.init');
        $A.enqueueAction(a);
    },
    cancel : function(component, event, helper){
        $A.get('e.force:refreshView').fire();
    },
    delSelectedRecord : function(component, event, helper){
        component.set("v.spinner", true);
		var dataDeletedList = [];
        var recIds = [];
        var getRecId = component.find("checkbox");
        var checkboxes = (getRecId.length == null) ? [getRecId] : getRecId;
        checkboxes.forEach(checkbox => checkbox.get("v.value") ? recIds.push(checkbox.get("v.text")) :'');
        var dataDeleted = recIds;
        for(var record in dataDeleted){
          var wrapperRecord ={
                     lineItem :dataDeleted[record],
                     isRowRemoved :true,
                     isError:false
            	}
           dataDeletedList.push(wrapperRecord);
        }
        if(recIds.length > 0){
            helper.deleteRecords(component, event, helper, dataDeletedList);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: 'info',
                "message": "Please select atleast one record."
            });
            toastEvent.fire();
            component.set("v.spinner", false);
        }
    },
    save: function(component, event, helper){
        component.set("v.spinner", true);
        var dataupdatedList = [];
        var dataupdated = component.get("v.editedRecords");
        var updatedIds=[];
        for(var record in dataupdated){
          //  dataupdatedList.push(dataupdated[record]);
          var wrapperRecord ={
                     lineItem :dataupdated[record],
                     isRowModified :true,
                     isError:false
            	}
           dataupdatedList.push(wrapperRecord);
        }
        if(dataupdatedList.length > 0){
            helper.saveRecords(component, event, helper, dataupdatedList);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: 'info',
                "message": "No Record Edited."
            });
            toastEvent.fire();
            component.set("v.spinner", false);
        }
    },
    handleSearch : function(component, event, helper){
        component.set("v.searchPagination", true);
        var cmpfind = component.find("ser");
        var searchValue = component.get("v.searchText");
        var searchdata = component.get("v.fullData");
        if(searchValue !== ""){
            var tableCol = component.get("v.columns");
            var searchCol =[];
            for(var i =0 ; i < tableCol.length ; i++){
                searchCol.push(tableCol[i].fieldName);
            }
            var searchTemp = searchdata;
            var regex ;
            regex = new RegExp(searchValue, "i");
            searchTemp = searchdata.filter(function(rows){
                for(var i=0 ;i<searchCol.length;i++){
                    if((searchCol[i]).includes(".")){
                        if(regex.test(rows[searchCol[i].split(".")[0]][searchCol[i].split(".")[1]]))
                            return true;
                    }
                    else if(regex.test(rows[searchCol[i]]) )
                    {
                        return true;
                    }
                }
                return false;
            });
            component.set("v.length", searchTemp.length);
            component.set("v.data", searchTemp);
            cmpfind.onchange();
        }
        else{
            var fullData = component.get("v.fullData");
            component.set("v.data", fullData);
            component.set("v.length", fullData.length);
            cmpfind.onchange();
        }
    },
    handleImportComponentEvent : function(component, event, helper){
        var message = event.getParam("message");
        helper.getdata(component, event, helper);
    },
    advancedSearch : function(component, event, handler){
        var aSChildCall = component.find("advancedSearch");
        component.set("v.ChildCall", true);
        aSChildCall.callAdvancedSearch();
    },
    clearAll :function(component, event, helper){
        component.set("v.badgelist", []);
        component.set("v.searchedData", []);
        var fullData = component.get("v.fullData");
        component.set("v.data", fullData);
        component.set("v.length", fullData.length);
        component.find("ser").onchange();
    },
    showRecordError :function(component, event, helper){
        var record = event.getSource().get("v.value");
        component.set("v.showError", true);
        component.set("v.validationError", record.validation);
    },
    handleCloseModal : function(component, event, helper){
        component.set("v.showError", false);
    }
});