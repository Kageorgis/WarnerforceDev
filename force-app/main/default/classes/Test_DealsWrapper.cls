@IsTest
private class Test_DealsWrapper {
    static testMethod void validatedDealsWrapper() {
        DealsWrapper.Table newTable = new DealsWrapper.Table();
        DealsWrapper.View newView = new DealsWrapper.View();
        DealsWrapper.Column newColumn = new DealsWrapper.Column();
        DealsWrapper.Filter newFilter = new DealsWrapper.Filter();
        DealsWrapper.StudioUser newStudioUser = new DealsWrapper.StudioUser();
        Boolean validate = true;
        if(!newTable.data.isEmpty()) { validate = false; system.debug('data error'); }
        if(!newView.value.equals('')) { validate = false; system.debug('view error'); }
        if(newColumn.width <> 0) { validate = false; system.debug('column error'); }
        if(!newFilter.value.equals('')) { validate = false; system.debug('filter error'); }
        if(!newStudioUser.value.equals('')) { validate = false; system.debug('data error'); }
        System.assertEquals(true, validate);
    }
}