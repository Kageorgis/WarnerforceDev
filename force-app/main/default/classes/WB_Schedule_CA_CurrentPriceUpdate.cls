global class WB_Schedule_CA_CurrentPriceUpdate  implements Schedulable{

    global void execute(SchedulableContext contextInstance) {
        WB_Batch_ClientAvail_CurrentPriceUpdate batchInstance = new WB_Batch_ClientAvail_CurrentPriceUpdate ();
        Database.executebatch(batchInstance);
    }
}