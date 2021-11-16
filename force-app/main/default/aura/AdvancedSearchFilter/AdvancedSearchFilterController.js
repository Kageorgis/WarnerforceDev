({
    init : function(component, event, helper) {
        helper.getMetaDataFields(component, event, helper);
        $A.enqueueAction(component.get("c.disableSearch"));
    },
    handleFilterCheckboxes: function(component, event, helper){
        var badge = component.get("v.badgelist");
        var i = badge.map(function(o){return o.key}).indexOf(event.getSource().get("v.name"));
        if(event.getSource().get("v.checked")){
            if(i > -1){
                (badge[i].value).push(event.getSource().get("v.value"));
            }
            else
                badge.push({key : event.getSource().get("v.name"), value : [event.getSource().get("v.value")]});
            badge.sort();
            component.set("v.badgelist", badge);
        }
        else if(!(event.getSource().get("v.checked"))){
            if(i > -1){
                (badge[i].value).splice((badge[i].value).indexOf(event.getSource().get("v.value")), 1)
            }
            component.set("v.badgelist", badge);
        }
        $A.enqueueAction(component.get("c.disableSearch"));
    },
    handleRemove : function(component, event, helper){
        var badgeList = component.get("v.badgelist");
        var removeId = event.getSource().get("v.label");
        var keyName = event.getSource().get("v.name");
        component.set("v.badgelist", badgeList);
        for(let v in badgeList){
            if(badgeList[v].key === keyName.key)
            {
                if(badgeList[v].value.length > 1){
                    (badgeList[v].value).splice((badgeList[v].value).indexOf(event.getSource().get("v.label")), 1);
                    break;
                }
                else{
                    badgeList.splice(v, 1);
                    break;
                }
                
            }
        }
        component.set("v.badgelist", badgeList);
        var arr=[];
        for(var iteration in badgeList){
            arr.push({key : {Field_Name__c : badgeList[iteration].key}, value : badgeList[iteration].value});
        }
        component.set("v.searchedData", arr);
        helper.filterMethod(component, event, helper);
        $A.enqueueAction(component.get("c.disableSearch"));
    },
    handleAdvancedSearch : function(component, event, helper){
        component.set("v.ChildCall", false);
        helper.getSearchResults(component, event, helper);
    },
    closeModel :function(component, event, helper){
        component.set("v.ChildCall", false);
    },
    disableSearch : function(component, event, helper){
        var search=component.find("searchId");
        var badge = component.get("v.badgelist");
        if(badge.length>0){
            search.set("v.disabled", false);
        }
        else
            search.set("v.disabled", true);
    },
    onChangeDate : function(component, event, helper){
        var selectValue = event.getSource().get("v.value");
        component.set('v.selectedOption', selectValue);
    },
    getValues : function(component, event, helper){
        var badge = component.get("v.badgelist");
        var i = badge.map(function(o){return o.key}).indexOf(event.getSource().get("v.name"));
        var dsValues = component.find("datevalue");
        if(i > -1)
            badge.splice(i, 1);
        if(event.getSource().get("v.value") !== '' )
            badge.push({key : event.getSource().get("v.name"),  value : [event.getSource().get("v.value")]});
        badge.sort();
        component.set("v.badgelist", badge);
        $A.enqueueAction(component.get("c.disableSearch"));
    }
})