/**
   @Author Cognizant
   @name CRM_EditAllRelatedOrdersCtrl
   @CreateDate 18 Oct 2016
   @Description This class will be use to edit the deal products.
   @Version <1.0>
   @reference Requirement no 35
*/

global with sharing class CRM_EditAllRelatedOrdersCtrl{
    public Order order {get; set;}
    public boolean isActivated{get; set;}
    
    public CRM_EditAllRelatedOrdersCtrl(ApexPages.Standardcontroller stdCon) {
        if (stdCon.getId() != null) {
            List<Order> lstOrder = [SELECT Id,ActivatedDate,OrderNumber
                                    FROM Order 
                                    WHERE Id = :stdCon.getId()];
                                    
            if (!lstOrder.isEmpty()){
                order = lstOrder[0];
                if(order.ActivatedDate != null)
                    isActivated = true;
                else
                    isActivated = false;
            }
        }               
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    } 
    
     /**
     * Method to get logged in uSer Locale
     */
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        return currentUserLocale.toLowerCase();
    }   
    /**
     * Method to get logged in uSer Locale Language code
     */
    global String getUserLocaleLanguage() {
        return UserInfo.getLocale().split('_')[0];
    }
     /**
     *  Method to fetch the Related Order from OrderId 
     *  @name getRelatedOrders
     *  @param Id orderId
     *  @return CRM_DataObjects.ProductToEdit[]
     *  @throws None
     */
    
    @RemoteAction 
    global static RelatedOrderToEdit[] getRelatedOrders(Id orderId) {
        RelatedOrderToEdit[] lstRelatedOrder = new RelatedOrderToEdit[]{};
        if(orderId != null){
              for(Order relatedOrder :  [SELECT Id,OrderNumber,Account.AccountNumber,Account.Name,Customer_PO_Number__c,EffectiveDate,Comments__c,Multi_Order__c 
                                         FROM Order 
                                         WHERE Multi_Order__c =: orderId]){
                                         
                  RelatedOrderToEdit rOrderToEdit = new RelatedOrderToEdit();
                  rOrderToEdit.childOrder = relatedOrder;
                  rOrderToEdit.OrderId = relatedOrder.Id;
                  rOrderToEdit.requestedDeliveryDate = relatedOrder.EffectiveDate;
                  rOrderToEdit.PoNumber = relatedOrder.Customer_PO_Number__c != null ? relatedOrder.Customer_PO_Number__c : '';
                  rOrderToEdit.Comments = relatedOrder.Comments__c != null ? relatedOrder.Comments__c : '';
                  rOrderToEdit.isSelected = false;
                  rOrderToEdit.isDelete = false;
                  lstRelatedOrder.add(rOrderToEdit);
              }
        }
        return lstRelatedOrder;
    }
    
    /**
     *  Method to update/Delete the Related Order 
     *  @name saveRelatedOrders
     *  @param Id orderId, List<RelatedOrderToEdit> relatedOrders, Boolean quickSave
     *  @return CRM_DataObjects.ProductToEdit[]
     *  @throws None
     */
    @RemoteAction
    static global RelatedOrderToEdit[] saveRelatedOrders(Id orderId, List<RelatedOrderToEdit> relatedOrders, Boolean quickSave) {
        boolean isDelete = false;
        List<Order> lstRelatedOrderUpsert = new List<Order>();
        List<Order> lstRelatedOrderDelete = new List<Order>();
        for(RelatedOrderToEdit ro : relatedOrders){
            if (ro.childOrder != null) {
                system.debug('RO : '+ro);
                Order orderObj = ro.childOrder;
                if(ro.isDelete){
                    lstRelatedOrderDelete.add(orderObj);
                    isDelete = true;
                }else if(orderObj.Customer_PO_Number__c != ro.PoNumber || orderObj.Comments__c != ro.Comments || orderObj.EffectiveDate != ro.requestedDeliveryDate){
                    orderObj.Customer_PO_Number__c = ro.PoNumber;
                    orderObj.Comments__c = ro.Comments;
                    orderObj.EffectiveDate = ro.requestedDeliveryDate;
                    lstRelatedOrderUpsert.add(orderObj);
                }
            }
        }
           
        // Commit changes
        Savepoint sp = Database.setSavepoint();
        try{
            if(lstRelatedOrderUpsert.size() > 0)
                Upsert lstRelatedOrderUpsert;
            if(lstRelatedOrderDelete.size() > 0)
                delete lstRelatedOrderDelete;
        }catch(System.DMLException e){
            Database.rollback(sp);
            throw new CRM_EditRelatedOrderException(e.getDmlMessage(0));
        }catch(Exception e){
            Database.rollback(sp);
            throw new CRM_EditRelatedOrderException(e.getMessage());
        }
       
        if(quickSave && isDelete)
            return getRelatedOrders(OrderId);
        else
           return null;
    } 
    
    //Method to fetch CRM_Max_Product_Limit__c to fetch Product limit
    global Integer getMaxRelatedOrderLimit() {
        return CRM_Max_Product_Limit__c.getInstance('Edit_Orders') != null ? Integer.valueOf(CRM_Max_Product_Limit__c.getInstance('Edit_Orders').Count__c) : 50;
    }
    
    global class RelatedOrderToEdit{
        global Boolean isSelected;
        global Boolean isDirtyRow;
        global Boolean isDelete;
        global Id OrderId;
        global Date requestedDeliveryDate;
        global String PoNumber;
        global String Comments;
        global Order childOrder;
        public RelatedOrderToEdit(){}
    }
    
    public class CRM_EditRelatedOrderException extends Exception {}
    
    /*  
    *  name getUserDateFormat: e.g. M/d/yyyy
    *  param none
    *  return string
    *  throw none
    */  
    global String getUserDateFormat(){
        return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
    }
}