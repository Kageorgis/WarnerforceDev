({
	afterRender: function (component, helper) {
        this.superAfterRender();
        var mainH = (window.innerHeight - 157);
        var SLDSCTDivH = $A.get("$Label.c.Add_Attendees_Model_Height"); 
        if(SLDSCTDivH){
            if(SLDSCTDivH > mainH){
                SLDSCTDivH = mainH;
            }else if(SLDSCTDivH < 250){
                SLDSCTDivH = 250;
            }
            var footerH = component.find("footerDiv").getElement().offsetHeight;
            console.log('footerH',footerH,'---',SLDSCTDivH,'--',mainH);
            var ht = (SLDSCTDivH - footerH);
            component.set("v.divHeight", ht+"px");
        }
    } 
})