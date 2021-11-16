/**
* Created by XMMORENO on 3/26/2020.
*/

trigger CP_ProductTrigger on CP_Product__c(before insert, before update, after insert, after update){
    
    if(trigger.isInsert){

        if(trigger.isBefore){
            CP_ProductTriggerSequenceController.executeBeforeInsert(trigger.new);
        }

        if(trigger.isAfter){
          String Batchsize = Label.WBCP_Product_Share_Batch_Size;
             if(!Test.isRunningTest()){
                WBCP_Batch_CP_ProductSharing wb1 = new WBCP_Batch_CP_ProductSharing(Trigger.New,CP_ProductUtility.WBCP_LOCAL); 
                database.executeBatch(wb1,integer.ValueOf(Batchsize));
                 }
            if(!Test.isRunningTest()){            
           WBCP_Batch_CP_ProductSharing wb = new WBCP_Batch_CP_ProductSharing(Trigger.New,CP_ProductUtility.WBCP_REGIONAL); 
           database.executeBatch(wb,integer.ValueOf(Batchsize));
                }
        }
    }
    
    if(trigger.isUpdate){
       if(trigger.isBefore){
            CP_ProductTriggerSequenceController.executeBeforeUpdate(trigger.new, trigger.oldMap);
        }
    }
    
}