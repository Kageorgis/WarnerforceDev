@isTest
private class MultiSelectPicklistController_Test {

	private static testMethod void testmethod1() {
	    test.startTest();
        MultiSelectPicklistController ctrl = new MultiSelectPicklistController ();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('test','test'));
        options.add(new SelectOption('test1','test1'));
        options.add(new SelectOption('test2','test2'));
        ctrl.leftOptions = options;
        List<SelectOption> rightOptions = new List<SelectOption>();
        rightOptions.add(new SelectOption('test','test'));
        rightOptions.add(new SelectOption('test1','test1'));
        rightOptions.add(new SelectOption('test2','test2'));
        ctrl.rightOptions = rightOptions;
        ctrl.leftOptionsHidden = 'tr#ue&fal#se';
        ctrl.rightOptionsHidden = 'tr#ue&fal#se';
        ctrl.leftOptionsHidden = '';
        ctrl.rightOptionsHidden = '';
        test.stopTest();
	}

}