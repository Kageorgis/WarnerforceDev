@isTest
private class WB_MultiselectControllerTest{
    
    
    static testMethod void testMultiselectController() {
        WB_MultiselectController c = new WB_MultiselectController();
        
        c.leftOptions = new List<SelectOption>();
        c.rightOptions = new List<SelectOption>();

        c.leftOptionsHidden = 'A&a&b&b&C&c';
        c.rightOptionsHidden = '';
        
        System.assertEquals(c.leftOptions.size(), 3);
        System.assertEquals(c.rightOptions.size(), 0);
    }
}