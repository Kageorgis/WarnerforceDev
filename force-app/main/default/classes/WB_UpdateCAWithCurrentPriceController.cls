public with sharing class WB_UpdateCAWithCurrentPriceController {

    public PageReference RunBatch() {
        WB_Batch_ClientAvail_CurrentPriceUpdate batchInstance = new WB_Batch_ClientAvail_CurrentPriceUpdate ();
        Database.executebatch(batchInstance);
        return null;
    }

}