/**
@Author: Atul(Cognizant)
@name: CRM_OrderController
@CreateDate: 11 Aug 2020
@Description: controller for to handle clone order and activate functionality
@Version <1.0>
@reference
*/

public with sharing class CRM_OrderController{
    
    public CRM_OrderController(Apexpages.StandardController stdCon){}
    
    /** 
*  @description: - This method is used to Clone order with/without products based on user selection on page
*  @name: cloneOrderProducts
*  @para: orderId - current order id, which going to clonned
*  @para: cloneProducts - accept true/false, if it true then order cloning with products, otherwise only order clone
*  @return: Credit note ID
*/     
    @AuraEnabled
    public static List<String> cloneOrderProducts(Id orderId, Boolean cloneProducts){
        system.debug('OrderID-->'+orderId+'--cloneProducts--'+cloneProducts);
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();        
        
        Map<String, Schema.SObjectField> fieldMap = Order.sObjectType.getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>(fieldMap.keySet());
        Map<String, Schema.SObjectField> OIfieldMap = OrderItem.sObjectType.getDescribe().fields.getMap();
        List<String> OIfieldNames = new List<String>(OIfieldMap.keySet());
        Set<String> clonedOrderIdOrerrorMessages = new Set<String>();
        List<String> clonedorderid = new List<String>();
        
        
        Order existingOrder = (Order) Database.Query('SELECT ' + String.join(fieldNames, ',') + ' FROM Order WHERE Id =: orderId')[0];
        List<OrderItem> lstExistingOrderProducts = Database.Query('SELECT ' + String.join(OIfieldNames, ',') + ' FROM OrderItem WHERE OrderId =: orderId');
        
        Order clonedOrder = existingOrder.clone(false, true, false, false);
        clonedOrder.Status = CRM_AppConstants.ORDER_STATUS_OPEN;
        clonedOrder.Order_Submitted_Date__c = null;
        clonedOrder.OwnerId = UserInfo.getUserId();
        clonedOrder.enddate = null;
        List<Profile> profilePermissions = [select id,PermissionsEditReadonlyFields from Profile where id =: UserInfo.getProfileId()];
        if(profilePermissions[0].PermissionsEditReadonlyFields == false){
             clonedOrder.Config__c = null;
        	 clonedOrder.OpportunityId = null;
        }
        system.debug('clonedOrder-->'+clonedOrder);
        
        if(clonedOrder != null){
            Database.SaveResult saveResultInstance = Database.Insert(clonedOrder, false);
            clonedorderid.add(clonedOrder.id);
            if(!saveResultInstance.isSuccess()){
                for(Database.Error err : saveResultInstance.getErrors()){
                    // Save the error in database
                    //ErrorText =  err.getMessage().left(200);
                    CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                    errorLog.functionalModule = 'Clone Order';
                    errorLog.errorMessage = err.getMessage().left(200);
                    clonedOrderIdOrerrorMessages.add(errorLog.errorMessage);
                    System.debug('errorLog.errorMessage--order---'+errorLog.errorMessage);
                    listErrorLog.add(errorLog);
                }
            }
        }
        System.debug('clonedorderid'+clonedorderid);
        If(clonedOrder.Id != null){
            System.debug('clonedOrder.Id'+clonedOrder.Id);
            List<OrderItem> lstClonedOrderProducts = new List<OrderItem>();        
            if(cloneProducts){
                for(OrderItem oi : lstExistingOrderProducts){
                    OrderItem newOI = oi.clone(false, true, false, false);
                    newOI.OrderId = clonedOrder.Id;
                    newOI.Unique_Product_ID__c = null;
                    lstClonedOrderProducts.add(newOI);
                }
                if(!lstClonedOrderProducts.isEmpty()){
                    Database.SaveResult[] saveResultList = Database.Insert(lstClonedOrderProducts, false);
                    for (Integer i = 0; i < saveResultList.size(); i++){
                        Database.SaveResult saveResultInstance = saveResultList[i];                    
                        if(!saveResultInstance.isSuccess()){
                            for(Database.Error err : saveResultInstance.getErrors()){
                                CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                                errorLog.functionalModule = 'Clone Order';
                                errorLog.errorMessage = err.getMessage().left(200);
                                System.debug('err'+err);
                                clonedOrderIdOrerrorMessages.add(errorLog.errorMessage);
                                System.debug('errorLog.errorMessage--orderproduct---'+errorLog.errorMessage);                               
                                listErrorLog.add(errorLog);
                            }
                        }
                    }
                }
            }        
        }
        if(!listErrorLog.isEmpty()){
            // Inserts all errors into database
            CRM_ErrorLogger.logError(listErrorLog);
        }
        if(!clonedOrderIdOrerrorMessages.isEmpty()){
            System.debug('clonedOrderIdOrerrorMessages'+clonedOrderIdOrerrorMessages);
           //clonedorderid.add(clonedOrderIdOrerrorMessages);
           if(clonedOrder.id != null){
                deleteOrder(clonedOrder.id);
            }
            return clonedorderid = new List<String>(clonedOrderIdOrerrorMessages);
        }
        else{
            System.debug('clonedorderid final'+clonedorderid);
            return clonedorderid;
        }
    }
    
    @AuraEnabled
    public static void deleteOrder(Id orderId){
        List<Order> orderToDelete = [SELECT Id FROM ORDER WHERE Id =: orderId];
        try {
                // Deleting the order
            delete orderToDelete;       
        }
        catch(Exception e) {
            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
            errorLog.functionalModule = 'Clone Order';
            errorLog.errorMessage = e.getMessage().left(200);
            System.debug('errorLog.errorMessage--order---'+errorLog.errorMessage);
            CRM_ErrorLogger.logError(errorLog);
        }
    }
               
        
    
    
    /** 
*  @description: - This method is used to activate the order
*  @name: activateOrder
*  @para: orderId - order id which going to activate
*  @return: null
*/ 
    @RemoteAction 
    public static void activateOrder(Id orderId){
        List<Order> lstOrder = [SELECT Id,OrderNumber,Status,Count_of_Order_Product__c FROM Order WHERE Id =: orderId];
        system.debug('lstOrder-->'+lstOrder);
        Schema.DescribeSObjectResult descResult =  Order.sObjectType.getDescribe();
        
        if(descResult.isUpdateable() == false){
            throw new CRM_OrderControllerException(System.label.CRM_Order_Activation_Error_Privilege);
        }else if(!lstOrder.isEmpty()){
            if(lstOrder[0].Count_of_Order_Product__c == 0){
                throw new CRM_OrderControllerException(System.label.CRM_Order_Item_Not_Present);
            }else if(lstOrder[0].Status == CRM_AppConstants.ORDER_STATUS_OPEN){
                lstOrder[0].Status = CRM_AppConstants.ORDER_STAGE_SUBMITTED;
                try{
                    update lstOrder;
                }catch(System.DmlException ex){
                    throw new CRM_OrderControllerException(ex.getDmlMessage(0));
                }
            }else{
                throw new CRM_OrderControllerException(System.label.CRM_Order_Activation_Error);
            }
        }
    }
    
    public class CRM_OrderControllerException extends Exception {}
}