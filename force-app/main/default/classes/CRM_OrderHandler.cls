public with sharing class CRM_OrderHandler{
    
    /**
    *  @Description - US. #632 / TO Do List Of(JAPAN): Update Ship To Account Address on Order.Auto Update Ship To Account based on Sold To
    *  @name - updatePricebookOnOrder
    *  @param - mapOldOrderValues - Map of Order Old values
    *  @param - lstOrder - list of Order new values
    *  @return - void
    **/
    public static void updatePricebookOnOrder(List<Order> lstOrder,Map<Id,Order> mapOldOrderValues){
        set<Id> setAcctIDs = new set<Id>();
        //US#632
        map<Id,List<Account>> mapChildShipToAccounts = new map<Id,List<Account>>();
        for (Order objOrder: lstOrder){
            if (objOrder.AccountId != null){
                setAcctIDs.add(objOrder.AccountId);
            }

        }
       
    //Us#632 - added subquery to get child ship to account for sold to account
        if (setAcctIDs != null && !setAcctIDs.isEmpty()){
            Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT Id,Price_Book__c ,BillingCity,BillingCountry,Ship_To__c,
                                                                BillingCountryCode,BillingGeocodeAccuracy,RecordTypeId,Sales_Organization__c,Digital_Country_Code__c,
                                                                BillingLatitude,BillingLongitude,BillingPostalCode,
                                                                (SELECT id,BillingCity,BillingCountry,Ship_To__c,
                                                                BillingCountryCode,BillingGeocodeAccuracy,RecordTypeId,Sales_Organization__c,Digital_Country_Code__c,
                                                                BillingLatitude,BillingLongitude,BillingPostalCode,BillingState,BillingStateCode,BillingStreet FROM Accounts__r),
                                                                BillingState,BillingStateCode,BillingStreet
                                                                FROM Account 
                                                                WHERE Id IN: setAcctIDs]);
            Account objAcct = new Account();
            Account accShipToOrSoldTo = new Account();            
            
            for (Order objOrder: lstOrder){
                if (mapAccount != null && mapAccount.containsKey(objOrder.AccountId)){
                    objAcct = mapAccount.get(objOrder.AccountId);
                    Map<Id,Account> childAccountsMap = 
                        objAcct.Accounts__r != null && objAcct.Accounts__r.size() > 0 
                        ? new Map<Id, Account> (objAcct.Accounts__r) 
                        : new Map<Id, Account>();
                    
                    //US#632: derive the correct Sold To/Ship to relationship on Orders. - start
                    if (
                            objAcct != null &&
                            (objOrder.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_STANDARD || objOrder.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_RETURN) &&
                            (
                                CRM_AppConstants.GERMANY_SALES_ORGS.contains(objAcct.Sales_Organization__c) || 
                                CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(objAcct.Digital_Country_Code__c)||
                                objAcct.Sales_Organization__c == CRM_AppConstants.TERRITORY_ITALY_CODE // Italy Changes 
                            )
                            //Def #4458: Skip Ship To validation on Order for Informatica User
                            && (UserInfo.getUserId() != (Id)CRM_Default_Configuration__c.getOrgDefaults().Informatica_User_Id__c)
                    ) {
                        if(objAcct.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO){
                            objOrder.Ship_To_Account__c = objAcct.Id;
                        } else if(objAcct.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO){
                            if(childAccountsMap != null && childAccountsMap.size() == 1 && childAccountsMap.values().size() == 1) {
                                objOrder.Ship_To_Account__c = childAccountsMap.values()[0].Id;
                            } else if (childAccountsMap.size() == 0 && childAccountsMap.values().size() == 0 && objAcct.ship_to__c ==True ) {
                                objOrder.Ship_To_Account__c = objAcct.Id;
                            }
                        }
                    }

                    //US#632: End
                    if (objAcct != null && objOrder.Pricebook2Id == null && objAcct.Price_Book__c != null){
                        objOrder.Pricebook2Id = objAcct.Price_Book__c;
                    }
                    if(objOrder.Ship_To_account__c != null){
                        if (childAccountsMap.containsKey(objOrder.Ship_To_account__c)) {
                            accShipToOrSoldTo = childAccountsMap.get(objOrder.Ship_To_account__c);
                        } else if (mapAccount.containsKey(objOrder.AccountId)) {
                            accShipToOrSoldTo = mapAccount.get(objOrder.AccountId);
                        }
                    } else if (mapAccount.containsKey(objOrder.AccountId)) {
                        accShipToOrSoldTo = mapAccount.get(objOrder.AccountId);
                    }
                    if(
                        //Defect#4106 - added to distiguish before insert and before update for Ship_To_account__c is changed.
                           (
                                mapOldOrderValues == null ||
                                (
                                    mapOldOrderValues != null &&
                                    mapOldOrderValues.containsKey(objOrder.Id) &&
                                    mapOldOrderValues.get(objOrder.Id)!= null &&
                                    (
                                        (
                                            objOrder.Ship_To_account__c == null &&
                                            (objOrder.AccountId != mapOldOrderValues.get(objOrder.Id).AccountId)
                                        ) ||
                                        (
                                            objOrder.Ship_To_account__c != null &&
                                            objOrder.Ship_To_account__c != mapOldOrderValues.get(objOrder.Id).Ship_To_account__c
                                        )
                                    )
                                )
                         ) 
                    ){
                            objOrder.BillingCity = accShipToOrSoldTo.BillingCity;
                            objOrder.BillingCountryCode = accShipToOrSoldTo.BillingCountryCode;
                            objOrder.BillingGeocodeAccuracy = accShipToOrSoldTo.BillingGeocodeAccuracy; 
                            objOrder.BillingLatitude = accShipToOrSoldTo.BillingLatitude;
                            objOrder.BillingLongitude = accShipToOrSoldTo.BillingLongitude;
                            objOrder.BillingPostalCode = accShipToOrSoldTo.BillingPostalCode;
                            objOrder.BillingState = accShipToOrSoldTo.BillingState;
                            objOrder.BillingStateCode = accShipToOrSoldTo.BillingStateCode;
                            objOrder.BillingStreet = accShipToOrSoldTo.BillingStreet;
                            objOrder.BillingCountry = accShipToOrSoldTo.BillingCountry;

                   }
                }
             }
        }   
    }
    
    public static void dontClone(List<Order> lstOrder){
        for (Order objOrder: lstOrder){    
            /*Defect 3579: Making few Fields Blank on Deal Clone.*/
            objOrder.Sub_Status__c = null;
            objOrder.SAP_Order_Number__c= null;
            objOrder.SAP_Updated_Date__c= null;
            objOrder.Order_Submitted_Date__c = null;
            //Defect#4217 (German UAT)
            objOrder.LPFR_Return_Value__c = null;
            /*Defect 3579: Making few Fields Blank on Deal Clone.*/
            //Defect #3647: ORDERS: Rejection Reason field being cloned 
            objOrder.Rejection_Reason__c = null;    
        }
    }

    public static void attachPDF(Map<Id,Order> mapOldOrders,List<Order> lstNewOrders){
        List<Id> listImpactedOrders = new List<Id>();
        for(Order newOrd : lstNewOrders) {
            if((newOrd.Status != mapOldOrders.get(newOrd.Id).Status) && (newOrd.Status == CRM_AppConstants.ORDER_STAGE_SUBMITTED) && 
               (newOrd.Confirm__c == True) && newOrd.Order_Submitted_Date__c==null) {
                   listImpactedOrders.add(newOrd.Id);
               }
        }
        
        if(!listImpactedOrders.isEmpty()){
            generateAttachPDF(listImpactedOrders);
        }
    }        
    
    @future(callout=true)
    public static void generateAttachPDF(List<Id> listImpactedOrders){
        
        for(Id ordId : listImpactedOrders){
            PageReference pageRef = Page.CRM_OrderConfirmationEmail;//new PageReference('Page.CRM_OrderConfirmationEmail');
            pageRef.getParameters().put('Id', ordId);
            
            Attachment attach = new Attachment();
            Datetime currentDate = Datetime.now();
            String dateOutput = currentDate.format('yyyyddMMHHmm');
            attach.Name = 'Order_Confirmation_Email_' + dateOutput;// 201607221315';
            attach.ParentId = ordId;
            attach.ContentType = 'application/pdf';
            attach.Body = (Test.IsRunningTest() ? Blob.valueOf('UNIT.TEST') : pageRef.getContentAsPDF());
            Database.insert(attach); 
        }         
    }
    //Update Custom Total Price of Related Order Products for SBOM Order
    public static void updateCustomTotalPriceOfOP(Map<Id,Order> mapOldOrders,List<Order> lstNewOrders){
        Set<Id> updatedOrderIds = new Set<Id>();
        List<OrderItem> orderItems = new List<OrderItem>();
        List<OrderItem> updatedOrderItem = new List<OrderItem>();
        
        for(Order o : lstNewOrders){
            boolean validationByPass = false;
            if(mapOldOrders.get(o.Id).Quantity__c != o.Quantity__c || mapOldOrders.get(o.Id).Config__c != o.Config__c){
                updatedOrderIds.add(o.Id);
            }
        }
        
        if(updatedOrderIds.size() > 0){
            
            orderItems = [Select Id,Total_Quantity__c,UnitPrice,Total_Price__c From OrderItem Where Order.Id IN :updatedOrderIds];
            if(orderItems.size() > 0){
                for(OrderItem oi : orderItems){
                    Decimal tempTP = (oi.Total_Quantity__c != null && oi.UnitPrice != null) ? (oi.Total_Quantity__c * oi.UnitPrice ) : 0;
                    if(oi.Total_Price__c != tempTP){
                        oi.Total_Price__c = tempTP;
                        updatedOrderItem.add(oi);
                    }
                }
            }
            
            if(updatedOrderItem.size() > 0)
                update updatedOrderItem;
        }
    }

    /**
    *  @Description - US. #590 (JAPAN): When Approve/Reject Parent order Approve/Reject all its Child orders.
    *  @name - updateReturnApprovalStatusOfAllChildOrders
    *  @param - mapOldOrders - Map of Order Old values
    *  @param - lstNewOrders - list of Order new values
    *  @return - void
    **/
    public static void updateReturnApprovalStatusOfAllChildOrders(Map<Id,Order> mapOldOrders,List<Order> lstNewOrders){
        Map<Id,String> mapIdToApprovalStatus = new Map<Id,String>();
        List<Order> lstAllChildOrders = new List<Order>();
        Set<Id> setOfMultiOrderReturn = new Set<Id>();
        Set<Id> setOfMultiOrderFailed = new Set<Id>();
        
        //Defect#4542 - variable to store the set of parent ids and child orders.
        List<Order> lstChildOrdersToUpdateReqDate = new List<Order>();
        set<Id> parentOrderIds = new set<Id>();
        //End - defect#4542
        
        for(Order orderObj : lstNewOrders){
            if(
                (orderObj.Return_Approval__c == CRM_AppConstants.RETURN_ORDER_RETURN_APPROVAL || orderObj.Return_Approval__c == CRM_AppConstants.RETURN_ORDER_RETURN_REJECTED || orderObj.Return_Approval__c == CRM_AppConstants.RETURN_ORDER_RETURN_AWAITING_APPROVAL) &&
                (mapOldOrders.get(orderObj.Id).Return_Approval__c != CRM_AppConstants.RETURN_ORDER_RETURN_APPROVAL && mapOldOrders.get(orderObj.Id).Return_Approval__c != CRM_AppConstants.RETURN_ORDER_RETURN_REJECTED) &&
                 orderObj.Return_Approval__c != mapOldOrders.get(orderObj.Id).Return_Approval__c &&
                 orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN
            ){
                mapIdToApprovalStatus.put(orderObj.Id,orderObj.Return_Approval__c);
            }
            
            if(orderObj.Status != mapOldOrders.get(orderObj.Id).Status && mapOldOrders.get(orderObj.Id).Status == CRM_AppConstants.ORDER_STAGE_SUBMITTED && 
               (orderObj.Status == CRM_AppConstants.ORDER_STAGE_In_SAP || orderObj.Status == CRM_AppConstants.ORDER_STAGE_IN_FAILED) && 
               (orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_RETURN || orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_STANDARD || orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_REV_SHARE)){
                
                //Defect#4213 (Update Failed Status in Parent Order)
                if(orderObj.Status == CRM_AppConstants.ORDER_STAGE_IN_FAILED){
                  setOfMultiOrderFailed.add(orderObj.Multi_Order__c);   
                }
                setOfMultiOrderReturn.add(orderObj.Multi_Order__c);    
            }
            
            //Defect#4542 - get all order records where requested delivery date is changed.
            if(orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER || 
                      orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN || 
                      orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_REVENUE_SHARE){
                      if(orderObj.EffectiveDate != mapOldOrders.get(orderObj.id).EffectiveDate){
                        parentOrderIds.add(orderObj.Id);
                      }
            }
        }
        
        if(!setOfMultiOrderReturn.isEmpty()){
            List<Order> lstMultiReturnOrder = [SELECT Id,Status FROM Order WHERE Id IN :setOfMultiOrderReturn AND Status != :CRM_AppConstants.ORDER_STAGE_IN_FAILED];
            List<Order> lstMROrderToUpdate = new List<Order>();
            for(Order mor : lstMultiReturnOrder){
                //Defect#4213 (Update Failed Status in Parent Order)
                if(setOfMultiOrderFailed.contains(mor.Id) && (mor.Status == CRM_AppConstants.ORDER_STAGE_In_SAP || mor.Status == CRM_AppConstants.ORDER_STAGE_SUBMITTED)){
                  mor.Status = CRM_AppConstants.ORDER_STAGE_IN_FAILED;
                  lstMROrderToUpdate.add(mor);
                }else{ 
                  if(mor.Status != CRM_AppConstants.ORDER_STAGE_In_SAP && mor.Status == CRM_AppConstants.ORDER_STAGE_SUBMITTED){
                      mor.Status = CRM_AppConstants.ORDER_STAGE_In_SAP;
                      lstMROrderToUpdate.add(mor);
                  }
              }
            }
            if(!lstMROrderToUpdate.isEmpty()){
                try{
                    CRM_AppConstants.orderActivateFlag = false;
                    update lstMROrderToUpdate;
                    CRM_AppConstants.orderActivateFlag = true;
                }catch(System.DMLException de){
                    CRM_AppConstants.orderActivateFlag = true;
                    List<String> orderNumbers = new List<String>();
                    for(integer i=0;i<de.getNumDml();i++){
                        orderNumbers.add(lstMROrderToUpdate.get(de.getDmlIndex(i)).OrderNumber);
                    }
                    lstNewOrders.get(0).addError(String.join(orderNumbers,'-')+' : '+de.getDmlMessage(0),false);
                }    
            }
        }
        
        if(mapIdToApprovalStatus.size() > 0){
            lstAllChildOrders = [Select Id,Status,Multi_Order__c,OrderNumber,Return_Approval__c
                             From Order 
                             WHERE Multi_Order__c IN :mapIdToApprovalStatus.keySet()];
            if(!lstAllChildOrders.isEmpty()){
                List<Order> lstOrders = new List<Order>();
                try{
                    for(Order orderObj : lstAllChildOrders){
                        if(mapIdToApprovalStatus.containsKey(orderObj.Multi_Order__c)){
                            orderObj.Return_Approval__c = mapIdToApprovalStatus.get(orderObj.Multi_Order__c);
                            lstOrders.add(orderObj);
                        }
                    }
                    if(lstOrders.size() > 0){
                        CRM_AppConstants.orderActivateFlag = false;
                        update lstOrders;
                        CRM_AppConstants.orderActivateFlag = true;
                    }
                }catch(System.DMLException de){
                    CRM_AppConstants.orderActivateFlag = true;
                    List<String> orderNumbers = new List<String>();
                    for(integer i=0;i<de.getNumDml();i++){
                        orderNumbers.add(lstOrders.get(de.getDmlIndex(i)).OrderNumber);
                    }
                    lstNewOrders.get(0).addError(String.join(orderNumbers,'-')+' : '+de.getDmlMessage(0),false);
                }         
            }
        }
        
        //Defect#4542 - query all child order records where parent orders delivery date is changed.
        if(parentOrderIds.size() > 0){
            
                    lstChildOrdersToUpdateReqDate = [Select Id,Status,Multi_Order__c,EffectiveDate,Multi_Order__r.EffectiveDate
                                        From Order 
                                        WHERE Multi_Order__c IN :parentOrderIds];
                                        
                    if(!lstChildOrdersToUpdateReqDate.isEmpty()){
                        //Method to update requested delivery date on child orders.
                        updateAllChildOrders(lstChildOrdersToUpdateReqDate,mapOldOrders);
                    }                    
        }
    }
    
    /**
    *  @Description - US. #476 (JAPAN): When Activate Parent order activate all its Child orders.
    *  @name - activateAllChildOrders
    *  @param - mapOldOrders - Map of Order Old values
    *  @param - lstNewOrders - list of Order new values
    *  @return - void
    **/
    public static void activateAllChildOrders(Map<Id,Order> mapOldOrders,List<Order> lstNewOrders){
        activateAllOrders(getAllRelatedChildOrdersFromMultiOrder(mapOldOrders,lstNewOrders),lstNewOrders);
    }
    
    private static List<Order> getAllRelatedChildOrdersFromMultiOrder(Map<Id,Order> mapOldOrders,List<Order> lstNewOrders){
        Set<Id> parentOrderIds = new Set<Id>();
        Set<Id> setOfOrderIds = new Set<Id>();
        Set<Id> setStandardOrRevenueShareOrders = new Set<Id>();
        //Set<Id> setMultiReturnOrderIds = new Set<Id>(); //Commented for ER-006683
        
        for(Order orderObj : lstNewOrders){
            
            if(orderObj.ActivatedDate != mapOldOrders.get(orderObj.Id).ActivatedDate && 
               orderObj.ActivatedDate != null && mapOldOrders.get(orderObj.Id).ActivatedDate == null){
               
                 
               if(orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER || 
                  orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN || 
                  orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_REVENUE_SHARE){
                
                 parentOrderIds.add(orderObj.Id);
                  if(orderObj.opportunityId != null && orderObj.RecordTypeId != CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN){
                      setOfOrderIds.add(orderObj.Id);
                  }
              }
              
        //Defect : 4244 (Germany) : Through error message for multi return order              
              /*if(CRM_AppConstants.GERMANY_SALES_ORGS.contains(orderObj.Sales_Organisation__c)){ //Commented for ER-006683
                if(orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN){
                  setMultiReturnOrderIds.add(orderObj.Id);
                }else if(orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_RETURN && orderObj.Multi_Order__c == null){
                  setMultiReturnOrderIds.add(orderObj.Id);
                }
              }*/ //Commented for ER-006683
                
              //Defect : 4239 : Validate Order Product Dist Chain Status While activate the Order
              if(orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_STANDARD || orderObj.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_REV_SHARE){
                setStandardOrRevenueShareOrders.add(orderObj.Id);
              }
          }
        }
        
        //Defect : 4244 (Germany) : Through error message for multi return order 
        /*if(!setMultiReturnOrderIds.isEmpty())
          validateMultiReturnOrders(setMultiReturnOrderIds,lstNewOrders);*/ //Commented for ER-006683
          
        //Defect : 4239 : Validate Order Product Dist Chain Status While activate the Order
        if(!setStandardOrRevenueShareOrders.isEmpty())
          validateAllOrderProducts(setStandardOrRevenueShareOrders,lstNewOrders);
          
        if(!setOfOrderIds.isEmpty())
            updateInitialQuantityOnDealProduct(setOfOrderIds);
            
        if(parentOrderIds.size() > 0){
            
            return [Select Id,Status,Multi_Order__c,OrderNumber,Return_Approval__c
                    From Order 
                    WHERE Multi_Order__c IN :parentOrderIds AND ActivatedDate = null AND ActivatedById = null];
        }
        return null;
    }
    
    private static void activateAllOrders(List<Order> lstAllChildOrders,List<Order> lstNewOrders){
        if(lstAllChildOrders != null){
            List<Order> lstOrders = new List<Order>();
            try{
                for(Order orderObj : lstAllChildOrders){
                    orderObj.Status = CRM_AppConstants.ORDER_STAGE_SUBMITTED;
                    lstOrders.add(orderObj);
                }
                system.debug('lstOrders '+lstOrders);
                if(lstOrders.size() > 0){
                    CRM_AppConstants.orderActivateFlag = false;
                    update lstOrders;
                }
            }catch(System.DMLException de){
                CRM_AppConstants.orderActivateFlag = true;
                List<String> orderNumbers = new List<String>();
                for(integer i=0;i<de.getNumDml();i++){
                    orderNumbers.add(lstOrders.get(de.getDmlIndex(i)).OrderNumber);
                }
                lstNewOrders.get(0).addError(String.join(orderNumbers,'-')+' : '+de.getDmlMessage(0),false);
            } 
        }
    }
    
    /**
    *  @Description - US. #476 (JAPAN): Delete Child orders when Parent Multi Order is deleted.
    *  @name - deleteChildOrder
    *  @param - oldOrders - list of Order Old values
    *  @return - void
    **/
    public static void deleteChildOrder(List<Order> oldOrders){
        List<Order> lstOrdersToBeDeleted=new List<Order>();
        for(Order ord : oldOrders){
            if(ord.RecordTypeId==CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER || ord.RecordTypeId==CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN || ord.RecordTypeId==CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_REVENUE_SHARE)
                lstOrdersToBeDeleted.add(ord);
        }
        
        List<Order> childOrderList = new List<Order>();
        if(!lstOrdersToBeDeleted.isEmpty())
            childOrderList = [select id from order where Multi_Order__c in :lstOrdersToBeDeleted];
        
        Savepoint sp = Database.setSavepoint();
        try{
            if(!childOrderList.isEmpty())
                delete childOrderList;
        }catch(Exception e) {
            Database.rollback(sp);
        }
    }
    
    /**
    *  @Description - US. #476 (JAPAN): Update Quantity of parentOrder's orderProduct when childOrder is deleted.
    *  @name - updateParentOrderQuantityRollup
    *  @param - oldOrders - list of toBeDeleted Order Old values,oldOrderItems - if orderproduct is manually deleted
    *  @return - void
    **/ 
    public static void updateParentOrderQuantityRollup(List<Order> oldOrders, List<OrderItem> oldOrderItems){
        //select Parent Order based on childOrderId
        Set<Id> setParentOrderId = new Set<Id>();   //  MUlti Order Id - to get parent order products
        List<Id> lstAccountId = new List<Id>();     //  To maintain account sequence
        List<OrderItem> lstChildOrderProducts = new List<OrderItem>();
        List<OrderItem> lstParentOrderProducts = new List<OrderItem>();
        List<Order> lstOldOrderToBeProcessed = new List<Order>();
        
        // <TODO>
        for(Order ord : oldOrders){
            if(null!=ord.Multi_Order__c){
                setParentOrderId.add(ord.Multi_Order__c);
                lstOldOrderToBeProcessed.add(ord);
                if(null!=ord.Ship_To_Account__c)
                    lstAccountId.add(ord.Ship_To_Account__c);
            }
        }
        
        lstChildOrderProducts = getChildOrderProducts(oldOrderItems, lstOldOrderToBeProcessed); 
        Map<Id, OrderItem> mapOfPBEandOrderItem = getMapOfPBEandOrderItem(setParentOrderId);         
        Savepoint sp = Database.setSavepoint();
        try{
            List<OrderItem> lstParentOrderItemToBeDeleted = new List<OrderItem>();
            lstParentOrderItemToBeDeleted = getListofParentOrderItemToBeProcessed(mapOfPBEandOrderItem, 
                                                                                       lstChildOrderProducts);
            // <TODO>
            if(!setParentOrderId.isEmpty())
                updateParentOrderAccountSequence(lstAccountId,setParentOrderId,lstParentOrderItemToBeDeleted);
            if(!lstParentOrderItemToBeDeleted.isEmpty()){
                delete lstParentOrderItemToBeDeleted;
            }
            
        }catch(Exception e) {
            Database.rollback(sp);
        }
    }
    
    /**
    *  @Description - US. #476 (JAPAN): Get child orderItems for the child orders
    *  @name - getChildOrderProducts
    *  @param - oldOrderItems - list childorder item(if triggered from orderitem), lstOldOrderToBeProcessed - childorder
    *  @return - Map<Order,Set<String>>
    **/ 
    private static List<OrderItem> getChildOrderProducts(List<OrderItem> oldOrderItems, List<Order> lstOldOrderToBeProcessed) {
        //Select orderProduct based on childOrderId
        if(oldOrderItems == null){
            return [Select Id,Quantity,Order.Id,Order.Multi_Order__c,PricebookentryId,ProductNumber__c from OrderItem 
                    where orderid in:lstOldOrderToBeProcessed];
        }else{
            return oldOrderItems;
        }
    }
    
    /**
    *   @Description - US. #476 (JAPAN): Creates a map of PricebookEntryId and OrderItem associated to it.   
    **/
    private static Map<Id, OrderItem> getMapOfPBEandOrderItem(Set<Id> setParentOrderId) {
        //Select parentOrderProduct based on parentOrderId
        List<OrderItem> lstParentOrderProducts;
        if(!setParentOrderId.isEmpty())
            lstParentOrderProducts = [Select Id,Quantity,Order.Id,PricebookentryId,ProductNumber__c from OrderItem 
                                      where orderid in:setParentOrderId];
       
        Map<Id, OrderItem> mapOfPBEandOrderItem = new Map<Id, OrderItem>();
        
        if(null != lstParentOrderProducts && !lstParentOrderProducts.isEmpty()){
            for(OrderItem oli: lstParentOrderProducts){
                mapOfPBEandOrderItem.put(oli.PricebookEntryId, oli);
            }
        }
        return mapOfPBEandOrderItem;
    }
    
    /**
    *   @Description - US. #476 (JAPAN): Subtract the quantity from ParentOrderItem and return the list of deleted ParentProductItem.   
    **/    
    private static List<OrderItem> getListofParentOrderItemToBeProcessed(Map<Id, OrderItem> mapOfPBEandOrderItem, List<OrderItem> lstChildOrderProducts) {
        Map<Id,OrderItem> mapOfParentOrderItemToBeUpdated = new Map<Id,OrderItem>();
        List<OrderItem> lstParentOrderItemToBeDeleted = new List<OrderItem>();
        if(!mapOfPBEandOrderItem.isEmpty() && null != lstChildOrderProducts && !lstChildOrderProducts.isEmpty()){
            for(OrderItem oi : lstChildOrderProducts){
                if(mapOfPBEandOrderItem.containsKey(oi.PricebookEntryId) && null!=mapOfPBEandOrderItem.get(oi.PricebookEntryId)){
                    OrderItem parentOrdItem = mapOfPBEandOrderItem.get(oi.PricebookEntryId);
                    if((parentOrdItem.Quantity - oi.Quantity)==0){
                        lstParentOrderItemToBeDeleted.add(parentOrdItem);
                        if(mapOfParentOrderItemToBeUpdated.containsKey(parentOrdItem.Id)){
                            mapOfParentOrderItemToBeUpdated.remove(parentOrdItem.Id);
                        }
                    }else{
                        parentOrdItem.Quantity = parentOrdItem.Quantity - oi.Quantity;
                        mapOfParentOrderItemToBeUpdated.put(parentOrdItem.Id,parentOrdItem);
                    }
                    
                }
            }
        }
        if(!mapOfParentOrderItemToBeUpdated.isEmpty()){
            update mapOfParentOrderItemToBeUpdated.values();
        }
        return lstParentOrderItemToBeDeleted;
    }
    
    /**
    *  @Description - US. #476 (JAPAN): Update Account Sequence of parentOrder when childOrder is deleted.
    *  @name - updateParentOrderAccountSequence
    *  @param - oldOrders - list of toBeDeleted Order Old values
    *  @return - void
    **/ 
    private static void updateParentOrderAccountSequence(List<Id> lstAccId,Set<Id> setParentOrderId, List<OrderItem> lstParentOrderItemToBeDeleted){
        
        List<Account> lstAccNumber = new List<Account>();       //Accounts of childOrders
        List<Order> lstParentOrder = new List<Order>();         //List of ParentOrders
        List<Order> lstUpdatedParentOrder = new List<Order>();  //List of ParentOrders with updated Account Sequence
        lstParentOrder = [Select Id,Order_Account_Sequence__c,Order_Product_Sequence__c from Order where id in :setParentOrderId];
        //Create Map of ParentOrder and its AccountSequence
        if(!lstAccId.isEmpty() && CRM_MultiUploadExtractOrderController.updateAccSeqFlag){
            lstAccNumber = [Select AccountNumber from Account where Id in : lstAccId];
            Map<Order,Set<String>> mapParentOrderAccNumSeq = getMapParentOrderAccNumSeq(lstParentOrder);
            //Check for Account in the Accountsequence and remove the accountnumber from parentOrder
            if(!mapParentOrderAccNumSeq.isEmpty() && !lstAccNumber.isEmpty()){
                for(Order parentOrder: mapParentOrderAccNumSeq.keySet()){
                    Set<String> setUpdatedAccSeq = mapParentOrderAccNumSeq.get(parentOrder);
                    for(Account acc : lstAccNumber){
                        if(setUpdatedAccSeq.contains(acc.AccountNumber)){
                            setUpdatedAccSeq.remove(acc.AccountNumber);
                        }
                    }
                    List<String> lstUpdatedAccSeq = new List<String>(setUpdatedAccSeq);
                    String finalAccountSequence= String.join(lstUpdatedAccSeq,',');
                    parentOrder.Order_Account_Sequence__c=finalAccountSequence;
                    lstUpdatedParentOrder.add(parentOrder);
                }
            }
            if(!lstUpdatedParentOrder.isEmpty()){
                update lstUpdatedParentOrder;
                
            }
        }
    }
    
    /**
    *  @Description - US. #476 (JAPAN): Get Map of Parent Order alongwith associated account sequence
    *  @name - getMapParentOrderAccNumSeq
    *  @param - lstParentOrder - list parent order
    *  @return - Map<Order,Set<String>>
    **/ 
    private static Map<Order,Set<String>> getMapParentOrderAccNumSeq(List<Order> lstParentOrder){
        Map<Order,Set<String>> mapParentOrderAccNumSeq = new Map<Order,Set<String>>();
        if(!lstParentOrder.isEmpty()){
            for(Order parentOrder : lstParentOrder){
                Set<String> setAccSequence = new Set<String>();
                if(parentOrder.Order_Account_Sequence__c!=null){
                    setAccSequence.addAll(parentOrder.Order_Account_Sequence__c.split(','));
                    mapParentOrderAccNumSeq.put(parentOrder, setAccSequence);
                }
            }
        }
        return mapParentOrderAccNumSeq;
    }
    
    /**
    *  @Description - US. #590 : Submit return order or multi return order for approval..
    *  @name - submitReturnOrMultiReturnOrderForApproval
    *  @param - mapOldOrders - map of Order , lstNewOrders - List of Orders
    *  @return - void
    **/
    public static void submitReturnOrMultiReturnOrderForApproval(Map<Id,Order> mapOldOrders,List<Order> lstNewOrders){
        Set<Id> setOfOrderIds = new Set<Id>();
        //Map<Id,Decimal> mapOfMultiOrderToChildOrderLPFR = new Map<Id,Decimal>();
        for(Order ord : lstNewOrders){
            if(((ord.LPFR_Return_Value__c != mapOldOrders.get(ord.Id).LPFR_Return_Value__c) || 
               (ord.Status != mapOldOrders.get(ord.Id).Status && ord.Status == CRM_AppConstants.ORDER_STAGE_In_SAP)) && 
                ord.RecordTypeId != CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER && ord.RecordTypeId != CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN &&  ord.RecordTypeId != CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_REVENUE_SHARE){
                
                if(ord.LPFR_Return_Value__c != null && ord.Status == CRM_AppConstants.ORDER_STAGE_In_SAP && ord.Return_Approval__c == null){
                    if(ord.Multi_Order__c != null){
                        setOfOrderIds.add(ord.Multi_Order__c);
                        //Defect: 4829 start
                        /*if(ord.Sales_Organisation__c == CRM_AppConstants.TERRITORY_GERMANY_CODE && ord.LPFR_Return_Value__c != mapOldOrders.get(ord.Id).LPFR_Return_Value__c){
                            if(mapOfMultiOrderToChildOrderLPFR.containsKey(ord.Multi_Order__c)){
                                Decimal lpfr = mapOfMultiOrderToChildOrderLPFR.get(ord.Multi_Order__c) + ord.LPFR_Return_Value__c;
                                mapOfMultiOrderToChildOrderLPFR.put(ord.Multi_Order__c,lpfr);
                            }else{
                                mapOfMultiOrderToChildOrderLPFR.put(ord.Multi_Order__c,ord.LPFR_Return_Value__c);
                            }    
                        }*/ //Defect: 4829 end
                    }else if(ord.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_RETURN){
                        setOfOrderIds.add(ord.Id);
                    }
                }
            }
        }
        
        if(!setOfOrderIds.isEmpty()){
            //Set<Id> accountOwnerIds = new Set<Id>(); //Commented for ER-006683
            List<Order> lstOrderForAp = new List<Order>();
            //Map<Id,List<CRM_Germany_Approval_Rule__c>> mapAccOwnerIdToCSlst = new Map<Id,List<CRM_Germany_Approval_Rule__c>>(); //Commented for ER-006683
            List<Order> lstOfOrderNotReqAp = [SELECT Id,Multi_Order__c From Order
                                              WHERE Multi_Order__c IN :setOfOrderIds AND  
                                              (LPFR_Return_Value__c = null OR Status != :CRM_AppConstants.ORDER_STAGE_In_SAP)];
            if(!lstOfOrderNotReqAp.isEmpty()){
                for(Order ord : lstOfOrderNotReqAp){
                    if(setOfOrderIds.contains(ord.Multi_Order__c)){
                        setOfOrderIds.remove(ord.Multi_Order__c);
                    }
                    //Defect: 4829 start
                    /*if(mapOfMultiOrderToChildOrderLPFR.containsKey(ord.Multi_Order__c)){
                        mapOfMultiOrderToChildOrderLPFR.remove(ord.Multi_Order__c);
                    }*/  //Defect: 4829 end
                }
            }
           
            if(!setOfOrderIds.isEmpty()){
                Set<Id> setExistAPOrderIds = new Set<Id>();
                for(ProcessInstance pi : [select TargetObjectId from ProcessInstance where TargetObjectId In :setOfOrderIds]){
                    setExistAPOrderIds.add(pi.TargetObjectId);
                }
                if(!setExistAPOrderIds.isEmpty()){
                    setOfOrderIds.removeAll(setExistAPOrderIds);
                }
                lstOrderForAp = [Select Id,OwnerId,Sales_Organisation__c,Account.OwnerId,LPFR_Return_Value__c From Order Where Id IN :setOfOrderIds];
                 //US#992 start
                //Set<Id> orderids = new Set<Id>(); //Commented for ER-006683
                //US#992 end
                for(Order orderObj : lstOrderForAp){
                    //orderids.add(orderObj.id); //US#992 //Commented for ER-006683
                    if(orderObj.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE){
                        sendOrderForAnApproval(orderObj.Id,orderObj.OwnerId,null);
                    }
                    //US#633 : Geremany Return Order Approval Process Changes 
                    /*else if (CRM_AppConstants.GERMANY_SALES_ORGS.contains(orderObj.Sales_Organisation__c)){ //Commented for ER-006683
                      accountOwnerIds.add(orderObj.Account.OwnerId);  
                    }*/
                }
                //US#992 start 
                /*Map<Id,Id> mapOrderToUser =new Map<Id,Id>(); //Commented for ER-006683
                mapOrderToUser = fetchUserforOrder(orderids);
                //US#992 end
                //US#633 : Geremany Return Order Approval Process Changes 
                List<Order> lstAutoApproveOrder = new List<Order>();
                if(!accountOwnerIds.isEmpty()){
                    mapAccOwnerIdToCSlst = getMapOfGermanApprovalProcessCS(accountOwnerIds);
                    CRM_Germany_Approval_Rule__c MaxLinmitGAR =  CRM_Germany_Approval_Rule__c.getInstance('Maximum_Limit') != null ? CRM_Germany_Approval_Rule__c.getInstance('Maximum_Limit') : null;
                    for(Order orderObj : lstOrderForAp){
                        if(mapAccOwnerIdToCSlst.containsKey(orderObj.Account.OwnerId)){
                            String approverId;
                            Decimal lastChildOrderLPFR = 0;*/ //Commented for ER-006683
                            //Defect: 4829 start
                            /*if(mapOfMultiOrderToChildOrderLPFR.containsKey(orderObj.Id)){
                                lastChildOrderLPFR = mapOfMultiOrderToChildOrderLPFR.get(orderObj.Id);
                            }*/ //Defect: 4829 end
                            /*Decimal LPFRAmount = orderObj.LPFR_Return_Value__c + lastChildOrderLPFR; //Commented for ER-006683
                            if(MaxLinmitGAR != null && LPFRAmount > MaxLinmitGAR.Approval_Limit_From__c){
                                approverId = MaxLinmitGAR.Approver__c;
                            }else{
                                for(CRM_Germany_Approval_Rule__c gar : mapAccOwnerIdToCSlst.get(orderObj.Account.OwnerId)){
                                    if(LPFRAmount > gar.Approval_Limit_From__c && LPFRAmount <= gar.Approval_Limit_To__c){
                                        //US#992 start Returns submitted by people other than Account owner, even if they are for my accounts, are still routed to Account Owner for approval
                                       if(!gar.Auto_Approve__c){
                                            approverId = gar.Approver__c;
                                        }else{
                                            if(mapOrderToUser.containsKey(orderObj.id) && orderObj.Account.OwnerId != mapOrderToUser.get(orderObj.id)){
                                                  approverId = orderObj.Account.OwnerId;
                                            }else{
                                                orderObj.Return_Approval__c = CRM_AppConstants.RETURN_ORDER_RETURN_APPROVAL;
                                                lstAutoApproveOrder.add(orderObj);
                                            }
                                        }//US#992 end    
                                    }
                                }
                            }
                            if(approverId != null)
                                sendOrderForAnApproval(orderObj.Id,orderObj.OwnerId,approverId);
                        }
                    } 
                    //US#992 start Returns submitted by people other than Account owner, even if they are for my accounts, are still routed to Account Owner for approval
                    if(!lstAutoApproveOrder.isEmpty()){
                        update lstAutoApproveOrder;
                    }//US#992 end   
                }*/ //Commented for ER-006683
            }
        }
    }
    
    /**
    *  @Description - US#992 Method to get UserId that changed the status from Open to Submitted
    *  @name - fetchUserforOrder
    *  @param - Id orderIdForApprover
    *  @return - Id UserId
    **/
    /*public static Map<Id,Id> fetchUserforOrder(Set<Id> orderIdForApprover){ //Commented for ER-006683
        
        Map<Id,Id> mapOrderToUser =new Map<Id,Id>();
        List<OrderHistory> lstOrderhistory =new List<OrderHistory>();
        if(!orderIdForApprover.isEmpty()){
            if(Test.isRunningTest()){  //if TEST, fill the map as Order History cannot be tested directly
                List<Id> orderTestIds =new List<Id>();
                orderTestIds.addall(orderIdForApprover); 
                Id orderApproverId = [Select Id From User Where FirstName = 'Order' AND LastName = 'Aprover User'].Id;
                if(orderApproverId!=null){
                    mapOrderToUser.put(orderTestIds[0],orderApproverId);
                }
             }else{ 
                    lstOrderhistory =[SELECT CreatedById,Field,Id,IsDeleted,NewValue,OldValue,OrderId 
                                                    FROM OrderHistory 
                                                    WHERE orderid IN: orderIdForApprover 
                                                    AND Field ='Status'];
                    for(OrderHistory orderHisRec :lstOrderhistory ){
                        if(orderHisRec.OldValue == CRM_AppConstants.ORDER_STATUS_OPEN && orderHisRec.NewValue == CRM_AppConstants.ORDER_STAGE_SUBMITTED){
                            if(!mapOrderToUser.containsKey(orderHisRec.OrderId)){
                                mapOrderToUser.put(orderHisRec.OrderId,orderHisRec.CreatedById);
                            }
                        } 
                    }
                }
        }
        return mapOrderToUser; 
    }*/ //Commented for ER-006683
    
    /**
    *  @Description - Methos to get German Custom Setting Apporal Rule Map
    *  @name - getMapOfGermanApprovalProcessCS
    *  @param - accountOwnerIds - Account Owner Id Set
    *  @return - Map<Id,List<CRM_Germany_Approval_Rule__c>>
    **/
    /*private static Map<Id,List<CRM_Germany_Approval_Rule__c>> getMapOfGermanApprovalProcessCS(Set<Id> accountOwnerIds) { //Commented for ER-006683
        Map<Id,List<CRM_Germany_Approval_Rule__c>> mapAccOwnerIdToCSlst = new Map<Id,List<CRM_Germany_Approval_Rule__c>>();
        for(CRM_Germany_Approval_Rule__c gar : [SELECT Account_Owner__c,Approval_Limit_From__c,Approval_Limit_To__c,Approver__c,Auto_Approve__c,Id 
                                                FROM CRM_Germany_Approval_Rule__c 
                                                WHERE Account_Owner__c IN :accountOwnerIds]){
            if(mapAccOwnerIdToCSlst.containskey(gar.Account_Owner__c)){
                mapAccOwnerIdToCSlst.get(gar.Account_Owner__c).add(gar);
            }else{
                mapAccOwnerIdToCSlst.put(gar.Account_Owner__c,new List<CRM_Germany_Approval_Rule__c>{gar});
            }
        }
        return mapAccOwnerIdToCSlst;
    }*/ //Commented for ER-006683
    
    /**
    *  @Description - Methos to submit Order for Approval Process
    *  @name - sendOrderForAnApproval
    *  @param - objOrderId - order Id
    *  @return - void
    **/
    private static void sendOrderForAnApproval(Id objOrderId,Id submitterId,String nextApprover) {
        //Create an approval request for the Order
        Approval.ProcessSubmitRequest reqApproval = new Approval.ProcessSubmitRequest();
        reqApproval.setObjectId(objOrderId);
        reqApproval.setSubmitterId(submitterId);
        //US#633 
        if(nextApprover != null)
            reqApproval.setNextApproverIds(new List<Id>{(Id)nextApprover});
        Approval.ProcessResult resultApprovalProcess = Approval.process(reqApproval);
    }
    
    /**
    *  @Description - Method to update Initial Quantity on Deal Product
    *  @name - updateInitialQuantityOnDealProduct
    *  @param - setOfOrderIds - PArent Order Id set
    *  @return - void
    **/
    private static void updateInitialQuantityOnDealProduct(Set<Id> setOfOrderIds){
        List<OrderItem> lstOrderProducts = new List<OrderItem>();
        Set<Id> dealIds = new Set<Id>();
        Map<String,Decimal> mapOfDealAndProductKeyToQuantity = new Map<String,Decimal>();
        Map<Id,Decimal> mapOfDealProductIdToQuantity = new Map<Id,Decimal>();
        
        if(setOfOrderIds.size() > 0){
            lstOrderProducts = [Select Id,OrderId,Order.OpportunityId,PricebookEntryId,PricebookEntry.Product2Id,PricebookEntry.Product2.ProductCode,Quantity From OrderItem Where OrderId IN :setOfOrderIds];
            if(!lstOrderProducts.isEmpty()){
                for(OrderItem oi : lstOrderProducts){
                    String strKey = oi.Order.OpportunityId+'-'+oi.PricebookEntry.Product2Id;
                    mapOfDealAndProductKeyToQuantity.put(strKey,oi.Quantity);
                    dealIds.add(oi.Order.OpportunityId);
                }
            }
            if(!dealIds.isEmpty()){
                for(OpportunityLineItem dp : [Select OpportunityId,Product2Id From OpportunityLineItem Where OpportunityId IN :dealIds]){
                    String strKey = dp.OpportunityId+'-'+dp.Product2Id;
                    
                    if(!mapOfDealAndProductKeyToQuantity.containsKey(strKey)){
                        mapOfDealProductIdToQuantity.put(dp.Id,0);
                    }else{
                        Decimal qty = mapOfDealAndProductKeyToQuantity.get(strKey);
                        mapOfDealProductIdToQuantity.put(dp.Id,qty);
                    }
                }
            }
        }
        
        if(mapOfDealProductIdToQuantity.size() > 0){
            Map<Id,Decimal> chunkMap = new Map<Id,Decimal>();
            integer tempChunkSize = CRM_Batch_Size__c.getInstance('UpdateInitialQtyOnDPFromMO') != null ? Integer.valueOf(CRM_Batch_Size__c.getInstance('UpdateInitialQtyOnDPFromMO').Batch_Size__c) : 200;
            integer chunkSize = mapOfDealProductIdToQuantity.size() < tempChunkSize ? mapOfDealProductIdToQuantity.size() : tempChunkSize;
            integer count = 0;
            for(String dpId : mapOfDealProductIdToQuantity.keySet()){
                count++;
                Decimal qty = mapOfDealProductIdToQuantity.get(dpId);
                if(count < chunkSize){
                    chunkMap.put(dpId,qty);
                }else{
                    chunkMap.put(dpId,qty);
                    System.enqueueJob(new CRM_RevertBackQtyIntoDpInitialQty(chunkMap));
                    chunkMap = new Map<Id,Decimal>();
                    count = 0;
                }
            }
            if(chunkMap.size() > 0 && chunkMap.size() < chunkSize){
                System.enqueueJob(new CRM_RevertBackQtyIntoDpInitialQty(chunkMap));
            }
        }
    }
    
     /**
    *  @Defect : 4239 
    *  @Description - Method to validate Order Products DChain Status 
    *  @name - validateAllOrderProducts
    *  @param - setOfOrderIds - Order Id set
    *  @return - void
    **/
    public static void validateAllOrderProducts(Set<Id> setOfOrderIds,List<Order> lstNewOrders){
      Map<Id,Order> mapNewOrders = new Map<Id,Order>(lstNewOrders);
      Map<Id,List<String>> mapOrderIdToOrderProduct = new Map<Id,List<String>>();
      // 01 =Active , 04 =On Hold & 11=Initial & 05 ,Z5 for Non-Returnable 
        Set<String> sAPdistChainProductStatus = new Set<String>{'01','04','11','05','Z5'};
      for(OrderItem op : [SELECT Id,OrderId,PricebookEntry.Product2Id,PricebookEntry.Product2.SAP_Dist_chain_product_Status__c,PricebookEntry.Product2.ProductCode
                  FROM OrderItem WHERE OrderId IN :setOfOrderIds]){
        if(!sAPdistChainProductStatus.contains(op.PricebookEntry.Product2.SAP_Dist_chain_product_Status__c)){
          if(!mapOrderIdToOrderProduct.containsKey(op.OrderId)){
            mapOrderIdToOrderProduct.put(op.OrderId,new String[]{});
          }
          String productCode = op.PricebookEntry.Product2.ProductCode;
          mapOrderIdToOrderProduct.get(op.OrderId).add(productCode);
        }
      }
      for(Id oId : mapOrderIdToOrderProduct.KeySet()){
        String commanErrorMsg = ' '+system.label.CRM_Dist_Chain_Status_Msg+' ';
        List<String> productCodes = mapOrderIdToOrderProduct.get(oId);
        if(mapNewOrders.containsKey(oId) && !productCodes.isEmpty()){
          commanErrorMsg += String.join(productCodes,' , ');
          Order ord = mapNewOrders.get(oId);
          ord.addError(commanErrorMsg);
        }
      }
    }
    
    /**
    *  @Defect : 4244 : Germany
    *  @Description - Method to validate Multi Return Order 
    *  @name - validateMultiReturnOrders
    *  @param - setOfOrderIds - Order Id set, lstNewOrders - List Of New Orders
    *  @return - void
    **/
    /*public static void validateMultiReturnOrders(Set<Id> setMultiReturnOrderIds,List<Order> lstNewOrders){ //Commented for ER-006683
      Map<Id,Order> mapNewOrders = new Map<Id,Order>(lstNewOrders);
      Set<Id> accountOwnerIds = new Set<Id>();
      List<Order> multiReturnOrders = new List<Order>();
      
      for(Order ord : [SELECT Id,Account.OwnerId FROM Order WHERE Id IN :setMultiReturnOrderIds]){
        accountOwnerIds.add(ord.Account.OwnerId);
        multiReturnOrders.add(ord);
      }
      
      if(!accountOwnerIds.isEmpty()){
      Map<Id,List<CRM_Germany_Approval_Rule__c>> mapAccOwnerIdToCSlst = getMapOfGermanApprovalProcessCS(accountOwnerIds);
      for(Order ord : multiReturnOrders){
        if(!mapAccOwnerIdToCSlst.containsKey(ord.Account.OwnerId) && mapNewOrders.containsKey(ord.Id)){
          mapNewOrders.get(ord.Id).addError(System.label.CRM_Multi_Return_Order_Account_Owner_Has_No_LPFRAmount_Limits_Msg);
         }
       }
      }
    }*/ //Commented for ER-006683
    
    /**
     *@defect#4542 : Japan
     *@Description - Method to update requested delivery date on child order based on parent order
     *@name - updateAllChildOrders
     *@param - mapOldOrders - Map of Order Old values
     *@param - lstNewOrders - map of Order new values
     *@return - void
     **/
     public static void updateAllChildOrders(List<Order> lstAllChildOrders,Map<Id,Order> mapOldOrders){
         List<Order> lstchildOrdersToUpdate = new List<Order>();    
         if(lstAllChildOrders != null){
            try{
                for(Order orderObj : lstAllChildOrders){
                    system.debug('parent Order effective date ----'+mapOldOrders.get(orderObj.Multi_Order__c).EffectiveDate);
                    system.debug('child Order effective date ----'+orderObj.EffectiveDate);
                    if(mapOldOrders.get(orderObj.Multi_Order__c).EffectiveDate == orderObj.EffectiveDate){
                        orderObj.EffectiveDate = orderObj.Multi_Order__r.EffectiveDate;
                        lstchildOrdersToUpdate.add(orderObj);
                    }
                }
                
                if(!lstchildOrdersToUpdate.isEmpty()){
                    system.debug('Update records');
                    CRM_AppConstants.orderActivateFlag = false;
                    update lstchildOrdersToUpdate;
                }
            }catch(System.DMLException de){
                system.debug('in exception');
                CRM_AppConstants.orderActivateFlag = true;
                List<String> orderNumbers = new List<String>();
                for(integer i=0;i<de.getNumDml();i++){
                    orderNumbers.add(lstAllChildOrders.get(de.getDmlIndex(i)).OrderNumber);
                }
                lstAllChildOrders.get(0).addError(String.join(orderNumbers,'-')+' : '+de.getDmlMessage(0),false); 
            } 
        }
        
     }
}