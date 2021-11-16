/**
   @Author Cognizant
   @name CRM_AddOrderProductsFromConfig
   @CreateDate 10 June 2016
   @Description This class will be use to generate order from assortment config.
   @Version <1.0>
   @reference Requirement no 85
*/

 global with sharing class CRM_AddOrderProductsFromConfigController{
     Opportunity Opp;
     public CRM_AddOrderProductsFromConfigController(ApexPages.StandardController controller){
         this.Opp = (Opportunity)controller.getRecord();
     }
     
     
      @RemoteAction  
      global static PageReference initCheck(Id OppId){
          PageReference pageRef;
          //Id OppId = Opp.Id;
          Map<String, Object> params = new Map<String, Object>(); 
          
          List<Opportunity> oppList = new List<Opportunity>();
          oppList = [SELECT ID,Account.Status__c,Account.Planning_Customer__c,StageName,Bundle__c,Bundle__r.RecordType.DeveloperName FROM Opportunity WHERE Id=: OppId LIMIT 1];    
          Savepoint sp = Database.setSavepoint();
          try{
              
            Boolean isValidAccount = CRM_ApplicationUtility.isValidAccount(oppList[0].Account);
            if(!isValidAccount){
                throw new CRM_AddOrderProductsFromConfigControllerException(Label.CRM_Restrict_Order_Generation_for_Filter);
            } 
            
            if(oppList[0].StageName != CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED){
                throw new CRM_AddOrderProductsFromConfigControllerException(Label.CRM_Restrict_Order_Generation_on_Deal_Stage);
            } 
           
            if(CRM_Functional_Permissions__c.getInstance().PreventGenerateOrderFromConfig__c) {
                    throw new CRM_AddOrderProductsFromConfigControllerException (Label.CRM_Generate_Order_From_Config_No_Access_Error);
            }
              
              List<Config__c> lstConfig = [SELECT id,Name FROM Config__c WHERE Assortment__c =: oppList[0].Bundle__c];
              system.debug('Config List========>'+ lstConfig);
              /*Condition runs if their is no assortment on deal OR if their is an assortment on deal but not of caimpaign type*/
             
              if(oppList[0].Bundle__c== null && oppList!=null || 
                 oppList[0].Bundle__c !=null && oppList[0].Bundle__r.RecordType.DeveloperName != 'Campaign_Assortment' ||
                 lstConfig.size()==0){
                   
                   
                   /*Passing the opportunity Id to the Flow and Calling the Flow*/
                   params.put('var_DealId',oppList[0].Id);
                   Flow.Interview.Opportunity_to_Order CRMGenerateOrder = new Flow.Interview.Opportunity_to_Order(params);
                   CRMGenerateOrder.Start();
                   String returnValue = (String)CRMGenerateOrder.getVariableValue('var_NewOrderId');
                   if(String.isNotBlank(returnValue)){
                        pageRef= new PageReference('/'+returnValue+'/e?retURL=%2F'+returnValue);
                        pageRef.setRedirect(true);
                    }
                    return pageRef;   
              }              
            return null;
           }  
            catch(Exception e){
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            //ApexPages.addMessage(myMsg);
            Database.rollback(sp);
            throw new CRM_AddOrderProductsFromConfigControllerException (e.getMessage());
            return null;
            }
      }
     
     
     
     /**
     *  Method
     *  @name getConfig
     *  @param opportunityId - Id of the opportunity record whose assortment configs are to be loaded
     *  @return ConfigProduct[] - list of Config Products to be made available for user selection
     */
    @RemoteAction
    global static Config[] getConfig(Id bundleId) {
        config[] lstconfigs = new config[]{};
        Config__c[] configs;
        if(bundleId!=null){
            configs = [SELECT Id,Name,Config_Number_Txt__c,Record_Type_Name__c FROM Config__c WHERE Assortment__c =: bundleId order By Name];
        }
        if(configs != null && configs.size() > 0) {
            for(Config__c conf: configs){
                Config c = new Config();
                c.config = conf;
                c.isSelected = false;
                lstconfigs.add(c);
            }
        }
        return lstconfigs;
    }
    
    
     
     /**
     *  Method
     *  @name generateOrder
     *  @param lstconfig - List of all the configs
     *  @configId - Selected configId
     *  @return true/false - Error or Success message on successfull creation of Order.
     */
    @RemoteAction
    global static PageReference  generateOrder(Id configId, Id OppId){
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<Account> lstAcc = new List<Account>();
        
       /*Step 1: Fetching the Opportunity(Deal) and required Fields*/
        if(!OppId.equals(null)){
            lstOpp = [SELECT AccountId,Bundle__r.RecordType.DeveloperName,Pricebook2Id,Start_Date__c,
                                    CloseDate,CurrencyIsoCode FROM Opportunity WHERE Id=: OppId Limit 1];
        }                            
       
       /*Step 2:Fetching the Account associated with the Opportunity(Deal)*/
        if(lstOpp.size()>0 || lstOpp!=null || lstOpp[0].AccountId!=null){
            lstAcc = [SELECT BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,
                      ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry
                      FROM Account WHERE Id =: lstOpp[0].AccountId LIMIT 1]; 
        }
        
       /*Step 3: Fetching the Standard RecordType For Creating a Standard Order */
          RecordType recOrderStandard = [SELECT DeveloperName,Id FROM RecordType 
                                         WHERE DeveloperName =: 'Standard' and SobjectType =: 'Order']; 
       
       /*Step 4: Generating Order From Opportunity(Deal) and The Account associated with the Opportunity(Deal)*/                                  
          Opportunity Opp= lstOpp[0];
          Account Acc = lstAcc[0];
          List<Order> lstOrder = new List<Order>();
         /*Intializing Order and assigning value to order field*/ 
              Order odr = new Order();
              odr.AccountId = Opp.AccountId;
              odr.EffectiveDate = System.Today();
              odr.Status = 'Open';       
              odr.OpportunityId = Opp.Id; 
              odr.Pricebook2Id = Opp.Pricebook2Id;
              odr.CurrencyIsoCode = Opp.CurrencyIsoCode;
              odr.BillingCity = Acc.BillingCity;
              odr.BillingCountry  = Acc.BillingCountry;
              odr.BillingPostalCode = Acc.BillingPostalCode;
              odr.BillingStreet = Acc.BillingStreet;
              odr.ShippingStreet = Acc.ShippingStreet; 
              odr.ShippingCity = Acc.ShippingCity; 
              odr.ShippingState = Acc.ShippingState;
              odr.ShippingCountry = Acc.ShippingCountry; 
              odr.ShippingPostalCode = Acc.ShippingPostalCode; 
              odr.RecordTypeId = recOrderStandard.Id; 
        /*!End of Order Intialization*/
        lstOrder.add(odr);
        
       /*Step 5: Creating Order */    
        if(lstOrder.size()==1){
            insert lstOrder;    
        }
       /*This function gets called only if their is a assortment on deal and the assortment is of type Caimpaign 
         in any other scenarios the function doesn't get called*/   
       PageReference orderPage= new PageReference('/'+lstOrder[0].id);
       Boolean result ; 
       boolean quantityFlag = false;
       if(configId != null){
           result = generateOrderProduct(lstOrder[0].id,configId);
           
           List<Config__c> tempConfig = [Select Id,RecordTypeId From Config__c Where Id =:configId limit 1];
           if(!tempConfig.isEmpty() && tempConfig.get(0).RecordTypeId == CRM_RecordTypeUtil.RT_CONFIG_SBOM)
               quantityFlag = true;
       }
       
       /*Adding Config on Order after adding order product to bypass the validation rule on Order.*/
       for(Order od:lstOrder){
           if(quantityFlag)
               od.Quantity__c =  1;
           od.Config__c = configId;
       }
       update lstOrder;
       return orderPage;       
    }
    
    
    /**
     *  Method
     *  @name generateOrderProduct
     *  @orderId - Id of Generated Order in generateOrder Function
     *  @return true/false - Generate Order Product on successfull creation of Order.
     */
    public static Boolean generateOrderProduct(Id orderId,Id configId){
        
        List<Config_Product__c> lstConfigProd = new List<Config_Product__c>();
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        List<Config__c> lstConfigAssort = new List<Config__c>();
        Map<String,PricebookEntry> mapPricebookEntries = new Map<String,PricebookEntry>();
        List<Bundle_Product__c> lstAssortProduct = new List<Bundle_Product__c>();
        Map<Id,Decimal> productListPriceMap = new Map<Id,Decimal>();
        Map<Id,Decimal> productAssortPriceMap = new Map<Id,Decimal>();
        
        if(!orderId.equals(null) && !configId.equals(null)){
            lstConfigAssort = [SELECT Assortment__c,Assortment__r.Price_Book__c, Assortment__r.CurrencyIsoCode
                             FROM Config__c WHERE Id=: configId Limit 1];
            
            lstAssortProduct = [SELECT Product__c,List_Price__c,Assortment_Price__c FROM Bundle_Product__c WHERE Bundle__c =: lstConfigAssort[0].Assortment__c];                   
            
            /*Query Updated to not select product whose material type is UNBW*/
            lstConfigProd = [SELECT Id,Config__c,Product__c,Product_Code__c,Quantity__c 
                             FROM Config_Product__c WHERE Config__c =: configId  AND Product__r.SAP_Material_Type__c!=: CRM_AppConstants.UNBW_SAP_MATERIAL_TYPE];
            
            if(lstConfigAssort.size()>0 &&  lstConfigProd.size()>0){
               mapPricebookEntries = getPricebookEntries(lstConfigProd,lstConfigAssort);
            }
            
            for(Bundle_Product__c  b: lstAssortProduct){
                productListPriceMap.put(b.Product__c, b.List_Price__c );
                productAssortPriceMap.put(b.Product__c , b.Assortment_Price__c );
            }
            
            if(mapPricebookEntries.size()>0 && mapPricebookEntries!=null){
                /*Outer Loop is going to execute only once.*/
                  for(Config__c conf: lstConfigAssort){
                                        
                      /*Inner loop is going to execute multiple times.*/
                      for(Config_Product__c confProd: lstConfigProd){
                         String mapUniqueKey = conf.Assortment__r.Price_Book__c +'-'
                                               + confProd.Product__c +'-'+ conf.Assortment__r.CurrencyIsoCode;
                                               system.debug('generateOrderProduct=mapUniqueKey=======>'+ mapUniqueKey);
                        if(mapPricebookEntries.get(mapUniqueKey) !=null){  
                         PricebookEntry pbe = mapPricebookEntries.get(mapUniqueKey);                      
                         OrderItem odrItem = new OrderItem();
                         odrItem.OrderId = orderId;
                         odrItem.PricebookEntryId =  pbe.Id;
                         odrItem.Quantity = (confProd.Quantity__c == 0 ? 1 : confProd.Quantity__c);
                         if(odrItem.Quantity==null){
                            odrItem.Quantity =1; 
                         }
                         
                         if(productAssortPriceMap.get(confProd.Product__c)!=null && productListPriceMap.get(confProd.Product__c)!=null){
                         odrItem.UnitPrice = (productAssortPriceMap.get(confProd.Product__c)!=0?productAssortPriceMap.get(confProd.Product__c):productListPriceMap.get(confProd.Product__c)) ;
                         }
                         else{
                             odrItem.UnitPrice =0.0;
                         }
                             
                         lstOrderItem.add(odrItem);/*Assigning Created Order Product to the List*/
                         } 
                      }/*End of Inner Loop*/
                  }/*End of Outer Loop*/
                
                if(lstOrderItem!=null)
                insert lstOrderItem;
            }
           
        }
        return true;
    }
     /**
     *  Method
     *  @name getPricebookEntries
     *  @lstConfigProd- List of Config Products
     *  @lstConfigAssort- Assortment Data related to config
     *  @return Map - Return List of Pricebook Entries 
     */
    public static Map<String,PricebookEntry> getPricebookEntries(List<Config_Product__c> lstConfigProd,List<Config__c> lstConfigAssort){    
      Set<String> setCurrencyCodes = new Set<String>();
      Set<Id> setPricebookIds = new Set<Id>();
      Set<Id> setProductIds = new Set<Id>();
      Map<String,PricebookEntry> mapPricebookEntries = new Map<String,PricebookEntry>();
     
      /*Outer Loop is going to execute only once.*/
      for(Config__c conf: lstConfigAssort){
          setCurrencyCodes.add(conf.Assortment__r.CurrencyIsoCode);
          setPricebookIds.add(conf.Assortment__r.Price_Book__c);
          
          /*Inner loop is going to execute multiple times.*/
          for(Config_Product__c confProd: lstConfigProd){
             setProductIds.add(confProd.Product__c);  
          }/*End of Inner Loop*/
      }/*End of Outer Loop*/
            
      for(PricebookEntry pbe : [SELECT Id, CurrencyISOCode, Product2Id, Pricebook2Id  from PricebookEntry 
                                WHERE Pricebook2Id in: setPricebookIds AND Product2Id in :setProductIds 
                                AND CurrencyISOCode in: setCurrencyCodes ]) {
        String mapUniqueKey = pbe.Pricebook2Id +'-'+ pbe.Product2Id +'-'+ pbe.CurrencyISOCode;
        mapPricebookEntries.put(mapUniqueKey, pbe);
      }
      
      return mapPricebookEntries;  
    }
    
    
    /* Wrapper class to be used as javascript remoting object */
    global class Config {
        global Boolean isSelected {get;set;}
        global Config__c config {get;set;}
    }
    
    global class CRM_AddOrderProductsFromConfigControllerException extends Exception {
    }

}/*End of Class*/