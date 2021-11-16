({
    doInit : function(component, event, helper){ 
		var myPageRef = component.get("v.pageReference");
        if(myPageRef){
            var frVar = myPageRef.state.fr;
            if(frVar){
                if(frVar==1){
                    myPageRef.state.fr=0;
                    component.set('v.pageReference',myPageRef);
                    $A.get('e.force:refreshView').fire();
                }
            } 
        }
	}
})