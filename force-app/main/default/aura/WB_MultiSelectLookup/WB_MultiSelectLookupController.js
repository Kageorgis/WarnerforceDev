({
    doInit : function(component,event,helper){
        var isSF1 = typeof sforce !== 'undefined';
        console.log('isSF1=======',isSF1);
        helper.loaddata(component,event);
    },
    
    onblur : function(component,event,helper){
        component.set("v.listOfSearchRecords", null );
        component.set("v.SearchKeyWord", '');
        component.set("v.SearchKeyWordCountry", '');
        var forclose = component.find("lookupCG");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        forclose = component.find("lookupC");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onfocus : function(component,event,helper){
        component.set("v.listOfSearchRecords", null ); 
        var forOpen = component.find("lookupCG");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        var forclose = component.find("lookupC");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    
    onfocusCountry : function(component,event,helper){
        component.set("v.listOfSearchRecordsCountry", null ); 
        var forOpen = component.find("lookupC");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        var forclose = component.find("lookupCG");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        var getInputkeyWord = '';
        helper.searchHelperCountry(component,event,getInputkeyWord);
    },
    
    keyPressController : function(component, event, helper) { 
        var getInputkeyWord = component.get("v.SearchKeyWord");
        if(getInputkeyWord.length > 0){
            var forOpen = component.find("lookupCG");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            var forclose = component.find("lookupC");
        	$A.util.addClass(forclose, 'slds-is-close');
        	$A.util.removeClass(forclose, 'slds-is-open');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("lookupCG");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
            var forclose = component.find("lookupC");
        	$A.util.addClass(forclose, 'slds-is-close');
        	$A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    keyPressControllerCountry : function(component, event, helper) { 
        var getInputkeyWord = component.get("v.SearchKeyWordCountry");
        if(getInputkeyWord.length > 0){
            var forOpen = component.find("lookupC");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            var forclose = component.find("lookupCG");
        	$A.util.addClass(forclose, 'slds-is-close');
        	$A.util.removeClass(forclose, 'slds-is-open');
            helper.searchHelperCountry(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecordsCountry", null );
            var forclose = component.find("lookupC");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
            var forclose = component.find("lookupCG");
        	$A.util.addClass(forclose, 'slds-is-close');
        	$A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    clear :function(component,event,heplper){
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.lstSelectedRecords"); 
        
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].Id == selectedPillId){
                AllPillsList.splice(i, 1);
                component.set("v.lstSelectedRecords", AllPillsList);
            }  
        }
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );      
    },
    
    handleComponentEvent : function(component, event, helper) {
        var spinnerCount = component.find("spinnerCountries");
        $A.util.addClass(spinnerCount, 'slds-show');
        $A.util.removeClass(spinnerCount, 'slds-hide');
        
        console.log('In handleComponentEvent---');
        component.set("v.SearchKeyWord",null);
        var selectedRecGetFromEvent = event.getParam("recordByEvent");
        helper.searchCountryGroupHelper(component, event, selectedRecGetFromEvent);
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        forclose = component.find("lookupCG");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        forclose = component.find("lookupC");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
    handleComponentEventCountry : function(component, event, helper) {
        var spinnerCount = component.find("spinnerCountries");
        $A.util.addClass(spinnerCount, 'slds-show');
        $A.util.removeClass(spinnerCount, 'slds-hide');
        
        console.log('In handleComponentEventCountry---');
        component.set("v.SearchKeyWordCountry",null);
        var selectedRecGetFromEvent = event.getParam("recordByEvent");
        helper.searchCountryGroupHelperCountry(component, event, selectedRecGetFromEvent);
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        forclose = component.find("lookupC");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        forclose = component.find("lookupCG");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
    save : function(component, event, helper) {
        helper.saveRecord(component, event);
		//location.reload();
	},
    
    clearAll : function(component, event, helper) {
        component.set("v.lstSelectedRecords", null)
        component.set("v.listOfSearchRecordsCountry", null );
        component.set("v.listOfSearchRecords", null );
        //helper.saveRecord(component, event);
		//location.reload();
	},
})