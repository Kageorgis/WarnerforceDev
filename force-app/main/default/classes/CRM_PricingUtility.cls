/**
   @Author: Cognizant Technology Solutions
   @name: CRM_PricingUtility
   @Description:  US#985 All Territories - Controller class to validate Price_Tier__c on Deal Product with Rate Card records
   @Version - 1.0
   @reference: None
  */

public with sharing class CRM_PricingUtility {
    static Map<String, Rate_Card__c[]> mapAccountPrices;
    static Map<String, Rate_Card__c[]> mapAccountProductPrices;
    static Map<String, Rate_Card__c[]> mapAccountProductPricesExactMatch;
    public static Boolean alreadyExecuted = false;
     
    /**
      *  Method to initialize Prices from the Rate Card Record using AccountId which is called from Deal Product Before Insert & Update Trigger 
      *  @name intializePrices
      *  @param List<Id> setAccountIds
      *  @return void
      *  @throws None
      */
    public static void intializePrices(Set<Id> setAccountIds,Date dealStartDate, Boolean isInsertUpdate) {
        mapAccountPrices = new Map<String, Rate_Card__c[]>();
        mapAccountProductPrices = new Map<String, Rate_Card__c[]>();
        mapAccountProductPricesExactMatch = new Map<String, Rate_Card__c[]>();
        //Fetch all Rate Card Records for the List of Accounts
        List<Rate_Card__c> lstRateCards = new List<Rate_Card__c>();
        if(!setAccountIds.isEmpty()){
            if(!isInsertUpdate && dealStartDate != null){
                lstRateCards = [SELECT Id, Name, Account__c, WSP1__c,WSP2__c,WSP3__c, Start_Date__c,End_Date__c, Price_Tier__c, Country__r.Country_Code2__c, RC_Lifecycle__c,
                                                Content_Type__c, Channel__c, Format__c,Step1_Length_Months__c,Step2_Length_Months__c,Step_Pricing__c
                                                FROM Rate_Card__c 
                                                WHERE Account__c =: setAccountIds 
                                                AND (Start_Date__c <=: dealStartDate AND End_Date__c >=: dealStartDate)
                                                ORDER BY Price_Tier__c desc Nulls Last ];   
            }else{
                lstRateCards = [SELECT Id, Name, Account__c, WSP1__c, WSP2__c, WSP3__c, Start_Date__c,End_Date__c,Price_Tier__c, Country__r.Country_Code2__c, RC_Lifecycle__c,
                                                Content_Type__c, Channel__c, Format__c,Step1_Length_Months__c,Step2_Length_Months__c,Step_Pricing__c,Rate_Card_Type__c
                                                FROM Rate_Card__c 
                                                WHERE Account__c =: setAccountIds ORDER BY Price_Tier__c desc Nulls Last ];
            }
        }
        for(Rate_Card__c rateCard : lstRateCards) {
            
            String accountPricingKey = String.ValueOf(rateCard.Account__c).substring(0, 15);
            // fill the mapAccountPrices map
            if(!mapAccountPrices.containsKey(accountPricingKey)) {
                mapAccountPrices.put(accountPricingKey, new Rate_Card__c[]{});
            }
            mapAccountPrices.get(accountPricingKey).add(rateCard);
            //List of Price Tiers shown in Promoted Price Tier dropdown should be taken by finding all Rate Card records with Storefront, Content Type, Channel, and Format matching the product
            //Generate key    (Account+Country+Format)         
            String[] accProdKeyTokens = new String[]{ String.ValueOf(rateCard.Account__c).substring(0, 15), rateCard.Country__r.Country_Code2__c, rateCard.Channel__c}; 
            String accountProductPricingKey = String.join(accProdKeyTokens, '_');
            
            //If Trigger is called then only fill the map   
            //List of Price Tiers shown in Promoted Price Tier dropdown should be taken by finding all Rate Card records with Storefront, Content Type, Channel, and Format matching the product
            //Generate key (Account+Country+Format +Content type+ Channel)    
            if(rateCard.Content_Type__c != 'All' && rateCard.Format__c != 'All') {
                // fill the mapAccountProductPrices map 
                String[] accProdKeyTokensAll = new String[]{ String.ValueOf(rateCard.Account__c).substring(0, 15), rateCard.Country__r.Country_Code2__c, rateCard.Content_Type__c, rateCard.Channel__c, rateCard.Format__c}; 
                String accountProductPricingKeyAll = String.join(accProdKeyTokensAll, '_');
                
                if(!mapAccountProductPricesExactMatch.containsKey(accountProductPricingKeyAll)) {
                   mapAccountProductPricesExactMatch.put(accountProductPricingKeyAll, new Rate_Card__c[]{});
                }    
                   mapAccountProductPricesExactMatch.get(accountProductPricingKeyAll).add(rateCard);    
            }
            // fill the mapAccountProductPrices map
            // Defect WBCTASK000243966: Rate Card Functionality: Assignment of incorrect Promoted Price Tier
            // Updated "if" to "else if" so as to check key only for Ratecards with either Content Type or Format as 'All', eliminating the partial match condition
            else if(!mapAccountProductPrices.containsKey(accountProductPricingKey)) {
               mapAccountProductPrices.put(accountProductPricingKey, new Rate_Card__c[]{});
            }
            // Defect WBCTASK000243966: Rate Card Functionality: Assignment of incorrect Promoted Price Tier
            // Updated the condition to restrict adding only the Ratecards with either Content Type or Format as 'All', eliminating the partial match condition
            if(mapAccountProductPrices.containsKey(accountProductPricingKey) && (rateCard.Content_Type__c == 'All' || rateCard.Format__c == 'All')){
              mapAccountProductPrices.get(accountProductPricingKey).add(rateCard);
             }
        }
    }
    
    /**
      *  Method to fetch the Rate Card Record from AccountId and ProductId which is called from Edit All Deal Product 
      *  @name fetchPricing
      *  @param Id accountId, Product2 product
      *  @return Rate_Card__c[]
      *  @throws None
      */
    public static Rate_Card__c[] fetchPricing(Id accountId, Date dealStartDate, Product2 product) {
        
        String accountPricingKey = String.ValueOf(accountId).substring(0, 15);
        Set<String> uniqueProductKeySet =new Set<String>();
        List<Rate_Card__c> lstPrices = new List<Rate_Card__c>();
        
       //DEF#4457 When Blank is saved in Price tier other price tier picklist will not be set blank
       //Initializes maps for AccId to Rate Card Records and map of Rate Card key to Rate Card Record

        //Generate Key for the Deal Product to be updated from CRM_EditAllOppProducts Page/Ctrl
        String[] accProdKeyTokens = new String[]{String.ValueOf(accountId).substring(0, 15), product.Country_Code__c, product.Product_Market__c};
        String accountProductPricingKey = String.join(accProdKeyTokens, '_');
        
        // Defect WBCTASK000243966: Rate Card Functionality: Assignment of incorrect Promoted Price Tier
        // Creating Key for Exact Match and adding those Ratecards also in the lstPrices
        String[] accProdKeyTokensforExactMatch = new String[]{String.ValueOf(accountId).substring(0, 15), product.Country_Code__c, product.Tittle_Content_Type__c, product.Product_Market__c,product.Product_Format__c};
        String accountProductPricingKeyforExactMatch = String.join(accProdKeyTokensforExactMatch, '_');
        if(mapAccountProductPricesExactMatch.containsKey(accountProductPricingKeyforExactMatch)){
            lstPrices = mapAccountProductPricesExactMatch.get(accountProductPricingKeyforExactMatch);
        }
        if(mapAccountProductPrices.containsKey(accountProductPricingKey)){
            for(Rate_Card__c rateCard :mapAccountProductPrices.get(accountProductPricingKey)){
                 String[] accProdKeyTok =new String[]{};
                 String accountProductPriKey ='';
                 accountProductPriKey = getAccountRateCardKey(rateCard, product.Product_Format__c, product.Tittle_Content_Type__c);
                 if(accountProductPriKey == ''){
                    String[] productKeyString = new String[]{String.ValueOf(accountId).substring(0, 15), product.Country_Code__c, product.Tittle_Content_Type__c, 
                                                                product.Product_Market__c, product.Product_Format__c};
                    String productKey = String.join(productKeyString, '_');
                    String[] rateCardKeyString = new String[]{ String.ValueOf(rateCard.Account__c).substring(0, 15), rateCard.Country__r.Country_Code2__c, 
                                                            rateCard.Content_Type__c,rateCard.Channel__c, rateCard.Format__c};  
                    String rateCardKey = String.join(rateCardKeyString, '_'); 
                    if(productKey == rateCardKey){
                        accProdKeyTok = new String[]{ String.ValueOf(rateCard.Account__c).substring(0, 15), rateCard.Country__r.Country_Code2__c, 
                                                            rateCard.Content_Type__c,rateCard.Channel__c, rateCard.Format__c,rateCard.Price_Tier__c,
                                                            String.ValueOf(rateCard.WSP1__c),String.ValueOf(rateCard.WSP2__c),String.ValueOf(rateCard.WSP3__c)};  
                        accountProductPriKey = String.join(accProdKeyTok, '_'); 
                        if(accountProductPriKey !='' && !uniqueProductKeySet.contains(accountProductPriKey)){
                            uniqueProductKeySet.add(accountProductPriKey);
                            lstPrices.add(rateCard);
                        }
                    }
                }else{
                    if(accountProductPriKey !='' && !uniqueProductKeySet.contains(accountProductPriKey)){
                        uniqueProductKeySet.add(accountProductPriKey);
                        lstPrices.add(rateCard);
                    }
                }
            }
        }
        
        //Save all valid  Rate Card records into a list
        Rate_Card__c[] lstRateCards = (product.id == null ? mapAccountPrices.get(accountPricingKey) : lstPrices);
        
        // returns list of valid  Rate Card records for the Deal Product.
        return (lstRateCards != null ? lstRateCards : new Rate_Card__c[]{});
    }
    
    /**
      *  Method to get generate Rate Card Key for combination of ALL in Content Type/Channel Record 
      *  @name getAccountRateCardKey
      *  @param Rate_Card__c rateCard
      *  @return String 
      *  @throws None
      * US#985 :  added extra variable change.
      */
    private static String getAccountRateCardKey(Rate_Card__c rateCard, String prodFormat, String prodContentType){
        String[] accProdKeyTok =new String[]{};
        String accountProductPriKey ='';
        if(rateCard.format__c == 'All' && rateCard.Content_Type__c != 'All' && rateCard.Content_Type__c == prodContentType){
            accProdKeyTok = new String[]{ String.ValueOf(rateCard.Account__c).substring(0, 15), rateCard.Country__r.Country_Code2__c, 
                                            rateCard.Content_Type__c, rateCard.Channel__c,rateCard.Price_Tier__c,
                                            String.ValueOf(rateCard.WSP1__c),String.ValueOf(rateCard.WSP2__c),String.ValueOf(rateCard.WSP3__c)};  
            accountProductPriKey = String.join(accProdKeyTok, '_');     
        }else if(rateCard.Format__c != 'All' && rateCard.Format__c == prodFormat && rateCard.Content_Type__c == 'All'){
            accProdKeyTok = new String[]{ String.ValueOf(rateCard.Account__c).substring(0, 15), rateCard.Country__r.Country_Code2__c, 
                                          rateCard.Channel__c, rateCard.Format__c,rateCard.Price_Tier__c,
                                          String.ValueOf(rateCard.WSP1__c),String.ValueOf(rateCard.WSP2__c),
                                          String.ValueOf(rateCard.WSP3__c)};  
            accountProductPriKey = String.join(accProdKeyTok, '_'); 
        }else if(rateCard.Format__c == 'All' && rateCard.Content_Type__c == 'All'){
            accProdKeyTok = new String[]{ String.ValueOf(rateCard.Account__c).substring(0, 15), rateCard.Country__r.Country_Code2__c, 
                                             rateCard.Channel__c,rateCard.Price_Tier__c,String.ValueOf(rateCard.WSP1__c),
                                             String.ValueOf(rateCard.WSP2__c),String.ValueOf(rateCard.WSP3__c)};  
            accountProductPriKey = String.join(accProdKeyTok, '_'); 
        }
        return accountProductPriKey;
    }
    
    /**
      *  Method to validate the Rate Card Record from DealProduct and throw error for incorrect data in Before Insert & Update Trigger 
      *  @name validatePricing
      *  @param Set<Id> setAccountIds, List<OpportunityLineItem> filteredDealProds,map<id,OpportunityLineItem> mapNewDealProducts
      *  @return Rate_Card__c[]
      *  @throws None
      * US#663 :  added extra variable change.
      */
    public static void validatePricing(map<id,Opportunity> mapOfDeals, Set<Id> setAccountIds, List<OpportunityLineItem> filteredDealProds,map<id,OpportunityLineItem> mapNewDealProducts,map<Id,Boolean> mapDealProIdPromoPricingChange,Map<Id,Integer> mapDealProductAge) { 
        if(mapAccountPrices == null|| mapAccountPrices.isEmpty()) {
            //Initializes maps for AccId to  Rate Card Records and map of  Rate Card key to  Rate Card Record
            intializePrices(setAccountIds, null, true);
            system.debug('alreadyExecuted::::::::::'+alreadyExecuted);
            
        }
    // Defect WBCTASK000278292: Promoted Price/Tier Error on CRM Digital Deal
        if(!alreadyExecuted){
        for(OpportunityLineItem dealProd :filteredDealProds){
            
            List<Rate_Card__c> lstRateCards = new List<Rate_Card__c>();
            Boolean flag =false;
            //Generate Key for the newly inserted/updated Deal Product =======> (Account + Country + Content Type + Channel + Format)
            String[] accProdKeyTokens = new String[]{String.ValueOf(dealProd.Opportunity.Storefront_Account__c).substring(0, 15), dealProd.product2.Country_Code__c, dealProd.product2.Tittle_Content_Type__c, dealProd.product2.Product_Market__c, dealProd.product2.Product_Format__c};
            String accountProductPricingKey = String.join(accProdKeyTokens, '_');
            //Check if the generated key matches with the fetched  Rate Card records
            if(mapAccountProductPricesExactMatch.containsKey(accountProductPricingKey)){ 
                //Get exact match for the deal product
                lstRateCards = mapAccountProductPricesExactMatch.get(accountProductPricingKey);
            }   
            //Call the method for exact match 
            flag = setRateCardDetailsOnDP(false, dealProd, lstRateCards,mapNewDealProducts,mapDealProIdPromoPricingChange,mapDealProductAge,flag);
            //If no exact match found then check for partial match
            //Generate Key for the newly inserted/updated Deal Product without Content Type & Format ========> (Account + Country + Channel)
            String[] accAllProdKeyTokens = new String[]{String.ValueOf(dealProd.Opportunity.Storefront_Account__c).substring(0, 15), dealProd.product2.Country_Code__c, dealProd.product2.Product_Market__c};
            String accountAllProductPricingKey = String.join(accAllProdKeyTokens, '_');
            if(!flag){
                if(mapAccountProductPrices.containsKey(accountAllProductPricingKey)){
                    lstRateCards = mapAccountProductPrices.get(accountAllProductPricingKey);
                }
               flag = setRateCardDetailsOnDP(true, dealProd, lstRateCards,mapNewDealProducts,mapDealProIdPromoPricingChange,mapDealProductAge,flag);
            }
            alreadyExecuted = true;

            if(flag == false){
                if(mapDealProIdPromoPricingChange.containsKey(dealProd.Id) && mapDealProIdPromoPricingChange.get(dealProd.Id)){
               mapNewDealProducts.get(dealProd.id).addError(System.label.CRM_Check_Valid_Price_Tier);
          }else{
              mapNewDealProducts.get(dealProd.id).Rate_Card__c = null;    
            mapNewDealProducts.get(dealProd.id).Price_Tier__c =null;
          }
            }
        }
    }
    }
    
    /**
      *  Method to Set the Rate Card Details in DealProduct to be updated and set the flag to throw error for incorrect data in Update Trigger 
      *  @name setRateCardDetailsOnDP
      *  @param Boolean allRateCards, OpportunityLineItem dealProd, List<Rate_Card__c> lstRateCards ,map<id,OpportunityLineItem> mapNewDealProducts,map<Id,Boolean> mapDealProIdPromoPricingChange,Map<Id,Integer> mapDealProductAge
      *  @return Boolean 
      *  @throws None
      * US#985 :  added extra variable change.
      */
    private static Boolean setRateCardDetailsOnDP(Boolean allRateCards, OpportunityLineItem dealProd, List<Rate_Card__c> lstRateCards ,map<id,OpportunityLineItem> mapNewDealProducts,map<Id,Boolean> mapDealProIdPromoPricingChange,Map<Id,Integer> mapDealProductAge,Boolean flag){
       Set<String> uniqueProductKeySet =new Set<String>();
       List<Rate_Card__c> lstContentTypeRateCards = new List<Rate_Card__c>();
       List<Rate_Card__c> lstFormatRateCards = new List<Rate_Card__c>();
       List<Rate_Card__c> lstAllRateCards = new List<Rate_Card__c>();   
        for(Rate_Card__c rateCard : lstRateCards) {
            if(rateCard.Start_Date__c <= dealProd.Opportunity.Start_Date__c && rateCard.End_Date__c >= dealProd.Opportunity.Start_Date__c){
                if(allRateCards){
                    String accountProductPriKey ='';
                    accountProductPriKey = getAccountRateCardKey(rateCard, dealProd.product2.Product_Format__c, dealProd.product2.Tittle_Content_Type__c);
                   // Defect WBCTASK000278292: Promoted Price/Tier Error on CRM Digital Deal
           // Defect WBCTASK000243966: Rate Card Functionality: Assignment of incorrect Promoted Price Tier
                   // Checking Condition if accountProductPriKey is not null 
                   if(accountProductPriKey !='' &&!uniqueProductKeySet.contains(accountProductPriKey)){
                        uniqueProductKeySet.add(accountProductPriKey);
        //WBCTASK000296250: Promoted Price Error on Digital Deal Start
        if(!accountProductPriKey.contains(rateCard.Content_Type__c) && !accountProductPriKey.contains(rateCard.Format__c)){
              if(mapNewDealProducts.get(dealProd.id).Promoted_Price__c==null && rateCard.Price_Tier__c!= null
                && rateCard.Price_Tier__c.equalsIgnoreCase(mapNewDealProducts.get(dealProd.id).Price_Tier__c)
                && !rateCard.Price_Tier__c.equalsIgnoreCase(dealProd.Price_Tier__c)// promoted price is null and price tier is not null and rate card price tier = new map dp's price tier and rate card price tier not equals old dp's price tiers
                ){
                  lstAllRateCards.add(rateCard);
                }
              else if (rateCard.Price_Tier__c!= null &&
                mapNewDealProducts.get(dealProd.id).Promoted_Price__c!=null
                && ((accountProductPriKey.contains(String.ValueOf(mapNewDealProducts.get(dealProd.id).Promoted_Price__c))
                && !rateCard.Price_Tier__c.equalsIgnoreCase(mapNewDealProducts.get(dealProd.id).Price_Tier__c))// rate card and promoted price not null and rate card key contains promoted price and not contain old price tier
                ||
                (rateCard.Price_Tier__c!=null && rateCard.Price_Tier__c.equalsIgnoreCase(mapNewDealProducts.get(dealProd.id).Price_Tier__c)
                && !accountProductPriKey.contains(String.ValueOf(mapNewDealProducts.get(dealProd.id).Promoted_Price__c))//// rate card and promoted price not null and rate card price tier is equal to new map dp's rate card when rate card key dont contain prmoted price.
                ))
                && ((dealProd.Promoted_Price__c== null || !accountProductPriKey.contains(String.ValueOf(dealProd.Promoted_Price__c)) || rateCard.Rate_Card_Type__c.equalsIgnoreCase(System.label.CRM_Rate_Card_Type_Step_DVD)) && !rateCard.Price_Tier__c.equalsIgnoreCase(dealProd.Price_Tier__c)// and accountProductPriKey dont have old dp promoted price and rate catd price tier is not changed
                ))
                {
                  lstAllRateCards.add(rateCard);
                }
                else if(rateCard.Price_Tier__c== null && mapNewDealProducts.get(dealProd.id).Promoted_Price__c!=null
                && (accountProductPriKey.contains(String.ValueOf(mapNewDealProducts.get(dealProd.id).Promoted_Price__c)))
                // new promoted price != null and accountproductpricing key contain promoted price 
                && (!accountProductPriKey.contains(String.ValueOf(dealProd.Promoted_Price__c)) || rateCard.Rate_Card_Type__c.equalsIgnoreCase(System.label.CRM_Rate_Card_Type_Step_DVD)) // and accountProductPriKey dont have old dp promoted price 
                ){
                  lstAllRateCards.add(rateCard);
                }
          }
          else if(accountProductPriKey.contains(rateCard.Content_Type__c)){
              if(mapNewDealProducts.get(dealProd.id).Promoted_Price__c==null && rateCard.Price_Tier__c!= null
                && rateCard.Price_Tier__c.equalsIgnoreCase(mapNewDealProducts.get(dealProd.id).Price_Tier__c)
                && !rateCard.Price_Tier__c.equalsIgnoreCase(dealProd.Price_Tier__c)
                ){
                  lstContentTypeRateCards.add(rateCard);
                }
              else if (rateCard.Price_Tier__c!= null &&
                mapNewDealProducts.get(dealProd.id).Promoted_Price__c!=null
                && ((accountProductPriKey.contains(String.ValueOf(mapNewDealProducts.get(dealProd.id).Promoted_Price__c))
                && !rateCard.Price_Tier__c.equalsIgnoreCase(mapNewDealProducts.get(dealProd.id).Price_Tier__c))
                ||
                (rateCard.Price_Tier__c!=null && rateCard.Price_Tier__c.equalsIgnoreCase(mapNewDealProducts.get(dealProd.id).Price_Tier__c)
                && !accountProductPriKey.contains(String.ValueOf(mapNewDealProducts.get(dealProd.id).Promoted_Price__c))
                ))
                && ((dealProd.Promoted_Price__c== null || !accountProductPriKey.contains(String.ValueOf(dealProd.Promoted_Price__c))|| rateCard.Rate_Card_Type__c.equalsIgnoreCase(System.label.CRM_Rate_Card_Type_Step_DVD)) && !rateCard.Price_Tier__c.equalsIgnoreCase(dealProd.Price_Tier__c)
                )
                ){
                  lstContentTypeRateCards.add(rateCard);
                }
                else if(rateCard.Price_Tier__c== null && mapNewDealProducts.get(dealProd.id).Promoted_Price__c!=null
                && (accountProductPriKey.contains(String.ValueOf(mapNewDealProducts.get(dealProd.id).Promoted_Price__c)))
                // new promoted price != null and accountproductpricing key contain promoted price 
                && (!accountProductPriKey.contains(String.ValueOf(dealProd.Promoted_Price__c))|| rateCard.Rate_Card_Type__c.equalsIgnoreCase(System.label.CRM_Rate_Card_Type_Step_DVD) // and accountProductPriKey dont have old dp promoted price 
                )){
                  lstContentTypeRateCards.add(rateCard);
                }
          } 
          else if(accountProductPriKey.contains(rateCard.Format__c)){
              if(mapNewDealProducts.get(dealProd.id).Promoted_Price__c==null && rateCard.Price_Tier__c!= null
                && rateCard.Price_Tier__c.equalsIgnoreCase(mapNewDealProducts.get(dealProd.id).Price_Tier__c)
                && !rateCard.Price_Tier__c.equalsIgnoreCase(dealProd.Price_Tier__c)
                ){
                  lstFormatRateCards.add(rateCard);
                }
              else if (rateCard.Price_Tier__c!= null &&
              mapNewDealProducts.get(dealProd.id).Promoted_Price__c!=null
                && ((accountProductPriKey.contains(String.ValueOf(mapNewDealProducts.get(dealProd.id).Promoted_Price__c))
                && !rateCard.Price_Tier__c.equalsIgnoreCase(mapNewDealProducts.get(dealProd.id).Price_Tier__c))
                ||
                (rateCard.Price_Tier__c!=null && rateCard.Price_Tier__c.equalsIgnoreCase(mapNewDealProducts.get(dealProd.id).Price_Tier__c)
                && !accountProductPriKey.contains(String.ValueOf(mapNewDealProducts.get(dealProd.id).Promoted_Price__c))
                ))
                && ((dealProd.Promoted_Price__c== null || !accountProductPriKey.contains(String.ValueOf(dealProd.Promoted_Price__c))|| rateCard.Rate_Card_Type__c.equalsIgnoreCase(System.label.CRM_Rate_Card_Type_Step_DVD)) && !rateCard.Price_Tier__c.equalsIgnoreCase(dealProd.Price_Tier__c)
                )
                ){
                  lstFormatRateCards.add(rateCard);
                }
                else if(rateCard.Price_Tier__c== null && mapNewDealProducts.get(dealProd.id).Promoted_Price__c!=null
                && (accountProductPriKey.contains(String.ValueOf(mapNewDealProducts.get(dealProd.id).Promoted_Price__c)))
                // new promoted price != null and accountproductpricing key contain promoted price 
                && (!accountProductPriKey.contains(String.ValueOf(dealProd.Promoted_Price__c))|| rateCard.Rate_Card_Type__c.equalsIgnoreCase(System.label.CRM_Rate_Card_Type_Step_DVD)) // and accountProductPriKey dont have old dp promoted price 
                ){
                  lstFormatRateCards.add(rateCard);
                }
          }           
            ////WBCTASK000296250: Promoted Price Error on Digital Deal End            
                    }   
                }else{
                    flag = prepareRateCardDetails(dealProd,rateCard,mapNewDealProducts,mapDealProIdPromoPricingChange,mapDealProductAge,flag);
                  if(flag){
                        break;
                    }
                }
            }
        }
        // Defect WBCTASK000243966: Rate Card Functionality: Assignment of incorrect Promoted Price Tier
        //Run prepareRateCardDetails() according to Content Type and Format values and give priority to Content Type
        if(!lstContentTypeRateCards.isEmpty()){
          flag = prepareRateCardDetails(dealProd,lstContentTypeRateCards[0],mapNewDealProducts,mapDealProIdPromoPricingChange,mapDealProductAge,flag);

        }
        else if(!lstFormatRateCards.isEmpty() && lstContentTypeRateCards.isEmpty()){
          flag = prepareRateCardDetails(dealProd,lstFormatRateCards[0],mapNewDealProducts,mapDealProIdPromoPricingChange,mapDealProductAge,flag);        

         }
        else if(!lstAllRateCards.isEmpty() && lstFormatRateCards.isEmpty() && lstContentTypeRateCards.isEmpty()){
          flag = prepareRateCardDetails(dealProd,lstAllRateCards[0],mapNewDealProducts,mapDealProIdPromoPricingChange,mapDealProductAge,flag);     

        }                  
        //changes for promoted price ER-002742
        /*if(flag == false && (mapDealProIdPromoPricingChange.containsKey(dealProd.Id) && !mapDealProIdPromoPricingChange.get(dealProd.Id)) ){
          mapNewDealProducts.get(dealProd.id).Rate_Card__c = null;    
            mapNewDealProducts.get(dealProd.id).Price_Tier__c =null;
            flag =true; 
        }
        //changes for promoted price ER-002742
        */
        return flag;
    }
    
        /**
      *  Method to set the Rate Card Details on the Rate Card Record in Update trigger of DealProduct and set the flag to throw error for incorrect data in Before Insert 
      *  @name prepareRateCardDetails
      *  @param OpportunityLineItem dealProd,Rate_Card__c rateCard ,map<id,OpportunityLineItem> mapNewDealProducts
      *         ,map<Id,Boolean> mapDealProIdPromoPricingChange,Map<Id,Integer> mapDealProductAge,Boolean flag
      *  @return boolean
      *  @throws None
      *  US#985
      */
    private static boolean prepareRateCardDetails(OpportunityLineItem dealProd,Rate_Card__c rateCard ,map<id,OpportunityLineItem> mapNewDealProducts,map<Id,Boolean> mapDealProIdPromoPricingChange,Map<Id,Integer> mapDealProductAge,Boolean flag){
        //Set Promo Price when Price Tier is given
            if(mapNewDealProducts!=null && mapNewDealProducts.get(dealProd.id) != null && rateCard != null && rateCard.Price_Tier__c != null
            && rateCard.Price_Tier__c.equalsIgnoreCase(mapNewDealProducts.get(dealProd.id).Price_Tier__c)
            && (mapDealProIdPromoPricingChange.containsKey(dealProd.Id) && mapDealProIdPromoPricingChange.get(dealProd.Id))) {
                mapNewDealProducts.get(dealProd.id).Rate_Card__c = rateCard.id;   
                mapNewDealProducts.get(dealProd.id).Promoted_price__c = setPromotedPriceOnDealProduct(mapNewDealProducts.get(dealProd.id) ,rateCard, mapDealProductAge); 
                flag =true;
            }
            
            //US#663 :  code to fetch price tier based on changed promo price
            if(mapNewDealProducts!=null && mapNewDealProducts.get(dealProd.id) != null && rateCard != null 
            && (mapDealProIdPromoPricingChange.containsKey(dealProd.Id) && !mapDealProIdPromoPricingChange.get(dealProd.Id))
            && ((rateCard.WSP1__c != null && rateCard.WSP1__c == mapNewDealProducts.get(dealProd.id).Promoted_price__c) ||
                    (rateCard.WSP2__c != null && rateCard.WSP2__c == mapNewDealProducts.get(dealProd.id).Promoted_price__c) ||
                    (rateCard.WSP3__c != null && rateCard.WSP3__c == mapNewDealProducts.get(dealProd.id).Promoted_price__c ))){
                    Decimal promoPrice = setPromotedPriceOnInsertDealProduct(mapNewDealProducts.get(dealProd.id),rateCard ,mapDealProductAge); 
                    if(promoPrice != null){
                        mapNewDealProducts.get(dealProd.id).Promoted_price__c = promoPrice; //setPromotedPriceOnInsertDealProduct(mapNewDealProducts.get(dealProd.id),rateCard ,mapDealProductAge);
                        mapNewDealProducts.get(dealProd.id).Rate_Card__c = rateCard.id;    
                        mapNewDealProducts.get(dealProd.id).Price_Tier__c =rateCard.Price_Tier__c;
                        flag = true;
                }
                
            }/*else if(mapNewDealProducts!=null && mapNewDealProducts.get(dealProd.id) != null && rateCard != null 
            && (mapDealProIdPromoPricingChange.containsKey(dealProd.Id) && !mapDealProIdPromoPricingChange.get(dealProd.Id))
            && (rateCard.WSP1__c != null && rateCard.WSP1__c != mapNewDealProducts.get(dealProd.id).Promoted_price__c &&
                    rateCard.WSP2__c != null && rateCard.WSP2__c != mapNewDealProducts.get(dealProd.id).Promoted_price__c &&
                    rateCard.WSP3__c != null && rateCard.WSP3__c != mapNewDealProducts.get(dealProd.id).Promoted_price__c )){
                 if(flag == false){
                        mapNewDealProducts.get(dealProd.id).Rate_Card__c = null;    
                        mapNewDealProducts.get(dealProd.id).Price_Tier__c =null;
                        flag =true; 
                    }
            }*/
        return flag;
    }
    /**
      *  Method to validate the Rate Card Record from DealProduct and throw error for incorrect data in Before Insert & Update Trigger 
      *  @name validatePricing
      *  @param Set<Id> setAccountIds, List<OpportunityLineItem> filteredDealProds,
      *  @return Rate_Card__c[]
      *  @throws None
      *  @ defect#4373 :  added new method to validate price tier at the time of insertion of record.
      */
    public static void validatePricingAtInsertion(Set<Id> setAccountIds, List<OpportunityLineItem> filteredDealProds,
        List<OpportunityLineItem> lstNewDealProducts,map<Id,Pricebook_Entry_Period__c> mapPbepRecords , map<Id,Opportunity> OpportunityIdMap ,
        map<Id,Boolean> mapPbepIdChangePromoPricing,Map<Id,Integer> mapDealProductAge, map<Id,Pricebook_Entry_Period__c> pbepIdMap){
        Map<OpportunityLineItem,Rate_Card__c> mapPricingToUpdate =new Map<OpportunityLineItem,Rate_Card__c>();
        Map<OpportunityLineItem,Rate_Card__c> mapPricingToUpdatePromoPrice =new Map<OpportunityLineItem,Rate_Card__c>();
        Map<OpportunityLineItem,Boolean> mapLineItemErrorFlag =new Map<OpportunityLineItem,Boolean>();
        
        if(mapAccountPrices == null|| mapAccountPrices.isEmpty()) {
            //Initializes maps for AccId to Rate Card Records and map of Rate Card key to Rate Card Record
            intializePrices(setAccountIds, null, true);
        }
       
        for(OpportunityLineItem dealProd :filteredDealProds){
            Id storefrontAccountId=null;
            String[] accProdKeyTokens;
            String accountProductPricingKey;
            
            String[] accAllProdKeyTokens;
            String accAllProductPricingKey;
                        
            if(OpportunityIdMap.containsKey(dealProd.OpportunityId)){
                storefrontAccountId =OpportunityIdMap.get(dealProd.OpportunityId).Storefront_Account__c;
            }
            
            if(!mapPbepRecords.isEmpty() && mapPbepRecords.containsKey(dealProd.Pricebook_Entry_Period__c)){
                Pricebook_Entry_Period__c pbepRecord =mapPbepRecords.get(dealProd.Pricebook_Entry_Period__c);
                if(storefrontAccountId != null){
                    accProdKeyTokens = new String[]{String.ValueOf(storefrontAccountId).substring(0, 15), pbepRecord.Product__r.Country_Code__c, pbepRecord.Product__r.Tittle_Content_Type__c, pbepRecord.Product__r.Product_Market__c, pbepRecord.Product__r.Product_Format__c};
                    accountProductPricingKey = String.join(accProdKeyTokens, '_');
                                        
                    accAllProdKeyTokens = new String[]{String.ValueOf(storefrontAccountId).substring(0, 15), pbepRecord.Product__r.Country_Code__c,pbepRecord.Product__r.Product_Market__c};
                    accAllProductPricingKey = String.join(accAllProdKeyTokens, '_');
                                       
                }
            }
            //If Rate Card exists for the Deal Prod Combo Key then assign the records
            List<Rate_Card__c> lstRateCards =new List<Rate_Card__c>();
            
            if(mapAccountProductPricesExactMatch.containsKey(accountProductPricingKey)){
                lstRateCards = mapAccountProductPricesExactMatch.get(accountProductPricingKey);
            }
            
            Boolean flag = false;
            flag = setRateCardDetailsOnInsert(false , OpportunityIdMap, lstRateCards, mapDealProductAge, dealProd, mapPricingToUpdatePromoPrice, mapPricingToUpdate,mapPbepIdChangePromoPricing,pbepIdMap);
                        
            if(!flag){
                if(mapAccountProductPrices.containsKey(accAllProductPricingKey)){
                    lstRateCards = mapAccountProductPrices.get(accAllProductPricingKey);
                }
                flag = setRateCardDetailsOnInsert(true, OpportunityIdMap, lstRateCards, mapDealProductAge, dealProd, mapPricingToUpdatePromoPrice, mapPricingToUpdate,mapPbepIdChangePromoPricing,pbepIdMap);
                
            }
            //Still flag is false 
            if(!flag){
                //If no matches are found then throw error.
                mapLineItemErrorFlag.put(dealProd,false);
            }
            if(!mapAccountProductPricesExactMatch.containsKey(accountProductPricingKey) && !mapAccountProductPrices.containsKey(accAllProductPricingKey)){
                mapLineItemErrorFlag.put(dealProd,false);
            } 
        }

        for(OpportunityLineItem dealItem :lstNewDealProducts){
                        
            //When price tier is inserted
            if(mapPricingToUpdatePromoPrice.containsKey(dealItem)){
                Rate_Card__c rateCardRec = mapPricingToUpdatePromoPrice.get(dealItem);
                
                dealItem.Rate_Card__c = rateCardRec.id;                 
                dealItem.Promoted_price__c = setPromotedPriceOnDealProduct(dealItem,rateCardRec ,mapDealProductAge); 
            }
            //When Promo Price is inserted and valid Rate card is present
            if(mapPricingToUpdate.containsKey(dealItem)){
                Rate_Card__c rateCardRec = mapPricingToUpdate.get(dealItem);
                dealItem.Rate_Card__c = rateCardRec.id;    
                dealItem.Price_Tier__c =rateCardRec.Price_Tier__c;
            }

            if(mapLineItemErrorFlag.containsKey(dealItem)){
                //If valid Rate card is not found then set Rate card null and Price Tier to Null
                if((mapPbepIdChangePromoPricing.containskey(dealItem.Pricebook_Entry_Period__c) && !mapPbepIdChangePromoPricing.get(dealItem.Pricebook_Entry_Period__c))){    
                       dealItem.Rate_Card__c = null;    
                       dealItem.Price_Tier__c =null; 
                }else{
                    dealItem.addError(System.label.CRM_Check_Valid_Price_Tier);
                }
            }
        } 
    }
    
    
    /**
      *  Method to set the Rate Crad Details on the Rate Card Record in DealProduct and set the flag to throw error for incorrect data in Before Insert 
      *  @name setRateCardDetailsOnInsert
      *  @param List<Rate_Card__c> lstRateCards,Map<Id,Integer> mapDealProductAge,OpportunityLineItem dealProd,Map<OpportunityLineItem,Rate_Card__c> mapPricingToUpdatePromoPrice, Map<OpportunityLineItem,Rate_Card__c> mapPricingToUpdate ,map<Id,Boolean> mapPbepIdChangePromoPricing
      *  @return boolean
      *  @throws None
      *  US#985
      */
    private static boolean setRateCardDetailsOnInsert(Boolean allRateCards, map<Id,Opportunity> OpportunityIdMap, List<Rate_Card__c> lstRateCards,
                                                        Map<Id,Integer> mapDealProductAge, OpportunityLineItem dealProd,
                                                        Map<OpportunityLineItem,Rate_Card__c> mapPricingToUpdatePromoPrice, 
                                                        Map<OpportunityLineItem,Rate_Card__c> mapPricingToUpdate 
                                                        ,map<Id,Boolean> mapPbepIdChangePromoPricing, map<Id,Pricebook_Entry_Period__c> pbepIdMap){
        Boolean flag = false;
        Set<String> uniqueProductKeySet =new Set<String>();
        List<Rate_Card__c> lstContentTypeRateCards = new List<Rate_Card__c>();
        List<Rate_Card__c> lstFormatRateCards = new List<Rate_Card__c>();
        List<Rate_Card__c> lstAllRateCards = new List<Rate_Card__c>();                                                    
        //If key matches with the rateCard records then set the Rate Card look up and Promoted Price on Deal Product.
        for(Rate_Card__c rateCard : lstRateCards) {
            if(rateCard.Start_Date__c <= OpportunityIdMap.get(dealProd.OpportunityId).Start_Date__c && rateCard.End_Date__c >= OpportunityIdMap.get(dealProd.OpportunityId).Start_Date__c){           
                if(allRateCards){
                    if(pbepIdMap.containsKey(dealProd.Pricebook_Entry_Period__c)){
                      String accountProductPriKey ='';
                        String prodFormat = pbepIdMap.get(dealProd.Pricebook_Entry_Period__c).Product__r.Product_Format__c;
                        String prodCT = pbepIdMap.get(dealProd.Pricebook_Entry_Period__c).Product__r.Tittle_Content_Type__c;
                        accountProductPriKey = getAccountRateCardKey(rateCard, prodFormat, prodCT);
                        // Defect WBCTASK000243966: Rate Card Functionality: Assignment of incorrect Promoted Price Tier
                      // Checking Condition if accountProductPriKey is not null
                        if(accountProductPriKey !='' && !uniqueProductKeySet.contains(accountProductPriKey)){
                          uniqueProductKeySet.add(accountProductPriKey);
                          //flag =prepareRateCardDetailsOnInsert(dealProd, rateCard, mapPricingToUpdatePromoPrice, mapPricingToUpdate ,
                          //                  mapDealProductAge,flag,mapPbepIdChangePromoPricing);
                        /*if(flag){
                                break;
                            }*/
                          //Update the Rate Card Lists according to the value of Content Type and Format
              if(!accountProductPriKey.contains(rateCard.Content_Type__c) && !accountProductPriKey.contains(rateCard.Format__c)){
                                lstAllRateCards.add(rateCard);
                            }
              else if(accountProductPriKey.contains(rateCard.Content_Type__c) && accountProductPriKey.contains(String.ValueOf(dealProd.Promoted_price__c))){
                            lstContentTypeRateCards.add(rateCard);
                            }
              else if(accountProductPriKey.contains(rateCard.Format__c) && accountProductPriKey.contains(String.ValueOf(dealProd.Promoted_price__c))){
                            lstFormatRateCards.add(rateCard);    
                            }
                     }
                   }
                }else{
                    flag =  prepareRateCardDetailsOnInsert(dealProd, rateCard, mapPricingToUpdatePromoPrice, mapPricingToUpdate ,
                        mapDealProductAge,flag, mapPbepIdChangePromoPricing);
                        if(flag){
                            break;
                        }
                }
            }
        }
        // Defect WBCTASK000243966: Rate Card Functionality: Assignment of incorrect Promoted Price Tier
    //Run prepareRateCardDetails() according to Content Type and Format values and give priority to Content Type
        if(!lstContentTypeRateCards.isEmpty()){
           flag =  prepareRateCardDetailsOnInsert(dealProd, lstContentTypeRateCards[0], mapPricingToUpdatePromoPrice, mapPricingToUpdate ,
                        mapDealProductAge,flag, mapPbepIdChangePromoPricing);                                                     
        }
        else if(!lstFormatRateCards.isEmpty() && lstContentTypeRateCards.isEmpty()){
          flag =  prepareRateCardDetailsOnInsert(dealProd, lstFormatRateCards[0], mapPricingToUpdatePromoPrice, mapPricingToUpdate ,
                        mapDealProductAge,flag, mapPbepIdChangePromoPricing);                                                        
       }
        else if(lstContentTypeRateCards.isEmpty() && lstFormatRateCards.isEmpty() && !lstAllRateCards.isEmpty()){
          flag =  prepareRateCardDetailsOnInsert(dealProd, lstAllRateCards[0], mapPricingToUpdatePromoPrice, mapPricingToUpdate ,
                        mapDealProductAge,flag, mapPbepIdChangePromoPricing);                                                       
        }                                                    
    return flag;
    }
    
    /**
      *  Method to set the Rate Card Details on the Rate Card Record in DealProduct and set the flag to throw error for incorrect data in Before Insert 
      *  @name prepareRateCardDetailsOnInsert
      *  @param OpportunityLineItem dealProd, Rate_Card__c rateCard, 
                    Map<OpportunityLineItem,Rate_Card__c> mapPricingToUpdatePromoPrice, Map<OpportunityLineItem,Rate_Card__c> mapPricingToUpdate ,
                    Map<Id,Integer> mapDealProductAge,Boolean flag,map<Id,Boolean> mapPbepIdChangePromoPricing
      *  @return boolean
      *  @throws None
      *  US#985
      */
    private static Boolean prepareRateCardDetailsOnInsert(OpportunityLineItem dealProd, Rate_Card__c rateCard, 
                                                             Map<OpportunityLineItem,Rate_Card__c> mapPricingToUpdatePromoPrice, 
                                                             Map<OpportunityLineItem,Rate_Card__c> mapPricingToUpdate ,
                                                             Map<Id,Integer> mapDealProductAge,Boolean flag,
                                                             Map<Id,Boolean> mapPbepIdChangePromoPricing){
         //if Price tier is given at DP insert
            if(rateCard != null && rateCard.Price_Tier__c != null && rateCard.Price_Tier__c.equalsIgnoreCase(dealProd.Price_Tier__c) 
            && (mapPbepIdChangePromoPricing.containskey(dealProd.Pricebook_Entry_Period__c) 
            && mapPbepIdChangePromoPricing.get(dealProd.Pricebook_Entry_Period__c))) {
                mapPricingToUpdatePromoPrice.put(dealProd,rateCard);
                flag = true;
            }
            //US#663 :  code to fetch price tier based on changed promo price
            if(rateCard != null && (mapPbepIdChangePromoPricing.containskey(dealProd.Pricebook_Entry_Period__c) && !mapPbepIdChangePromoPricing.get(dealProd.Pricebook_Entry_Period__c))){
                if((rateCard.WSP1__c != null && rateCard.WSP1__c == dealProd.Promoted_price__c) ||
                    (rateCard.WSP2__c != null && rateCard.WSP2__c == dealProd.Promoted_price__c) ||
                    (rateCard.WSP3__c != null && rateCard.WSP3__c == dealProd.Promoted_price__c)
                ){
                    Decimal promoPrice = setPromotedPriceOnInsertDealProduct(dealProd,rateCard ,mapDealProductAge); 
                    
                    if(promoPrice != null){
                        dealProd.Promoted_price__c = promoPrice; //setPromotedPriceOnInsertDealProduct(dealProd,rateCard ,mapDealProductAge);
                        mapPricingToUpdate.put(dealProd,rateCard);
                        flag = true;
                    } 
                } 
            } 
        return flag;
    }
    
    
    /**
      *  Method to set the Promoted price on DealProduct when Price Tier is entered
      *  @name setPromotedPriceOnDealProduct
      *  @param OpportunityLineItem dealItem , Rate_Card__c rateCardRec ,Map<Id,Integer> mapDealProductAge 
      *  @return Decimal
      *  @throws None
      *  US#985
      */
    private static Decimal setPromotedPriceOnDealProduct(OpportunityLineItem dealItem , Rate_Card__c rateCardRec ,
                                                            Map<Id,Integer> mapDealProductAge ){
        Decimal promotedPrice =null;
        if (rateCardRec.Step_Pricing__c == FALSE){
            promotedPrice = rateCardRec.WSP1__c;
        }else if(rateCardRec.Step_Pricing__c == TRUE && mapDealProductAge.containsKey(dealItem.Product2Id)){
            if (mapDealProductAge.get(dealItem.Product2Id) < rateCardRec.Step1_Length_Months__c){
                promotedPrice = rateCardRec.WSP1__c;
            }else if (mapDealProductAge.get(dealItem.Product2Id) < rateCardRec.Step2_Length_Months__c){
                promotedPrice = rateCardRec.WSP2__c;
            }else{    
                promotedPrice = rateCardRec.WSP3__c;
            }
        }
        return  promotedPrice;
    }
    
    
    /**
      *  Method to set the Promoted price on DealProduct when Promoted price is entered
      *  @name setPromotedPriceOnDealProduct
      *  @param OpportunityLineItem dealItem , Rate_Card__c rateCardRec ,Map<Id,Integer> mapDealProductAge 
      *  @return Decimal
      *  @throws None
      *  US#985
      */
    private static Decimal setPromotedPriceOnInsertDealProduct(OpportunityLineItem dealItem, Rate_Card__c rateCardRec,
                                                                    Map<Id,Integer> mapDealProductAge ){
                                                                        
        Decimal promotedPrice =null;
        if (rateCardRec.Step_Pricing__c == FALSE && dealItem.Promoted_price__c == rateCardRec.WSP1__c){
            promotedPrice = rateCardRec.WSP1__c;
        }else if(rateCardRec.Step_Pricing__c == TRUE && mapDealProductAge.containsKey(dealItem.Product2Id)){
            if (mapDealProductAge.get(dealItem.Product2Id) < rateCardRec.Step1_Length_Months__c  && dealItem.Promoted_price__c == rateCardRec.WSP1__c){
                promotedPrice = rateCardRec.WSP1__c;
            }else if (mapDealProductAge.get(dealItem.Product2Id) >= rateCardRec.Step1_Length_Months__c && mapDealProductAge.get(dealItem.Product2Id) < rateCardRec.Step2_Length_Months__c && dealItem.Promoted_price__c == rateCardRec.WSP2__c){
                promotedPrice = rateCardRec.WSP2__c;
            }else if (mapDealProductAge.get(dealItem.Product2Id) >= rateCardRec.Step2_Length_Months__c && dealItem.Promoted_price__c == rateCardRec.WSP3__c){
                promotedPrice = rateCardRec.WSP3__c;
            }
        }
        return  promotedPrice;
    }
}