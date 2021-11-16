({
    doInit : function(component, event, helper){
        var recordId = component.get('v.recordId'); 
        var querystring = location.search.substr(1);
        if(querystring != null){
            querystring.split("&").forEach(function(part){
                var param = part.split("=");
                if(param[0]=='c__fr' && param[1]=='1'){
                  window.setTimeout(
                        $A.getCallback(function() {
                    		$A.get('e.force:refreshView').fire();          
                        }), 100
                    );      
                }
                if(param[0]=='c__fr' && param[1]=='2'){
                    
                    window.setTimeout(
                        $A.getCallback(function() {
                            var editRecordEvent = $A.get("e.force:editRecord");
                            editRecordEvent.setParams({
                                "recordId": recordId,
                            });
                            editRecordEvent.fire();
                        }), 2000
                    ); 
                    
                    var urlEvent = $A.get("e.force:navigateToSObject");
                    urlEvent.setParams({
                        "recordId": recordId,
                        "isredirect": "true"
                    });
                    urlEvent.fire();                    
                }
            });
        }
    }
})