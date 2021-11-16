({
	getEmailTemplateHelper: function (component, event) {
		
        var action = component.get("c.getEmailTempaltes");
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('Response : ',response.getReturnValue());
            component.set('v.loaded',false);
            var optionList = [{label:'All' , value:'All'}];
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                var tempList = [];
                var emailfolderVSTemplateList = response.getReturnValue();
                console.log('emailfolderVSTemplateList:::',emailfolderVSTemplateList);
                emailfolderVSTemplateList.forEach(function (element) {
                    tempList.push.apply(tempList,element.emailtemplatelist);
                    var option = {label:element.folderName , value:element.folderId};
                    optionList.push(option);
                });
                component.set("v.emailTemplateList", tempList);
                component.set("v.emailfolderVSTemplateList", response.getReturnValue());
                component.set("v.folderOptions", optionList);
            }
            else if (state === "INCOMPLETE") {
                system.debug('INCOMPLETE');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log("Error message: ",errors[0].message);
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    
    // Used to sort the 'Template Name' column
    sortBy: function(field, reverse, primer) {
        var key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },

    handleSort: function(component, sortedBy, sortDirection) {
        console.log('--> Sort ',sortedBy,'---',sortDirection);
        
        var cloneData = component.get('v.emailTemplateList').slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        console.log('--> After Sort ',sortedBy,'---',sortDirection);
        
        component.set('v.emailTemplateList', cloneData);
        component.set('v.sortDirection', sortDirection);
        component.set('v.sortedBy', sortedBy);
        component.set('v.loaded',false);
    },
    
    searchRecordsBySearchPhrase : function (component,searchPhrase) {
        var folderId = component.get("v.folderId");
        console.log(folderId,'--inside---',searchPhrase);
        if (!$A.util.isEmpty(searchPhrase)) {
            let allData = this.getTemplates(component,folderId);
            console.log(folderId,'--if---',allData);
            let filteredData = allData.filter(record => record.Name.includes(searchPhrase));
            component.set("v.emailTemplateList", filteredData);
        }else{
            console.log(folderId,'-else---',this.getTemplates(component,folderId));
            component.set('v.emailTemplateList',this.getTemplates(component,folderId));
        }
        var sortBy = component.get('v.sortedBy');
        var sortDirection = component.get('v.sortDirection');
        console.log('sortBy--> ',sortBy,'sortDirection--> ',sortDirection)
        this.handleSort(component,sortBy,sortDirection);
    },
    
    getTemplates: function(component,folderId){
        var emailfolderVSTemplateList = component.get("v.emailfolderVSTemplateList");
        var tempList = [];
        if(folderId == 'All'){
            emailfolderVSTemplateList.forEach(function (element) {
                tempList.push.apply(tempList,element.emailtemplatelist);
            });
        }else if (folderId != null && folderId != '' && folderId != 'undefined') {
            emailfolderVSTemplateList.forEach(function (element) {
                if (element.folderId == folderId) {
                    tempList = element.emailtemplatelist;
                }
            });
        } 
        return tempList;
    }
})