({
    filterMethod : function(component, event, helper) {
        var filteredData = component.get("v.fullData");
        var fields = component.get("v.dataFields");
        var searchdata= component.get("v.searchedData");
        var fldName = component.get("v.queryFieldName");
        var arrayMapKeys = [] ;
        var regex ;
        regex = new RegExp("true", "i");
        fields.filter(function(rows){
            if(regex.test(rows["Searchable__c"]) && fldName.indexOf(rows.Field_Name__c)!== -1){
                if(rows.Type__c === "Picklist"){
                    var value = [] ;
                    for(var key in filteredData){
                        var i = (searchdata).map(function(o){return o.key.Field_Name__c}).indexOf(rows.Field_Name__c);
                        var filteredDataValue = "";
                        filteredDataValue = helper.getfilteredDataValue(key, rows.Field_Name__c, value, filteredData);
                        var j = value.map(function(o){return o.val}).indexOf(filteredData[key][rows.Field_Name__c]);
                        if( i > -1){
                            if(filteredDataValue){
                                if((searchdata[i].value).includes(filteredDataValue)){
                                    if(j === -1){
                                        component.get("v.selectedboxes").push({key : rows.Field_Name__c, value : filteredDataValue});
                                        value.push({val: filteredDataValue, checked: true });}}
                                else
                                    if(j === -1){
                                        value.push({val: filteredDataValue, checked: false  });
                                    }
                            }
                        }
                        else if(j === -1){
                            if(filteredDataValue)
                                value.push({val: filteredDataValue, checked: false });
                        }
                    }
                    arrayMapKeys.push({key: rows, value: value });
                }
                else{
                    var value="";
                    if(searchdata.length>0){
                        var i = (searchdata).map(function(o){return o.key.Field_Name__c}).indexOf(rows.Field_Name__c);
                        value = i > -1 ? searchdata[i].value:"";
                    }
                    arrayMapKeys.push({key: rows, value: {val:value.toString() }});
                }
            }
        });
        component.set("v.searchfieldsList", (arrayMapKeys));
    },
    getfilteredDataValue : function(key, fieldName, value, filteredData){
        return (fieldName).includes(".") ?
            value.map(function(o){return o.val}).indexOf(filteredData[key][fieldName.split(".")[0]][fieldName.split(".")[1]]) === -1 ?
            filteredData[key][fieldName.split(".")[0]][fieldName.split(".")[1]] : '' : filteredData[key][fieldName];
    },
    getMetaDataFields : function(component, event, helper){
        var action = component.get("c.getOpptyLineItemFilter");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.dataFields", (response.getReturnValue()));
            }
            helper.filterMethod(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    getSearchResults : function(component, event, helper){
        var map = {} ;
        var badge = component.get("v.badgelist");
        var dsFields = component.get("v.dataFields");
        var sizeOfMap = badge.length;
        var whereCondition = " WHERE opportunityId = " + "'" + component.get("v.opptId") + "'" + " AND " ;
        for(var b in badge){
            for(var f in dsFields){
                if(dsFields[f].Field_Name__c === badge[b].key){
                    if(dsFields[f].Type__c === "Picklist"){
                        var pLval ="";
                        var len = badge[b].value.length;
                        for(var val in badge[b].value){
                            if((badge[b].value[val]).includes("\'")){
                                var v = badge[b].value[val];
                                var j = "\'";
                                v = v.replace( new RegExp(j, "g"),"\\'");
                                pLval += "'"+v+"'";
                            }else{
                            	pLval += "'"+badge[b].value[val]+"'";
                            }
                            if(len - 1 !== 0)
                                pLval += ",";
                            len--;
                        }
                        whereCondition += badge[b].key + " IN " + "("+pLval+")";
                    }
                    else if(dsFields[f].Type__c === "String"){
                        var sVal ="";
                        if((badge[b].value[0]).includes("\'")){
                                var v = badge[b].value[0];
                                var j = "\'";
                                v = v.replace( new RegExp(j, "g"),"\\'");
                                sVal += v;
                            }else{
                            	sVal += badge[b].value[0];
                            }
                        whereCondition += badge[b].key +" LIKE " +"'"+"%"+ (sVal) +"%"+"'";
                    }
                        else if(dsFields[f].Type__c === "Date"){
                            var dateOption = component.get("v.selectedOption");
                            var operator = "";
                            if(dateOption === "Equals")
                                operator = "=";
                            else if(dateOption === "Greaterthan")
                                operator = ">";
                                else if(dateOption === 'Lessthan')
                                    operator = "<";
                            whereCondition += badge[b].key + " "+operator+ " "+badge[b].value ;
                        }
                            else
                                whereCondition += badge[b].key + " = "+badge[b].value ;
                }
            }
            if(!(sizeOfMap - 1 === 0))
                whereCondition += " AND ";
            sizeOfMap--;
        }
        map=badge;
        var mapKey =[];
        var searchfieldValues = component.get("v.searchfieldsList");
        for(var listValue in map){
            var i = searchfieldValues.map(function(o){return o.key.Field_Name__c}).indexOf(map[listValue].key);
            if(i>-1 && map[listValue].key === searchfieldValues[i].key.Field_Name__c){
                var label = { label : searchfieldValues[i].key.Label, Field_Name__c: map[listValue].key };
                mapKey.push({key: label, value: map[listValue].value });
            }
        }
        component.set("v.searchedData", (mapKey));
        var action = component.get("c.getDealData");
        action.setParams({
            whereCondition : whereCondition,
            tablColNames : JSON.stringify(component.get("v.queryFieldName")),
            sObjectName : component.get("v.sObjectName")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            component.set("v.data", response.getReturnValue());
            component.set("v.length", response.getReturnValue().length);
        });
        $A.enqueueAction(action);
    }
})