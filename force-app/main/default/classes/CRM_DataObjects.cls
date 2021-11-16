global with sharing class CRM_DataObjects {
    
    global class ProductWrapper {
        global ProductItem[] products;
        global Integer maxPageCount;
        global Boolean maxLimitExceeded;
        //US#253
        global Set<Id> setProductIds;
        global Boolean isDigital;//US#1015:Product language column
    }
    global class DealProdWrapper {
        global Id dealId;
        global String dealCurrencyCode;
        global Id pricebookId;
        global Id productId;
        global Id productRecTypeId;
        global Date productStreetDate;
        global Date productNREndDate;
        global Date startDate;
        global Date endDate;
        global String releaseCatgory;
    }
    
    global class ParentRecord {
        global String salesOrg; 
        global String currencyCode;
        global Date startDate;
        global Date endDate;
        global Id bundleId;
        global Id accountId;
        global string recordType;//US#232
        global Opportunity dealRecord;
        global Order orderRecord;
         //US#788 UNBW Products for Bundle
        global Id bundleRecordTypeId;
        global Bundle__c bundleRecord;//Defect#4363
    }
    
    global class ProductItem {
        global Boolean isSelected;
        global Id productId;
        global String pricebookEntryId;
        global String name;
        global String productCode;
        global String format;
        global Date streetDate;
        global String imageUrl;
        global String videoVersion;
        global String countryCode;
        global String languageCode;
        global Integer quantity;
        global Integer stockQty;
        global Decimal listPrice;
        global Decimal recommendedPrice;
        global String currencyCode;
        global Boolean stockWarning;
        global String externalId;
        global String salesOrg;
        global String distriButionChannel;
        global String universalProductCode;
        global Date releaseDate;
        
        //JAPAN-US:480 For Product Filter on Deal related to JAPAN
        global String productMarket;
        global String productType;
        //For Order Product Filter
        global String plantSpecificMaterialStatus;
        global String sAPDistChainProductStatus;
       /*Red Border Enhancement in Add Product Page All Terrritory*/ 
        global Boolean ExclusiveCustomerFlag;
        //US#232
        global Boolean SAPAndPlantStatusWarning;
        //US#253 starts
        global Decimal lastPromotedPrice;
        global Decimal threeMonthOrderHistory;
        //US#253 ends 
        //US#909 Ankita
        global Integer quantityForProd =1;
        
    }

    global class ProductItemSave {
        global Id productId;
        global String pricebookEntryId;
        global Integer quantity;
        global Decimal listPrice;
    }
    
    global class SearchFilters {
        global String text;
        global String title;
        global String materialNumber;
        global Boolean fullMatchMaterialNumber;
        global Boolean bundleProductsOnly;
        global Boolean exclusiveProductFlag;
        global Boolean isMarketingMaterial;
        global Boolean showAvailedProductsOnly;
        global Integer pageCount;
        
        //US#232 
    global PicklistOption[] plantStatus;
        global PicklistOption[] StreetDate;
        global PicklistOption[] distChainProdStatus;
        global PicklistOption[] releaseCategories;
        global PicklistOption[] productMarkets;
        global PicklistOption[] productFormats;
        global PicklistOption[] productTypes;
        global PicklistOption[] productGenres;
        global PicklistOption[] prodLanguages;
        global PicklistOption[] franchiseTypes;
        global PicklistOption[] productRatings;
        global PicklistOption[] contentTypes;
        global Double recommendedPriceFrom;
        global Double recommendedPriceTo;
        global Double listPriceFrom;
        global Double listPriceTo;
        global String sortByField;
        global String sortOrder;
    //US#554
    global Date streetDateFrom;
        global Date streetDateTo;
    }
    
    global class PicklistOption {
        global String label;
        global String value;
        global Boolean selected;
        
        global PicklistOption(String val, String lbl) {
            label = lbl;
            value = val;
            selected = false;
        }
    } 
    
    global class PhysicalProductToEdit{
        global ID lineItemId;
        global string coopReason;
        global ID productId;
        global string productName;
        global string productCode;
        global Date startDate;
        global Date endDate;
        // global List<Deal_Overlap__c> dealOverlapList;
        global List<DealOverLapWrapper> dealOverlapWrap;

    }
    global class DealOverLapWrapper{
        global id overLapId;
        global string dealName;
        global  string dealCode;
        global date startDate;
        global date endDate;
        global string stageName;
    }
    /* FOR EDIT OPP PRODUCTS*/
    global class ProductToEdit {
        global Boolean isSelected;
        global Boolean isDirtyRow;
        global Id lineItemId;
        global Id productId;
        global Id dealOrOrderId;
        global Id pricebookEntryId;
        global String productName;
        global String productCode;
        global Boolean isNR;
        global String format;
        global String prodFormat;//US#617
        global Double listPrice;
        global Double suggestedPrice;
        global Double accountPrice;
        global Double minimumPrice; // For German Requirement Provided by Jorge on Mail.
        global Double promotedPrice;
        global Double totalQty;
        global Double discount;
        global Double customerRetailPrice;
        global String materialStreetDate;
        global String cutOffDate;
        global String currencyCode;
        global String startDate;
        global Double approvedQty;
        global Double UnitPrice;
        global Boolean scheduleEnabled;
        global Double grossRevenue;
        global Double unitCOP;
        global Double netContribution;
        global Double returns;
        global Double salesAllowance;
        global Double coop;
        global Double merchandising;
        global Double distributionCost;
        global Double returnCost;
        global Double productionCost;
        global Double royalFeeFixed;
        global Double masterNegative;
        global Boolean overrideCOP;
        global Double totalPrice;
        global Double totalCOP;
        global Double estContribution;
        global Double estContributionPercent;
        global Double customerSalesRevenue;
        global Double customerContribution;
        global Double minimumContribution;
        global Boolean isMarketingMaterial;
        global Double posQuantity;
        global Double pap;
        //global Boolean isGermanyAccount;
        global Double targetUnit;
        global Double actualQty;
        global Double initialQuantity;
        // US 547
        global Double initialBackOrderQuantity;
        global Double replenQuantity;
        global String decayCurveTemplate;
        global String decayCurveTemplateName;
        global Double nrCoopAmount;
        global String coopReason;
        global String coopComments;
        global String languageCode;
        global Boolean isManuallySchedule;
        global Integer replenDelayDays;
        global Double allocationOverride;
        global Double plQuantity;
        global String plDecayCurveTemplate;
        global String plDecayCurveTemplateName;
        global Boolean isConsignmentCustomer;
        global Double sharePercent;
        global Double replenPercent;
        
        //Japan-US:483: To display Account Plan Fields
        global Decimal handlingFee;
        global Decimal rentalPrice;
        global Decimal revenueShare;
        global Decimal numberOfRentals;
        global Decimal finalPurchasePrice;
        global Decimal finalPurchase;
        //global String decayCurve;
        //Japan - DEF#3926
        global Boolean overrideRentalPrices;
        //US #581: Populate Consignment Multiplier on Deal Product
        global Decimal consignmentMultiplier;
        
        //Added for Germany US #283
        global Decimal gema;
        global Decimal grossReceiptTaxesFFA;
        global Decimal doubtfulAccounts;
        global Decimal cashDiscounts;
        
        //US#172 June Release
        global String priceTier;
        //US#663 - added new field 
        global String PermanentPriceTier;
        global List<String> lstPriceTier =new List<String>{''} ;
         
        //US#598
        global Boolean isUnTargetedDealProd =false;
        
        global Map<String, Boolean> inValidFormatMap = new Map<String, Boolean>();
         
    } 

    global class SimilarTitles {
        global List<SimilarTitle> lstSimilarTitle;
    }

    global class SimilarTitle {
        global String titleId;
        global String titleName;
        global Double[] schedules;
    }

    global class OrderHistory{
        global List<String> months;
        global List<Decimal> posActuals;
        global List<Decimal> actuals;         
    }
}