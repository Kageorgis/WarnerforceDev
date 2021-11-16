public without sharing class CRM_DealProductHandler{

    public void scheduleHandler(Map<Id,OpportunityLineItem> mapOldDealProducts, Map<Id,OpportunityLineItem> mapNewDealProducts){
        if (mapOldDealProducts != null && mapNewDealProducts != null){
            List<Account> lstAccounts = new List<Account>();
            List<Id> lstAccountIDs = new List<Id>();
            List<Id> lstDealIDs = new List<Id>();
            
            for (OpportunityLineItem objDealProduct: mapOldDealProducts.values()){                
                if (mapNewDealProducts.containsKey(objDealProduct.Id) && mapNewDealProducts.get(objDealProduct.Id) != null && mapOldDealProducts.containsKey(objDealProduct.Id) && mapOldDealProducts.get(objDealProduct.Id) != null && mapOldDealProducts.get(objDealProduct.Id).TotalPrice != mapNewDealProducts.get(objDealProduct.Id).TotalPrice){
                    lstDealIDs.add(objDealProduct.OpportunityId);
                }
            }
            
            if (lstDealIDs != null && lstDealIDs.size() > 0){
                List<Opportunity> lstDeals = [SELECT Account.scheduleRevenueChanged__c from Opportunity WHERE Id IN: lstDealIDs]; 
                
                if (lstDeals != null && lstDeals.size() > 0){
                    for(Opportunity objDeal: lstDeals){
                        if (objDeal.Account != null && objDeal.Account.scheduleRevenueChanged__c != null && objDeal.Account.scheduleRevenueChanged__c != true)
                            lstAccountIDs.add(objDeal.AccountId);
                    }
                    
                    if (lstAccountIDs != null && lstAccountIDs.size() > 0){
                        lstAccounts = [SELECT Id, scheduleRevenueChanged__c FROM Account WHERE Id IN: lstAccountIDs];
                        if (lstAccounts != null && lstAccounts.size() > 0){
                            for (Account objAcct: lstAccounts){
                                objAcct.scheduleRevenueChanged__c = true;
                            }               
                            update lstAccounts;
                        }
                    }
                }
            }
        }
    }
    
    public void markDeletedDealItems(Map<Id,OpportunityLineItem> mapOldDealProducts) {
        system.debug('In markDeletedDealItems ... ');
        List<Opportunity_Line_Item_Deleted__c> lstDeletedDealItems = null;
        if (null != mapOldDealProducts){
            lstDeletedDealItems = new List<Opportunity_Line_Item_Deleted__c>();
            
            for (OpportunityLineItem objDealProduct: mapOldDealProducts.values()){                
                Opportunity_Line_Item_Deleted__c deletedDealItem = new Opportunity_Line_Item_Deleted__c();
                deletedDealItem.OpportunityId__c = objDealProduct.OpportunityId;
                deletedDealItem.OpportunityLineItemId__c = objDealProduct.Id;
                deletedDealItem.ProductId__c = objDealProduct.Product2Id;
                lstDeletedDealItems.add(deletedDealItem);
            }
        }
        
        if(null != lstDeletedDealItems && !lstDeletedDealItems.isEmpty())
            insert lstDeletedDealItems;
    }
    
    /* @US#501 
       @Description - Method to update the royalty fees if respective records is present in Custom settings
    *  @name - updateRoyaltyFeesFields
    *  @param - List of new deal products
    *  @returns - Null
    */
    public void updateRoyaltyFeesFields(List<OpportunityLineItem> lstNewDealProducts){
    

        List<Royalty_Fees__c> royaltyFeesList = Royalty_Fees__c.getall().values();
        Map<String,Royalty_Fees__c> royaltyFeeMap = new Map<String,Royalty_Fees__c>();
        String key;
        String searchKey;
        Royalty_Fees__c royalFeeInstance;
        String productLabel;
        String salesOrg;
        //US#594 Automated Estimation of Production Costs starts
        List<CRM_Production_Cost_Estimated__c> csAllValues = CRM_Production_Cost_Estimated__c.getAll().values();
        Map<String, CRM_Production_Cost_Estimated__c> mapCType = new Map<String, CRM_Production_Cost_Estimated__c>();
        DealProductRule[] dealProductAssignmentRules = new DealProductRule[]{};
        //Generate the Key and sort the records of Custom setting CRM_Production_Cost_Estimated__c
        for(CRM_Production_Cost_Estimated__c csValues : csAllValues){
            String countryTypeKey = '^';
            countryTypeKey += csValues.Country__c ;
            countryTypeKey += '-'+(csValues.Case_Type__c != null ? csValues.Case_Type__c : '(.*)');
            countryTypeKey += '-'+(csValues.Pack_Type__c != null ? csValues.Pack_Type__c : '(.*)');
            countryTypeKey += '-'+(csValues.Format__c != null ? csValues.Format__c : '(.*)');
            countryTypeKey += '-'+(csValues.Currency__c != null ? csValues.Currency__c : '(.*)');
            //US#958 - added code change to calculate production cost for FR based on product labels
            countryTypeKey += '-'+(csValues.Product_Label__c != null ? csValues.Product_Label__c : '(.*)');
            //US#958 - end
            mapCType.put(countryTypeKey,csValues);
            
            dealProductAssignmentRules.add(new DealProductRule(countryTypeKey,csValues));
            system.debug('countryTypeKey : '+countryTypeKey);
        }
        if(!dealProductAssignmentRules.isEmpty()){
            dealProductAssignmentRules.sort();
        }
        //US#594 Automated Estimation of Production Costs ends
        
        
        Set<Id> oppSet = new Set<Id>();
        Set<Id> prodSet = new Set<Id>();
        
        for(OpportunityLineItem oppLineItem : lstNewDealProducts){
            oppSet.add(oppLineItem.opportunityId);
            prodSet.add(oppLineItem.Product2Id);
        }
        
        //US #581: Populate Consignment Multiplier on Deal Product
        Map<Id,Opportunity> oppIdObjMap = new Map<Id,Opportunity>();
        if(!oppSet.isEmpty()){
        oppIdObjMap = new Map<Id,Opportunity>([Select Id,Account.Sales_Organization__c, Opportunity.AccountId, Opportunity.Account.Consignment_Customer__c,
                                                                   Opportunity.Account.Consignment_Multiplier_Video__c, Opportunity.Account.Consignment_Multiplier_Games__c,
                                                                   Override_Pricing__c, RecordTypeId ,Sales_Organisation__c,StageName,Account.Digital_Country_Code__c
                                                                   from Opportunity 
                                                                   where Id in : oppSet]);
        }
        List<Product2> lstProducts = new List<Product2>();
        if(!prodSet.isEmpty()){
            lstProducts = [SELECT Id,Product_Label__c, Type__c, Product_Format__c,
                                    Case_Type__c,RecordTypeId,Pack_Type__c,Production_Cost__c,CurrencyIsoCode 
                                    FROM Product2 
                                    WHERE Id IN : prodSet];
        }
        //US #581: Populate Consignment Multiplier on Deal Product
        Map<Id,Product2> prodIdObjMap = new Map<Id,Product2>();
        //US#594 Automated Estimation of Production Costs starts
        Map<id,Product2> mapIdProducts = new Map<id,Product2>();
        
        for(Product2 prod :lstProducts){
            prodIdObjMap.put(prod.id,prod);
            if((prod.Type__c == CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE || prod.Type__c == CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE)
                && prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT)
                {
                   mapIdProducts.put(prod.id,prod);
                }
        }
         
        //US#594 Automated Estimation of Production Costs ends
        
        for(Royalty_Fees__c royaltyFeeInstance : royaltyFeesList){
            
            if(royaltyFeeInstance.Label__c != null && royaltyFeeInstance.Sales_Organisation__c != null){
                key = royaltyFeeInstance.Label__c + '-' + royaltyFeeInstance.Sales_Organisation__c;
                royaltyFeeMap.put(key,royaltyFeeInstance);
            }
        }
        
        for(OpportunityLineItem objOppProduct : lstNewDealProducts){
            productLabel = prodIdObjMap.get(objOppProduct.Product2Id).Product_Label__c;
            salesOrg = oppIdObjMap.get(objOppProduct.OpportunityId).Account.Sales_Organization__c;
            
            //US#612 (Japan) : Update Override Pricing Checkbox on DP If deal Overide Pricing Checkbox is checked.
            if(oppIdObjMap.get(objOppProduct.OpportunityId).Override_Pricing__c && salesOrg == CRM_AppConstants.TERRITORY_JAPAN_CODE && oppIdObjMap.get(objOppProduct.OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL){
                objOppProduct.Override_Pricing__c = true;
            }
            
            if(productLabel != null && salesOrg != null){
                searchKey = productLabel + '-' + salesOrg;
                if(royaltyFeeMap.containsKey(searchKey)){
                    royalFeeInstance = royaltyFeeMap.get(searchKey);
                    objOppProduct.Royalty_Fee__c = royalFeeInstance.Fee__c;
                    objOppProduct.Royalty_Fee_Applied_to_Gross_Revenue__c = royalFeeInstance.Gross_Revenue__c;
                }
            }
            
            //US #581: Populate Consignment Multiplier on Deal Product
            if(salesOrg == CRM_AppConstants.TERRITORY_UK_CODE){
                if(oppIdObjMap.containsKey(objOppProduct.OpportunityId) && oppIdObjMap.get(objOppProduct.OpportunityId).Account.Consignment_Customer__c){
                    if(prodIdObjMap.containsKey(objOppProduct.Product2Id) && prodIdObjMap.get(objOppProduct.Product2Id).Type__c == CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE){
                        if(oppIdObjMap.get(objOppProduct.OpportunityId).Account.Consignment_Multiplier_Video__c != null){
                            objOppProduct.Consignment_Multiplier__c = oppIdObjMap.get(objOppProduct.OpportunityId).Account.Consignment_Multiplier_Video__c;
                        } else{
                            objOppProduct.Consignment_Multiplier__c = 0;
                        }
                    }
                    else if(prodIdObjMap.containsKey(objOppProduct.Product2Id) && prodIdObjMap.get(objOppProduct.Product2Id).Type__c == CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE){
                        if(oppIdObjMap.get(objOppProduct.OpportunityId).Account.Consignment_Multiplier_Games__c != null){
                            objOppProduct.Consignment_Multiplier__c = oppIdObjMap.get(objOppProduct.OpportunityId).Account.Consignment_Multiplier_Games__c;
                        } else {
                            objOppProduct.Consignment_Multiplier__c = 0;
                        }
                    }
                }   
            }
            //Defect #4090: Product Format from Product2
            objOppProduct.Format__c = prodIdObjMap.get(objOppProduct.Product2Id).Product_Format__c;
            
            //US#594  Automated Estimation of Production Costs  starts
            //If physical product and deal present for Estimation of Production Cost then update the cost with Estimated Production Cost
            if(mapIdProducts.containskey(objOppProduct.Product2id) && oppIdObjMap.containskey(objOppProduct.OpportunityId)){
                if(oppIdObjMap.get(objOppProduct.OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL){
                    if(mapIdProducts.get(objOppProduct.Product2id).Production_Cost__c == Null || mapIdProducts.get(objOppProduct.Product2id).Production_Cost__c == 0 ){
                       //Fetch The Product and Deal
                        Product2 product = mapIdProducts.get(objOppProduct.Product2id);
                        Opportunity deal = oppIdObjMap.get(objOppProduct.OpportunityId);
                        //Key creation from Product and Deal
                        //US#958 - added one more component to form the key 'product.Product_Label__c' for FR to calculate production cost based on product label.
                        String productKey = deal.Sales_Organisation__c +'-'+product.Case_Type__c + '-' +  product.Pack_Type__c + '-' + product.Product_Format__c + '-' +  product.CurrencyIsoCode + '-' +  product.Product_Label__c;
                        
                        system.debug('Product Key ===>>>'+ productKey);
                        //Check if key matches any Record in the Custom Setting                 
                        for(DealProductRule pgAssignmentRule : dealProductAssignmentRules){
                            Pattern regexPattern = Pattern.compile(pgAssignmentRule.ruleKey);
                            Matcher regexMatcher = regexPattern.matcher(productKey);
                            if(regexMatcher.matches()){
                                // First record that matches should be assigned to Deal Product
                                if(!objOppProduct.Production_Cost_Estimated__c){
                                    CRM_Production_Cost_Estimated__c rule = pgAssignmentRule.rule;
                                    objOppProduct.Production_Cost__c = rule.Estimated_Production_Cost__c;  
                                    objOppProduct.Production_Cost_Estimated__c =  true;
                                    break;
                                }
                            }//end if
                        }
                    }else if(mapIdProducts.get(objOppProduct.Product2id).Production_Cost__c != Null){
                        //If Production Cost present then move the cost to Deal Product.
                        objOppProduct.Production_Cost__c = mapIdProducts.get(objOppProduct.Product2id).Production_Cost__c;  
                    }
                }
            } //US#594 ends if
            
            //US#394 (Germany) : Update Contribution is under Minimum (Sales)/Contribution is under Minimum (Finance) Check box 
            if(oppIdObjMap.containsKey(objOppProduct.opportunityId) && oppIdObjMap.get(objOppProduct.opportunityId) != null){
                Opportunity deal = oppIdObjMap.get(objOppProduct.opportunityId);
                setDPAsContributionIsUnderMinimumForFinanceAndSalse(
                    objOppProduct,
                    null,
                    deal.RecordTypeId,
                    deal.Sales_Organisation__c,
                    deal.Account.Digital_Country_Code__c,
                    deal.StageName
                );
            }
        }
    }
    
    
    /**  US#172 Update Price Tier on deal product Has been changed as per US#985 for Rate Cards
        * @Description - Method to Update Price Tier on deal product from pricing record based on account and product
        * @name - updatePriceTierOnDealProduct
        * @param - List of new deal products
        * @returns - Null
     **/
    public void updatePriceTierOnDealProduct(List<OpportunityLineItem> lstNewDealProducts, Map<Id,OpportunityLineItem> mapOldDealProducts){ 
        Set<Id> setAccountIds =new Set<Id>();
        //Defect#4373 : added teo variables.
        List<OpportunityLineItem> filteredDealProds = new List<OpportunityLineItem>();
        map<Id,Product2> productIdMap = new map<Id,Product2>();
        map<Id,Opportunity> OpportunityIdMap = new map<Id,Opportunity>();
        //US#663 :  added variable to verify wether price tier or promo price is changed.
        map<Id,Pricebook_Entry_Period__c> mapPbepRecords = new map<Id,Pricebook_Entry_Period__c>();
        map<Id,Boolean> mapPbepIdChangePromoPricing = new map<Id,Boolean>();
        map<Id,Pricebook_Entry_Period__c> pbepIdMap = new map<Id,Pricebook_Entry_Period__c>();
        
        // DEAL PRODUCT INSERT SCENARIO
        if(mapOldDealProducts == null || mapOldDealProducts.size() == 0){ 
            system.debug('before insertcode');
            set<Id> setPbepIds = new set<Id>();
            //Defect#4373 : added variables for product and opp. ids.
            set<Id> setProductIds = new set<Id>();
            set<Id> setOpportunityIds = new set<Id>();
            
            for(OpportunityLineItem dealProd : lstNewDealProducts){
                //Defect#4373 : added check if price tier is null then only check for PBEP's.
                if(dealProd.Price_Tier__c != null 
                    || dealProd.Promoted_price__c != null){
                    setOpportunityIds.add(dealProd.OpportunityId);
                }
                if(dealProd.Pricebook_Entry_Period__c!=null){
                    setPbepIds.add(dealProd.Pricebook_Entry_Period__c);
                }

            }
            if(!setOpportunityIds.isEmpty()){
               OpportunityIdMap = new map<Id,Opportunity>([SELECT Id,Storefront_Account__c ,Start_Date__c
                                                               FROM Opportunity 
                                                               WHERE Id IN: setOpportunityIds AND Storefront_Account__c!=NULL]);                                     
            }
             
            if(!setPbepIds.isEmpty()){  
                pbepIdMap = new map<Id,Pricebook_Entry_Period__c>([SELECT id,Pricing__c,Price_Tier__c, Product__r.Country_Code__c ,Account_Price__c,
                                                                            Product__r.Product_Format__c,Product__r.Tittle_Content_Type__c ,
                                                                            Product__r.Product_Market__c,Client_Avail__r.Local_DVD_Release_Date__c
                                                                        FROM Pricebook_Entry_Period__c 
                                                                        WHERE Id IN:setPbepIds ]);
            }
            Map<Id,Integer> mapDealProductAge = new Map<Id,Integer>();
            for(OpportunityLineItem dealProd : lstNewDealProducts){
                
               //Defect#4373 : added code snipet to check if user has entered the price tier. 
                if(!pbepIdMap.isEmpty() && pbepIdMap.containsKey(dealProd.Pricebook_Entry_Period__c) && ((dealProd.Price_Tier__c != null) || (dealProd.Price_Tier__c == null && dealProd.Promoted_price__c != null)) ){
                    system.debug('inside before insertcode');
                    //Fill the set with the filtered DP with PBEPs 
                    filteredDealProds.add(dealProd);
                    //Fill the set with Storefront account
                    Date dealStartDate =null;  
                    if(OpportunityIdMap.containsKey(dealProd.OpportunityId)){
                        setAccountIds.add(OpportunityIdMap.get(dealProd.OpportunityId).Storefront_Account__c);
                        dealStartDate = OpportunityIdMap.get(dealProd.OpportunityId).start_date__c;
                    }
                    
                    if(pbepIdMap.containsKey(dealProd.Pricebook_Entry_Period__c)){
                        //Add records in map Product to PBEP values to access Product Field to create key for Pricing Search
                        mapPbepRecords.put(dealProd.Pricebook_Entry_Period__c,pbepIdMap.get(dealProd.Pricebook_Entry_Period__c));
                        if(dealProd.Price_Tier__c != null){
                            mapPbepIdChangePromoPricing.put(dealProd.Pricebook_Entry_Period__c,true);
                        }else if(dealProd.Price_Tier__c == null && dealProd.Promoted_price__c != null){
                            mapPbepIdChangePromoPricing.put(dealProd.Pricebook_Entry_Period__c,false);
                        }
                       if(pbepIdMap.get(dealProd.Pricebook_Entry_Period__c).Client_Avail__r.Local_DVD_Release_Date__c !=null && dealStartDate != null){
              Date localDataDate = pbepIdMap.get(dealProd.Pricebook_Entry_Period__c).Client_Avail__r.Local_DVD_Release_Date__c;
              Integer monthsBetween = math.abs(localDataDate.monthsBetween(dealStartDate));
              if((dealStartDate.day() < localDataDate.day() && dealStartDate > localDataDate) || 
                 (localDataDate.day() < dealStartDate.day() && localDataDate > dealStartDate)  
              ){
                monthsBetween--;
              }     
              mapDealProductAge.put(dealProd.Product2Id,monthsBetween);// changes related to WBCTASK000190239
              System.debug('mapDealProductAge::::::::'+mapDealProductAge);
            }
                    }
                }
               
                //Defect#4373 : end (also added check in next line if if price tier is not entered by user to set default price tier from PBEP.) 
                if(dealProd.Price_Tier__c == null 
                    && dealProd.Promoted_price__c == null 
                    && pbepIdMap.containsKey(dealProd.Pricebook_Entry_Period__c))
                {
                    dealProd.Pricing__c = pbepIdMap.get(dealProd.Pricebook_Entry_Period__c).Pricing__c;
                    dealProd.Price_Tier__c = pbepIdMap.get(dealProd.Pricebook_Entry_Period__c).Price_Tier__c;
                    dealProd.Promoted_price__c = pbepIdMap.get(dealProd.Pricebook_Entry_Period__c).Account_Price__c; 
                }
            }
           
           //Defect#4373 : added code snipet to validate user entered price tier. 
            if(!filteredDealProds.isEmpty() && !setAccountIds.isEmpty() && !mapPbepRecords.isEmpty() && !OpportunityIdMap.isEmpty()){
                CRM_PricingUtility.validatePricingAtInsertion(setAccountIds, filteredDealProds,lstNewDealProducts,mapPbepRecords,OpportunityIdMap,mapPbepIdChangePromoPricing,mapDealProductAge, pbepIdMap);
            }
            //Defect#4373 : end
        }
        // DEAL PRODUCT UPDATE SCENARIO        
        else{
            Map<Id,Integer> mapDealProductAge = new Map<Id,Integer>();
            map<Id,Boolean> mapDealProIdPromoPricingChange =new map<id,Boolean>();
            //Get all New Products into Map for throwing validation error message.
            map<Id,OpportunityLineItem> mapNewDealProducts = new map<Id,OpportunityLineItem>(lstNewDealProducts);
            //Fetch all Deal Product required field for key creation only for Digital Deals
            map<Id,OpportunityLineItem> mapDealProducts = new map<Id,OpportunityLineItem>();
            map<Id,Opportunity> mapOfDeals = new map<Id,Opportunity>();
            if(!mapNewDealProducts.isEmpty()){
              mapDealProducts = new map<Id,OpportunityLineItem>([SELECT Id ,OpportunityId ,Opportunity.RecordTypeId ,Promoted_price__c,Opportunity.AccountId ,Opportunity.StageName,Opportunity.Storefront_Account__c,Opportunity.Start_Date__c,
                                                                      Price_Tier__c ,Pricing__c,product2.Country_Code__c ,product2.Product_Format__c ,Opportunity.Account.Digital_Country_Code__c,
                                                                      product2.Tittle_Content_Type__c ,product2.Product_Market__c ,Opportunity.Sales_Organisation__c,Pricebook_Entry_Period__r.Client_Avail__r.Local_DVD_Release_Date__c 
                                                                      FROM OpportunityLineItem
                                                                      WHERE Id IN: mapNewDealProducts.keySet()
                                                            AND (Opportunity.RecordTypeId = :CRM_RecordTypeUtil.RT_DEAL_DIGITAL 
                                                            OR Opportunity.RecordTypeId = :CRM_RecordTypeUtil.RT_DEAL_PHYSICAL)]);
            }
            
            for(OpportunityLineItem dealItem : mapDealProducts.values()){
                //Filter the Deal products where Pricing is set and needs to be validated
            if(dealItem.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL){
                //US#663 - added code snipet to allow user to change the promo price and price tier at the same instance on deal product only through code.
                if(((mapNewDealProducts.get(dealItem.Id).Price_Tier__c == null && 
                    mapNewDealProducts.get(dealItem.Id).Promoted_price__c == null) ||
                    (mapNewDealProducts.get(dealItem.Id).Price_Tier__c != null && 
                    mapNewDealProducts.get(dealItem.Id).Promoted_price__c != null)
                    )
                    && 
                    (mapOldDealProducts.get(dealItem.Id).Price_Tier__c != mapNewDealProducts.get(dealItem.Id).Price_Tier__c 
                    && mapOldDealProducts.get(dealItem.Id).Promoted_price__c != mapNewDealProducts.get(dealItem.Id).Promoted_price__c)
                  ){
                    system.debug('inside time stamp change block'+dealItem.id);
                    mapNewDealProducts.get(dealItem.Id).Modified_Promo_Price_And_PriceTier__c = system.now();
                }
                  if(mapNewDealProducts.containsKey(dealItem.Id) //executes for price tier
                          //added new code for Defect#4467 
                          && (
                                  (mapNewDealProducts.get(dealItem.Id).Price_Tier__c!=null  
                                && (mapOldDealProducts.get(dealItem.Id).Price_Tier__c != mapNewDealProducts.get(dealItem.Id).Price_Tier__c) 
                                  ) ||
                                  (mapNewDealProducts.get(dealItem.Id).Promoted_price__c == null 
                                      && (mapOldDealProducts.get(dealItem.Id).Promoted_price__c != mapNewDealProducts.get(dealItem.Id).Promoted_price__c)
                                  )
                             )
                         //end Defect#4467    
                           && dealItem.id == mapNewDealProducts.get(dealItem.Id).Id){ 
                      //Pricing will be related to Storefront 's account so sending those account for fetching Pricing Records  
                      if(dealItem.Opportunity.Storefront_Account__c!=null)
                      {   
                          setAccountIds.add(dealItem.Opportunity.Storefront_Account__c);
                          mapOfDeals.put(dealItem.OpportunityId,dealItem.Opportunity);
                      }
                      filteredDealProds.add(dealItem);
                      mapDealProIdPromoPricingChange.put(dealItem.Id,true);
                  }
                  //US#663 - added code snippet to allow user to change the promo price of price tier is present on deal product.
                  else if(mapNewDealProducts.containsKey(dealItem.Id) //executed for promoted price
                          //added new code for Defect#4467
                          && 
                          (
                            (mapOldDealProducts.get(dealItem.Id).Price_Tier__c != mapNewDealProducts.get(dealItem.Id).Price_Tier__c 
                                && mapNewDealProducts.get(dealItem.Id).Price_Tier__c == null
                            )
                            || 
                            (mapOldDealProducts.get(dealItem.Id).Promoted_price__c != mapNewDealProducts.get(dealItem.Id).Promoted_price__c 
                                && mapNewDealProducts.get(dealItem.Id).Promoted_price__c != null
                            )
                          ) 
                          //End Defect#4467
                          && dealItem.id == mapNewDealProducts.get(dealItem.Id).Id){
                              
                      if(dealItem.Opportunity.Storefront_Account__c!=null){   
                          setAccountIds.add(dealItem.Opportunity.Storefront_Account__c);
                          mapOfDeals.put(dealItem.OpportunityId,dealItem.Opportunity);
                      }
                      filteredDealProds.add(dealItem);
                      mapDealProIdPromoPricingChange.put(dealItem.Id,false);
            
                  }
                 
                  if(dealItem.Pricebook_Entry_Period__r.Client_Avail__r.Local_DVD_Release_Date__c !=null ){
            Date locaDataDate = dealItem.Pricebook_Entry_Period__r.Client_Avail__r.Local_DVD_Release_Date__c;
            Integer monthsBetween = math.abs(locaDataDate.monthsBetween(dealItem.Opportunity.Start_Date__c));
            Date dealStartDate = dealItem.Opportunity.Start_Date__c;
            if((dealStartDate.day() < locaDataDate.day() && dealStartDate > locaDataDate) || 
                 (locaDataDate.day() < dealStartDate.day() && locaDataDate > dealStartDate)  
            ){
              monthsBetween--;
            }
            mapDealProductAge.put(dealItem.Product2Id,monthsBetween);// changes related to WBCTASK000190239
          }
              }
              
          //US#394 (Germany) : Update Contribution is under Minimum (Sales)/Contribution is under Minimum (Finance) Check box 
          if(mapOldDealProducts.containsKey(dealItem.Id) && mapOldDealProducts.get(dealItem.Id) != null){
            setDPAsContributionIsUnderMinimumForFinanceAndSalse(
                mapNewDealProducts.get(dealItem.Id),
                mapOldDealProducts.get(dealItem.Id),
                dealItem.Opportunity.RecordTypeId,
                dealItem.Opportunity.Sales_Organisation__c,
                dealItem.Opportunity.Account.Digital_Country_Code__c,
                dealItem.Opportunity.StageName
            );
          } 
        }
        system.debug('mapofdeal::::::::::'+mapOfDeals);
          //Call the PricingUtility method to validate and throw the error message if any.
            CRM_PricingUtility.validatePricing(mapOfDeals,setAccountIds, filteredDealProds,mapNewDealProducts,mapDealProIdPromoPricingChange,mapDealProductAge);
        } 
    }
    
     /**  US#394 Update Contribution is under Minimum Finance/Salse on Deal Product
        * @Description - Method to update Contribution is under Minimum Finance/Salse on Deal Product
        * @name - setDPAsContributionIsUnderMinimumForFinanceAndSalse
        * @param - newDp - New Deal Prodcut ,oldDp - Old Deal Prodcut,dealRecordTypeId - Deal RecordTypeId, dealSalseOrg - Deal Salse Org, accDCC - Account Digital Country Code, dealStageName - Deal Stage
        * @returns - None
    **/
    public static void setDPAsContributionIsUnderMinimumForFinanceAndSalse(OpportunityLineItem newDp, OpportunityLineItem oldDp, Id dealRecordTypeId, String dealSalseOrg, String accDCC, String dealStageName){
      if(((dealRecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && 
           (dealSalseOrg == CRM_AppConstants.TERRITORY_GERMANY_CODE || dealSalseOrg == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE || 
           dealSalseOrg == CRM_AppConstants.TERRITORY_ITALY_CODE)
          )
            ||
            (dealRecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(accDCC))) && 
             dealStageName != CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED){
            
            if(newDP.Contribution__c < newDP.Min_Contribution_Sales__c){
                newDP.Contribution_is_under_Minimum_Sales__c = true;
            }else{
                newDP.Contribution_is_under_Minimum_Sales__c = false;
            }
            if(newDP.Contribution__c < newDP.Min_Contribution_Finance__c){
                newDP.Contribution_is_under_Minimum_Finance__c = true;
            }else{
                newDP.Contribution_is_under_Minimum_Finance__c = false;
            }
        }   
    }
     
     /**  US#594   Automated Estimation of Production Costs
        * @Description - Wrapper Class to sort the Custom Setting values for Estimated Productio Cost.
        * @name - DealProductRule
        * @param - key, CRM_Production_Cost_Estimated__c
        * @returns - Sorted list
     **/
    public class DealProductRule implements Comparable {
        public String ruleKey {get;set;}
        public CRM_Production_Cost_Estimated__c rule {get;set;}
        
        public DealProductRule(String key, CRM_Production_Cost_Estimated__c rule){
            this.rule = rule;
            this.ruleKey = key;
        }
        
        public Integer compareTo(object compareTo) {
            if(rule.Calculation_Order__c > ((DealProductRule)compareTo).rule.Calculation_Order__c){
                return 1;
            }
            
            return -1;
        }
    }
    
     /** 
    *  US : 929 : US Games 
    *  @description: - This method is used to throw error message if deal products are linked with Credit Note Item while Deleting.
    *  @name: restrictToDeleteDealProductsLinkedWithCNI
    *  @return: void
    */ 
    public static void restrictToDeleteDealProductsLinkedWithCNI(Map<Id,OpportunityLineItem> mapOldDealProducts){
        
        for(OpportunityLineItem dp : mapOldDealProducts.values()){
            if(dp.Deal_Record_Type__c == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_TRADE_SPEND_DEAL){
                if(dp.Status__c == CRM_AppConstants.DEAL_PRODUCT_STATUS_CANCELLED){
                    dp.addError(System.Label.CRM_RestrictToDeleteCancelledDealProducts);
                }else if(dp.Status__c == CRM_AppConstants.DEAL_PRODUCT_STATUS_PAID && dp.Status__c == CRM_AppConstants.DEAL_PRODUCT_STATUS_PAYMENT_IN_PROGRESS && dp.Accruing_Tactic__c){
                    dp.addError(System.Label.CRM_DealProductCannotDelete);
                }else if(dp.Status__c == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED){
                    dp.addError(System.Label.CRM_RestrictToDeleteDealProductInCommittedStage);
                }else if(!((dp.Status__c == CRM_AppConstants.DEAL_PRODUCT_STATUS_PLANNED && dp.Credit_Note_Item__c == null) || (!dp.Accruing_Tactic__c))){
                    dp.addError(System.Label.CRM_RestrictToDeleteDealProductsLinkedWithCNI);
                }
            }
        }
    } 
}