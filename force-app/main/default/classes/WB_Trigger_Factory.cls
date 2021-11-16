/*
Class Name : Trigger_Factory
Description  : This is the common class for all the trigger handler classes, it iterates 
               the Trigger values and pass them to respective handler classes.
Created By   : Cognizant Technology Solutions - Shekhar Vinayak
Created On   : 10th Aug 2015


Change History:
----------------------------------------------------------------------------------------------------------------------
Sr#      Description                     Updated By                         Updated On            Emp ID
----------------------------------------------------------------------------------------------------------------------
1        [Change Type]                   CTS - [Developer Name]             [MM/DD/YYYY]           


*/

public with sharing class WB_Trigger_Factory
{ 
    private static String handlerName = '';
    /**
     * Public static method to create and execute a trigger handler
     *
     * Arguments:   Schema.sObjectType soType - Object type to process (SObject.sObjectType)
     *
     * Throws a TriggerException if no handler has been coded.
     */
    public static void createHandler(Schema.sObjectType soType)
    {
            handlerName = String.valueOf(soType);
            WB_ITrigger handler = getHandler(soType);
            execute(handler);
     }
 
 
 
    /**
     * private static method to control the execution of the handler
     *
     * Arguments:   ITrigger handler - A Trigger Handler to execute
     */
    private static void execute(WB_ITrigger handler)
    {
        try
        {
            // Before Trigger
            if (Trigger.isBefore)
            {
                // Call the bulk before to handle any caching of data and enable bulkification
                handler.bulkBefore();
                
                // Iterate through the records to be deleted passing them to the handler.
               if (Trigger.isDelete)
                {
                     /*for (SObject so : Trigger.old)
                     {
                        system.debug(so);
                       handler.beforeDelete(so);
                    }*/
                }
                // Iterate through the records to be inserted passing them to the handler.
                else if (Trigger.isInsert)
                {
                    for (SObject so : Trigger.new)
                    {
                        handler.beforeInsert(so);
                    }
                }
                // Iterate through the records to be updated passing them to the handler.
                else if (Trigger.isUpdate)
                {
                     
                    for (SObject so : Trigger.old)
                    {
                       handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                    }
                }
            }
            else
            {
            // Shekhar changes
              // Call the bulk after to handle any caching of data and enable bulkification
                handler.bulkAfter();
                 
                // Iterate through the records deleted passing them to the handler.
                if (Trigger.isDelete)
                {
                    /*for (SObject so : Trigger.old)
                    {
                        handler.afterDelete(so);
                    }*/
                }
                // Iterate through the records inserted passing them to the handler.
                else if (Trigger.isInsert)
                {
                    for (SObject so : Trigger.new)
                    {
                        handler.afterInsert(so);
                    }
                }
                // Iterate through the records updated passing them to the handler.
                else if (Trigger.isUpdate)
                {
                    for (SObject so : Trigger.old)
                    {
                        handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                    }
                }
            
           } // else is completed
            
             // Perform any post processing
            handler.andFinally();
        }
          catch(Exception e){
            /*if(handlerName == null)
                handlerName = '';*/
            if(handlerName != 'User'){   
                String msg =  e.getMessage() +'\n' + e.getStackTraceString()  ;  
              }
        }
    }
    
      private static WB_ITrigger getHandler(Schema.sObjectType soType)
      {
        if (soType == Announcement_Rule__c.sObjectType)
        {
            return new WB_Announcementype_Handler();
        }else if (soType == EC_AnnouncementType__c.sObjectType)
        {
            return new WB_ECAnnouncementype_Handler();
        }  
        
        return null;
      }
 }