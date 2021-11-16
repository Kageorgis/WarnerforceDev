({
    loadData: function (component) {
        var categories = component.get('v.categories');
        var data = component.get('v.data');
        var searchOnTable = component.get('v.searchOnTable');
        if(searchOnTable != '') {
            data = this.filterBySearchKey(data,searchOnTable);
        }
        var dataByCategories = {};
        for(var i=0; i<categories.length; i++) {
            var category = categories[i];
            var categoryId = category.replace(/ /g,'');
            var dataByCategory = this.filterByCategory(data,category);
            dataByCategories[categoryId] = dataByCategory;
        }
        component.set('v.dataByCategories',dataByCategories);
        component.set('v.tabs',[]);
        setTimeout($A.getCallback(function () {
            component.set('v.searching',false);
        }),800);
        this.loadTabs(component,dataByCategories);
    },
    
    filterBySearchKey: function (data, searchKey) {
        var dataResult = [];
        searchKey = searchKey.toLowerCase();
        for(var row in data) {
            var insert = -1;
            if(data[row].hasOwnProperty('Related_Contacts__r.WBSF_Contact__r.Name')) {
                var contactName = data[row]['Related_Contacts__r.WBSF_Contact__r.Name'];
                contactName = contactName.toLowerCase();
                insert = contactName.search(searchKey);
            }
            if(data[row].hasOwnProperty('Related_Companies__r.WBSF_Company__r.Name')) {
                var companyName = data[row]['Related_Companies__r.WBSF_Company__r.Name'];
                companyName = companyName.toLowerCase();
                insert = companyName.search(searchKey);
            }
            if(insert != -1) dataResult.push(data[row]);
            else {
                var dealName = data[row].Name;
                dealName = dealName.toLowerCase();
                insert = dealName.search(searchKey);
                if(insert != -1) dataResult.push(data[row]);
            }
        }
        return dataResult;
    },
    
    filterByCategory: function (data,category) {
        var dataByCategory = [];
        for(var row in data) {
            if(data[row].WBSF_Project_Phase__c === category) dataByCategory.push(data[row]);
        }
        return dataByCategory;
    },
    
    loadTabs: function (component,dataByCategories) {
        component.set('v.hideDummy',false);
        var categories = component.get('v.categories');
        for(var i=0; i<categories.length; i++) {
            var category = categories[i];
            var categoryId = category.replace(/ /g,'');
            var count = dataByCategories[categoryId].length;
            category = category+' ('+count+')';
            $A.createComponent('lightning:tab', {
                'id': categoryId,
                'label': category,
                'onactive': component.getReference('c.handleActiveTab')
            }, function (tab, status, error) {
                if (status === "SUCCESS") {
                    var tabs = component.get('v.tabs');
                    tabs.push(tab);
                    component.set('v.tabs', tabs);
                } else {
                    throw new Error(error);
                }
            });
        }
    },
    
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.dataTable");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.dataTable", data);
    },
    
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
        }
    }
})