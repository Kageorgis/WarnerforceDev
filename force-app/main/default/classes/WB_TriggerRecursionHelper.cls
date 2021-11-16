public class WB_TriggerRecursionHelper {
    public static Boolean releasePlanRecursiveUpdate = false; 
    public static Boolean mpmRecursiveUpdate = false;
    //ER-002171 : Flag for monitoring roll up flag   
    public static Boolean isBatchWB_Batch_MPMRD_Rollup = false;
    //ER-002734 Start
    //Flag added to stop creation or updation of MRD country records
    public static Boolean mrdRecursiveUpdateTrigger = false;
    //Flag added to stop creation or updation of MRD country records when Roll Up batch is Running
    public static Boolean wbBatchMPMRDRollup = false;
    //ER-002734 End
    
}