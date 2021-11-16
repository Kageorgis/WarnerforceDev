/*********************************************************************************************************************************************************** 
CheckQuantitySaleDigitalProducts
Creation Date- 06 January 2017
Description- This class duplicate opportunity products
Author - Martín Mori
************************************************************************************************************************************************************/
public class DuplicateOpportunityProducts {
    public static void executeAfterInsert(List<OpportunityLineItem> listOpportunityLineItem) {
        System.debug(listOpportunityLineItem);
        // Create a Set from Opportunity Ids to Opportunity Line Items.
        Set<Id> setOpportunityId = new Set<Id>();
        // Create a Set from Opportunity Line Items.
        Set<Id> setOpportunityLineItemId = new Set<Id>();
        // Create a List from Opportunity Line Items. 
        List<OpportunityLineItem> listOpportunityId = new List<OpportunityLineItem>();
        for(OpportunityLineItem oOpportunityLineItem : listOpportunityLineItem){
            //Add Ids to Opportunity Line Items with repeate
            if(oOpportunityLineItem.Duplicate_Num_Week__c!=null) {
                setOpportunityId.add(oOpportunityLineItem.OpportunityId);
                setOpportunityLineItemId.add(oOpportunityLineItem.Id);
            }
        }
        
        if(setOpportunityId.size()>0) {
            //remove Ids to Opportunity Line Items with recordtype distict 'DC Deals'
            for(OpportunityLineItem oOpportunityLineItem : [SELECT Id, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :setOpportunityId AND Opportunity.RecordType.Name<>'DC Deals']) {
                setOpportunityLineItemId.remove(oOpportunityLineItem.Id);
            }
        
            if(setOpportunityLineItemId.size()>0) {
                List<OpportunityLineItem> listNewOpportunityLineItem = new List<OpportunityLineItem>();
                //Create the Opportunity Line Items
                for(OpportunityLineItem oOpportunityLineItem : listOpportunityLineItem) {
                    Integer cont=1;
                    Date dt;
                    if(setOpportunityLineItemId.contains(oOpportunityLineItem.Id)) {
                        While(cont<=oOpportunityLineItem.Duplicate_Num_Week__c) {
                            OpportunityLineItem newOpportunityLineItem = New OpportunityLineItem();
                            if(dt==null) {
                                dt=oOpportunityLineItem.Onsale_Date__c.adddays(7);
                            }
                            else {
                                dt=dt.adddays(7);
                            }
                            newOpportunityLineItem.OpportunityId=oOpportunityLineItem.OpportunityId;
                            newOpportunityLineItem.Quantity=oOpportunityLineItem.Quantity;
                            newOpportunityLineItem.Onsale_Date__c=dt;
                            newOpportunityLineItem.PricebookEntryId=oOpportunityLineItem.PricebookEntryId;
                            newOpportunityLineItem.UnitPrice=oOpportunityLineItem.UnitPrice;
                            newOpportunityLineItem.Target_Cover_Rating__c=oOpportunityLineItem.Target_Cover_Rating__c;
                            newOpportunityLineItem.Materials_Due__c=oOpportunityLineItem.Materials_Due__c;
                            newOpportunityLineItem.Impression__c=oOpportunityLineItem.Impression__c;
                            newOpportunityLineItem.ParentId__c=oOpportunityLineItem.id;
                            listNewOpportunityLineItem.add(newOpportunityLineItem);
                            cont++;
                        }
                    }
                }
                if(listNewOpportunityLineItem.size()>0) insert listNewOpportunityLineItem;
            }
        }
    }
    public static void executeAfterUpdate(Map<Id, OpportunityLineItem> oldOpportunityLineItemsMap, Map<Id, OpportunityLineItem> newOpportunityLineItemsMap) {
        // Create a Map of Opportunity Line Items List where will be all the duplicate Opportunity Line Items.
        Map<Id, List<OpportunityLineItem>> duplicateOpportunityLineItemsMap = new Map<Id, List<OpportunityLineItem>>();
        // Create a Set from Opportunity Line Items.
        for(OpportunityLineItem oOpportunityLineItem: [Select Id, Duplicate_Num_Week__c From OpportunityLineItem where id in :newOpportunityLineItemsMap.keySet() and Opportunity.RecordType.Name='DC Deals']){
            if(oOpportunityLineItem.Duplicate_Num_Week__c!=oldOpportunityLineItemsMap.get(oOpportunityLineItem.id).Duplicate_Num_Week__c && oOpportunityLineItem.Duplicate_Num_Week__c!=null && oOpportunityLineItem.Duplicate_Num_Week__c>0){
                // The List of each Opportunity Line Item is Instantiated.
                duplicateOpportunityLineItemsMap.put(oOpportunityLineItem.id, new List<OpportunityLineItem>());
            }
        }
        System.debug('duplicateOpportunityLineItemsMap: '+duplicateOpportunityLineItemsMap);
        for(OpportunityLineItem oOpportunityLineItem: [Select Id, OpportunityId, Quantity, PricebookEntryId, Duplicate_Num_Week__c, UnitPrice, Onsale_Date__c, Target_Cover_Rating__c, Materials_Due__c, Impression__c, Unique_Product_ID__c, ParentId__c From OpportunityLineItem where ParentId__c in :duplicateOpportunityLineItemsMap.keySet() and ParentId__c!=null and ParentId__c!='' order by Onsale_Date__c]){
            // The Map for Duplicate Opportunity Line Items is being built.
            duplicateOpportunityLineItemsMap.get(oOpportunityLineItem.ParentId__c).add(oOpportunityLineItem);
        }
        System.debug('#####duplicateOpportunityLineItemsMap'+duplicateOpportunityLineItemsMap);
        // Creating an Opportunity Line Items List that will be inserted.
        List<OpportunityLineItem> listNewOpportunityLineItems = new List<OpportunityLineItem>();        
        // Creating an Opportunity Line Items List that will be deleted.
        List<OpportunityLineItem> listOpportunityLineItemsToDelete = new List<OpportunityLineItem>();        
        // Creating an Opportunity Line Item variable where is goint to be the last Opportunity Line Item.
        OpportunityLineItem lastOpportunityLineItem;
        // Counter that determines the first Opportunity Line Item that will be created.
        Integer j;
        for(String opportunityLineItemId: duplicateOpportunityLineItemsMap.keyset()){
            if(duplicateOpportunityLineItemsMap.get(opportunityLineItemId).size() == 0 || newOpportunityLineItemsMap.get(opportunityLineItemId).Duplicate_Num_Week__c>duplicateOpportunityLineItemsMap.get(opportunityLineItemId).size()){
                j = 0;
                if(duplicateOpportunityLineItemsMap.get(opportunityLineItemId).size() > 0) j = duplicateOpportunityLineItemsMap.get(opportunityLineItemId).size();
                for(Integer i = j; i<(Integer)newOpportunityLineItemsMap.get(opportunityLineItemId).Duplicate_Num_Week__c; i++){
                    // Adding the new Opportunity Line Items to the list to insert.
                    listNewOpportunityLineItems.add(new OpportunityLineItem(
                        OpportunityId = newOpportunityLineItemsMap.get(opportunityLineItemId).OpportunityId,
                        Quantity = newOpportunityLineItemsMap.get(opportunityLineItemId).Quantity,
                        Onsale_Date__c = duplicateOpportunityLineItemsMap.get(opportunityLineItemId).size() > 0 ? duplicateOpportunityLineItemsMap.get(opportunityLineItemId).get(duplicateOpportunityLineItemsMap.get(opportunityLineItemId).size() - 1).Onsale_Date__c.addDays(7*(i - duplicateOpportunityLineItemsMap.get(opportunityLineItemId).size() + 1)) : newOpportunityLineItemsMap.get(opportunityLineItemId).Onsale_Date__c.addDays(7*(i + 1)),
                        PricebookEntryId = newOpportunityLineItemsMap.get(opportunityLineItemId).PricebookEntryId,
                        UnitPrice = newOpportunityLineItemsMap.get(opportunityLineItemId).UnitPrice,
                        Target_Cover_Rating__c = newOpportunityLineItemsMap.get(opportunityLineItemId).Target_Cover_Rating__c,
                        Materials_Due__c = newOpportunityLineItemsMap.get(opportunityLineItemId).Materials_Due__c,
                        Impression__c = newOpportunityLineItemsMap.get(opportunityLineItemId).Impression__c,
                        ParentId__c = opportunityLineItemId
                    ));
                }
            }
            else{
                for(Integer i=duplicateOpportunityLineItemsMap.get(opportunityLineItemId).size() - 1; i>=(Integer)newOpportunityLineItemsMap.get(opportunityLineItemId).Duplicate_Num_Week__c; i--){
                    // Adding the Opportunity Line Items to the list to delete.
                    listOpportunityLineItemsToDelete.add(duplicateOpportunityLineItemsMap.get(opportunityLineItemId).get(i));
                }                    
            }
        }
        System.debug(listOpportunityLineItemsToDelete);
        if(!listOpportunityLineItemsToDelete.isEmpty()){
            try{
                // Deleting Opportunity Line Items.
                Delete listOpportunityLineItemsToDelete;
            }
            catch(DmlException e){
                System.debug('Error Deleting OpportunityLineItems: '+e.getMessage());
            }
        }
        System.debug(listNewOpportunityLineItems);
        if(!listNewOpportunityLineItems.isEmpty()){
            try{
                // Inserting the new Opportunity Line Items.
                insert listNewOpportunityLineItems;
            }
            catch(DmlException e){
                System.debug('Error Inserting New OpportunityLineItems: '+e.getMessage());
            }
        }
    }
}