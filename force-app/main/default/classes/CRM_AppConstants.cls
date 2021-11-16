public class CRM_AppConstants {
    // No Need to create Lables for following constants
    public static final String OPPORTUNITY_OBJECT ='Opportunity';
    public static final String ORDER_OBJECT ='Order';
    public static final String BUNDLE_OBJECT ='Bundle__c';
    public static final String GAMES_TITTLE_CONTENT_TYPE = 'Game';
    public static final String VIDEO_DIGITAL_PRODUCT_TYPE = 'Video Digital';
    public static final String GAMES_DIGITAL_PRODUCT_TYPE = 'Games Digital';
    public static final String VIDEO_PHYSICAL_PRODUCT_TYPE = 'Video Physical';
    public static final String GAMES_PHYSICAL_PRODUCT_TYPE = 'Games Physical';
    //Defect # 3976
    public static final String EPISODE_CONTENT_TYPE = 'Episode';
    
    //US JAPAN : 561
    public static final String MUSIC_TITTLE_CONTENT_TYPE = 'Music';
    public static final String MUSIC_DIGITAL_PRODUCT_TYPE = 'Music Digital';
    public static final String MUSIC_PHYSICAL_PRODUCT_TYPE = 'Music Physical';
    public static final String MUSIC_DIGITAL_PRODUCT_TYPE_SHORT_NAME = 'MD';
    public static final String MUSIC_PHYSICAL_PRODUCT_TYPE_SHORT_NAME = 'MP';
    public static final String SBOM_PRODUCT_TYPE = 'SBOM';
    public static final String UNBW_PRODUCT_TYPE = 'UNBW';
    public static final String ZEST_SAP_MATERIAL_TYPE = 'ZEST';
    public static final String FERT_SAP_MATERIAL_TYPE = 'FERT';
    public static final String SBOM_SAP_MATERIAL_TYPE = 'SBOM';
    public static final String UNBW_SAP_MATERIAL_TYPE = 'UNBW';
    public static final String VIDEO_DIGITAL_PRODUCT_TYPE_SHORT_NAME = 'VD';
    public static final String GAMES_DIGITAL_PRODUCT_TYPE_SHORT_NAME = 'GD';
    public static final String VIDEO_PHYSICAL_PRODUCT_TYPE_SHORT_NAME = 'VP';
    public static final String GAMES_PHYSICAL_PRODUCT_TYPE_SHORT_NAME = 'GP';
    public static final String ACCOUNT_STATUS_ACTIVE = 'N';
    public static final String ACCOUNT_STATUS_BLOCKED = 'B';
    public static final String ACCOUNT_STATUS_EXPLANNING = 'E';
    public static final String Entity_CRM= 'CRM';
    //450
    public static final String EUR_CURRENCY_CODE = 'EUR';
    public static final String GBP_CURRENCY_CODE = 'GBP';
    public static final String USD_CURRENCY_CODE = 'USD';
    
    //US JAPAN : 476
    public static final String SAP_DIST_CHAIN_PRODUCT_ACTIVE_STATUS = '01';
    //US JAPAN : 536
    public static final String REQUEST_DRAFT_STATUS = 'Draft';
    
    //US JAPAN : 561
    public static final String JAPAN_COUNTRY_CODE = 'JP';

    // create lables for following constants
    public static final String OPPORTUNITY_STAGE_APPROVED ='Approved';
    public static final String OPPORTUNITY_STAGE_CANCELLED ='Cancelled';
    public static final String OPPORTUNITY_STAGE_AWAITING_APPROVAL ='Awaiting Approval';
    public static final String OPPORTUNITY_STAGE_REVISED ='Revised';
    public static final String OPPORTUNITY_STAGE_COMMITTED ='Committed';
    public static final String OPPORTUNITY_STAGE_PLANNED ='Planned';
    public static final String OPPORTUNITY_STAGE_SCENARIO ='Scenario';
    public static final String OPPORTUNITY_STAGE_CLOSED ='Closed';
    public static final String OPPORTUNITY_STAGE_POS_Actuals ='POS Actuals';
    public static final String OPPORTUNITY_STAGE_Actuals_Sales = 'Actual Sales';
    public static final String OPPORTUNITY_STAGE_NR_DEFAULT ='NR Default';
    public static final String OPPORTUNITY_STAGE_REJECTED ='Rejected';
    public static final String OPPORTUNITY_DEAL_PRIORITY_NORMAL ='Normal';
    //--ER-007269 Added for Admin Status as new for JV project --Start--//
    public static final String OPPORTUNITY_ADMIN_STATUS_NEW ='New';
    //--ER-007269 Added for Admin Status as new for JV project --End--//

    public static final String ASSORTMENT_STATUS_DRAFT ='Draft';
    public static final String ASSORTMENT_STATUS_AWATING_APPROVAL ='Awaiting Approval';
    public static final String ASSORTMENT_STATUS_APPROVED ='Approved';
    public static final String ASSORTMENT_STATUS_PENDING_CHANGES = 'Pending Changes (Finance)';
    public static final String ASSORTMENT_STATUS_PENDING_FINANCIAL_REVIEW = 'Pending Financial Review';
    
    //public static final String ASSORTMENT_STATUS_PUBLISHED ='Published';
    public static final String ASSORTMENT_STATUS_CANCELLED = 'Cancelled';
    public static final String PROMOTIONAL_ASSORTMENT = 'Promotional Assortment';
    public static final String CAMPAIGN_ASSORTMENT = 'Campaign Assortment';
    
    public static final String ASSORTMENT_TYPE_NATIONAL ='National';
    public static final String ASSORTMENT_PRICING_MODE_NET_PRICE ='Net Price';
    public static final String ASSORTMENT_PRICING_MODE_FILE_DISCOUNT ='File Discount';
    
    //US#590 (JAPAN)
    public static final String ORDER_STAGE_SUBMITTED ='Submitted';
    public static final String ORDER_STAGE_In_SAP ='In SAP';
    //DEF#4213
    public static final String ORDER_STAGE_IN_FAILED ='Failed';
  
    public static final String OPPORTUNITY_RECORDTYPE_PHYSICAL_DEAL ='Physical Deal';
    public static final String OPPORTUNITY_RECORDTYPE_DIGITAL_DEAL ='Digital Deal';
    public static final String OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_TRADE_SPEND_DEAL ='Trade_Spend';
    public static final String OPPORTUNITY_RECORDTYPE_PHYSICAL_POS_DEAL ='Physical ADV/POS';
    public static final String OPPORTUNITY_RECORDTYPE_PHYSICAL_DFI_DEAL ='Physical DFI Deal';
    //--W-017677 Added for new planning deal recordtype for JV project --Start--//
    public static final String OPPORTUNITY_RECORDTYPE_PHYSICAL_PLANNING_DEAL ='Physical Planning Deal';
    //--W-017677 Added for new planning deal recordtype for JV project --End--//
    
    //US:936 
    public static final String OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DEAL ='Physical_Deal';
    public static final String OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_HIGH_LEVEL_DEAL ='High_Level';
    public static final String OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL ='Physical_POS_Deal';
    public static final String OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DFI_DEAL ='Physical_DFI_Deal';
    //--W-017677 Added for new planning deal recordtype for JV project --Start--//
    public static final String OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_PLANNING_DEAL ='Physical_Planning_Deal';
    //--W-017677 Added for new planning deal recordtype for JV project --End--//

    public static final String RENTAL_ACCOUNT_SPLIT ='Rental';
    public static final String RENTAL_ACCOUNT_PLAN = 'Rental';

    public static final String ACCOUNT_RECORDTYPE_SOLD_TO ='Sold To';

    //--W-017644, W-017678 added for deal product reason for JV project--Start--//
    public static final String DEAL_PRODUCT_REASON_DFI ='DFI';
    public static final String DEAL_PRODUCT_REASON_POS_REBATE ='POS Rebate';
    //--W-017644, W-017678 added for deal product reason for JV project--Start--//

    public static final Set<String> SALES_ORGS_TO_PROCESS_SHIP_TO =
        new Set<String>{
            CRM_AppConstants.TERRITORY_FRANCE_CODE, CRM_AppConstants.TERRITORY_JAPAN_CODE,
            CRM_AppConstants.TERRITORY_GERMANY_CODE, CRM_AppConstants.TERRITORY_SWITZERLAND_CODE,
            CRM_AppConstants.TERRITORY_ITALY_CODE, CRM_AppConstants.TERRITORY_SPAIN_CODE,
            CRM_AppConstants.TERRITORY_NORWAY_CODE, CRM_AppConstants.TERRITORY_FINLAND_CODE,
            CRM_AppConstants.TERRITORY_DENMARK_CODE, CRM_AppConstants.TERRITORY_SWEDEN_CODE
        };
       
    //W-017571 - Start - Added Condition to skip CRMJV Accounts 
    public static final Set<String> SALES_JV_ORGS =
        new Set<String>{
            CRM_AppConstants.TERRITORY_SDS_US_CODE, CRM_AppConstants.TERRITORY_SDS_CANADA_CODE
        };   
    //W-017571 - End - Added Condition to skip CRMJV Accounts 

    public static final Set<String> NR_WITH_FRANCE_LIKE_WITHOUT_BENELUX_SALES_ORGS =
        new Set<String>{
            CRM_AppConstants.TERRITORY_FRANCE_CODE, CRM_AppConstants.TERRITORY_JAPAN_CODE,
            CRM_AppConstants.TERRITORY_ITALY_CODE,
            CRM_AppConstants.TERRITORY_US_CODE,CRM_AppConstants.TERRITORY_CANADA_CODE,CRM_AppConstants.TERRITORY_MEXICO_CODE
        };
 
    public static final Set<String> NR_WITH_FRANCE_LIKE_WITHOUT_BENELUX_DIGITAL_COUNTRY_CODES =
        new Set<String>{
            CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE, CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_ITALY_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_WB_US_DIGITAL_COUNTRY_CODE,CRM_AppConstants.ACCOUNT_WB_CANADA_DIGITAL_COUNTRY_CODE
        };
 
    public static final Set<String> BENELUX_SALES_ORGS =
        new Set<String>{CRM_AppConstants.TERRITORY_NETHERLAND_CODE, CRM_AppConstants.TERRITORY_BELGIUM_CODE};

    public static final Set<String> NR_WITH_BENELUX_LIKE_SALES_ORGS =
        new Set<String>{CRM_AppConstants.TERRITORY_NETHERLAND_CODE, CRM_AppConstants.TERRITORY_BELGIUM_CODE, CRM_AppConstants.TERRITORY_SPAIN_CODE};

    public static final Set<String> NR_WITH_FRANCE_LIKE_SALES_ORGS =
        new Set<String>{CRM_AppConstants.TERRITORY_FRANCE_CODE,
            CRM_AppConstants.TERRITORY_NETHERLAND_CODE, CRM_AppConstants.TERRITORY_BELGIUM_CODE, CRM_AppConstants.TERRITORY_JAPAN_CODE,
            CRM_AppConstants.TERRITORY_ITALY_CODE, CRM_AppConstants.TERRITORY_SPAIN_CODE,
            CRM_AppConstants.TERRITORY_US_CODE,CRM_AppConstants.TERRITORY_CANADA_CODE,CRM_AppConstants.TERRITORY_MEXICO_CODE
        };

    public static final Set<String> BENELUX_DIGITAL_COUNTRY_CODES =
        new Set<String>{
            CRM_AppConstants.ACCOUNT_BG_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_LX_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_NL_DIGITAL_COUNTRY_CODE
        };

    public static final Set<String> NR_WITH_BENELUX_LIKE_DIGITAL_COUNTRY_CODES =
        new Set<String>{
            CRM_AppConstants.ACCOUNT_BG_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_LX_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_NL_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
        };

    public static final Set<String> NR_WITH_FRANCE_LIKE_DIGITAL_COUNTRY_CODES =
        new Set<String>{
            CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_BG_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_LX_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_NL_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_ITALY_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_WB_US_DIGITAL_COUNTRY_CODE,CRM_AppConstants.ACCOUNT_WB_CANADA_DIGITAL_COUNTRY_CODE
        };

    public static final Set<String> IT_SP_NO_SALES_ORGS =
        new Set<String>{
            CRM_AppConstants.TERRITORY_ITALY_CODE,
            CRM_AppConstants.TERRITORY_SPAIN_CODE,
            CRM_AppConstants.TERRITORY_NORWAY_CODE, CRM_AppConstants.TERRITORY_FINLAND_CODE, CRM_AppConstants.TERRITORY_DENMARK_CODE, CRM_AppConstants.TERRITORY_SWEDEN_CODE
        };
    public static final String TERRITORY_ITALY_CODE = '6008';
    public static final String TERRITORY_SPAIN_CODE = '6505';
    public static final String TERRITORY_NORWAY_CODE = '6509';
    public static final String TERRITORY_FINLAND_CODE = '6510';
    public static final String TERRITORY_DENMARK_CODE = '6511';
    public static final String TERRITORY_SWEDEN_CODE = '6013';
    public static final Set<String> TERRITORY_NORDICS_CODE =
        new Set<String>{
            CRM_AppConstants.TERRITORY_NORWAY_CODE,
            CRM_AppConstants.TERRITORY_FINLAND_CODE,
            CRM_AppConstants.TERRITORY_DENMARK_CODE,
            CRM_AppConstants.TERRITORY_SWEDEN_CODE
        };

    public static final Set<String> ACCOUNT_IT_SP_NO_DIGITAL_COUNTRY_CODES =
        new Set<String>{
            CRM_AppConstants.ACCOUNT_ITALY_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_NORWAY_DIGITAL_COUNTRY_CODE, CRM_AppConstants.ACCOUNT_FINLAND_DIGITAL_COUNTRY_CODE, CRM_AppConstants.ACCOUNT_DENMARK_DIGITAL_COUNTRY_CODE, CRM_AppConstants.ACCOUNT_SWEDEN_DIGITAL_COUNTRY_CODE
        };
    public static final String ACCOUNT_BRAZIL_DIGITAL_COUNTRY_CODE = '40';
    public static final String ACCOUNT_ITALY_DIGITAL_COUNTRY_CODE = '595';
    public static final String ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE = '772';
    public static final String ACCOUNT_NORWAY_DIGITAL_COUNTRY_CODE = '620';
    public static final String ACCOUNT_FINLAND_DIGITAL_COUNTRY_CODE = '125';
    public static final String ACCOUNT_DENMARK_DIGITAL_COUNTRY_CODE = '515';
    public static final String ACCOUNT_SWEDEN_DIGITAL_COUNTRY_CODE = '350';
    public static final Set<String> ACCOUNT_NORDICS_DIGITAL_COUNTRY_CODE =
        new Set<String>{
            CRM_AppConstants.ACCOUNT_NORWAY_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_FINLAND_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_DENMARK_DIGITAL_COUNTRY_CODE,
            CRM_AppConstants.ACCOUNT_SWEDEN_DIGITAL_COUNTRY_CODE
        };

    public static final String TERRITORY_FRANCE_CODE ='6007';
    public static final String TERRITORY_NETHERLAND_CODE ='6004';
    public static final String TERRITORY_BELGIUM_CODE ='6501';
    public static final String TERRITORY_GERMANY_CODE ='6014';
    public static final String TERRITORY_SWITZERLAND_CODE ='6005';
    public static final String TERRITORY_UK_CODE ='6000';
    public static final String TERRITORY_JAPAN_CODE ='8003';
    public static final String TERRITORY_US_CODE ='2500';
    public static final String TERRITORY_CANADA_CODE ='2403';
    // added as a part of US924 US GAMES
    public static final String TERRITORY_MEXICO_CODE ='2504';
    // added as a part of JVCRM
    public static final String TERRITORY_SDS_US_CODE ='9500';
    public static final String TERRITORY_SDS_CANADA_CODE ='9403';

    
    public static final String ACCOUNT_JP_DIGITAL_COUNTRY_CODE = '600';

    // Refered as UK Digital Country Code in code logic
    public static final String ACCOUNT_US_DIGITAL_COUNTRY_CODE = '80';

    // Refered as US Digital Country Code in code logic
    public static final String ACCOUNT_WB_US_DIGITAL_COUNTRY_CODE = '435';
    public static final String ACCOUNT_WB_CANADA_DIGITAL_COUNTRY_CODE = '443';
    public static final Set<String> ACCOUNT_US_DIGITAL_COUNTRY_CODES = new Set<String>{ACCOUNT_WB_US_DIGITAL_COUNTRY_CODE,ACCOUNT_WB_CANADA_DIGITAL_COUNTRY_CODE};
    
    //added as part of US924 US Games
    public static final Set<String> US_SALES_ORGS = new Set<String>{TERRITORY_US_CODE,TERRITORY_CANADA_CODE,TERRITORY_MEXICO_CODE};

    public static final String ACCOUNT_IRE_DIGITAL_COUNTRY_CODE = '975';
    public static final String ACCOUNT_FR_DIGITAL_COUNTRY_CODE = '520';
    public static final String ACCOUNT_BG_DIGITAL_COUNTRY_CODE = '524';
    public static final String ACCOUNT_LX_DIGITAL_COUNTRY_CODE = '791';
    public static final String ACCOUNT_NL_DIGITAL_COUNTRY_CODE = '523';
    
    public static final String ACCOUNT_AUSTRIA_DIGITAL_COUNTRY_CODE = '870';
    public static final String ACCOUNT_GERMANY_DIGITAL_COUNTRY_CODE = '555';
    public static final Set<String> ACCOUNT_SWITZERLAND_DIGITAL_COUNTRY_CODES = new Set<String>{'142','143','144','145'};
    public static final Set<String> GERMANY_DIGITAL_COUNTRY_CODES =
        new Set<String>{
            CRM_AppConstants.ACCOUNT_AUSTRIA_DIGITAL_COUNTRY_CODE,CRM_AppConstants.ACCOUNT_GERMANY_DIGITAL_COUNTRY_CODE,'142','143','144','145'
        };

    public static final Set<String> NR_WITH_GERMANY_LIKE_DIGITAL_COUNTRY_CODES =
        new Set<String>{
            CRM_AppConstants.ACCOUNT_AUSTRIA_DIGITAL_COUNTRY_CODE,CRM_AppConstants.ACCOUNT_GERMANY_DIGITAL_COUNTRY_CODE,'142','143','144','145',
            CRM_AppConstants.ACCOUNT_NORWAY_DIGITAL_COUNTRY_CODE, CRM_AppConstants.ACCOUNT_FINLAND_DIGITAL_COUNTRY_CODE, CRM_AppConstants.ACCOUNT_DENMARK_DIGITAL_COUNTRY_CODE, CRM_AppConstants.ACCOUNT_SWEDEN_DIGITAL_COUNTRY_CODE
        };

    public static final Set<String> GERMANY_SALES_ORGS =
        new Set<String>{CRM_AppConstants.TERRITORY_GERMANY_CODE, CRM_AppConstants.TERRITORY_SWITZERLAND_CODE};

    public static final Set<String> NR_WITH_GERMANY_LIKE_SALES_ORGS =
        new Set<String>{
            CRM_AppConstants.TERRITORY_GERMANY_CODE, CRM_AppConstants.TERRITORY_SWITZERLAND_CODE,
            CRM_AppConstants.TERRITORY_NORWAY_CODE, CRM_AppConstants.TERRITORY_FINLAND_CODE, CRM_AppConstants.TERRITORY_DENMARK_CODE, CRM_AppConstants.TERRITORY_SWEDEN_CODE
        };

    public static String DEAL_OBJECT_NAME = 'Opportunity';


    // String Constants used for Contribution
    public static String CONTRIBUTION_TEMPLATE_LABEL = 'Contribution Template';
    public static String CONTRIBUTION_TEMPLATE_API_NAME = 'Contribution_Template__c';
    public static String CONTRIBUTION_TEMPLATE_R = 'Contribution_Template__r';
    public static String ACCOUNT_API_NAME = 'Account';
    public static String PRODUCT_LABEL = 'Product';
    public static String PRODUCT_API_NAME = 'Product2';
    public static String CRM_FUNCTIONALMODULE_FETCH_CONTRIBUTIONTEMPLATE = 'getOpportunityAndContributionTemplate';
    public static final String DEAL_FORECASTCATEGORY_APPROVED = 'Approved';
    public static final String DEAL_FORECASTCATEGORY_PLANNED = 'Planned';
    public static final String DEAL_FORECASTCATEGORY_CONFIRMED = 'Confirmed';

    public static final String PRODUCT_TYPE_CATALOG = 'LB';
    public static final String PRODUCT_TYPE_NEW_RELEASE = 'NR';
    public static final String PRODUCT_RELEASE_CATEGORY_CATALOG = '19';
    public static final String PRODUCT_RELEASE_CATEGORY_NEW_RELEASE = '23';
    public static final String PRODUCT_RENTAL_MARKET_TYPE = '1';
    public static final String PRODUCT_SELL_THROUGH_MARKET_TYPE = '2';

    public static final String DEAL_RENTAL_MARKET_TYPE = '1';
    public static final String DEAL_SELL_THROUGH_MARKET_TYPE = '2';
    public static final Set<String> JAPAN_PRODUCT_MARKETS = new Set<String>{CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE, CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE};

    public static final String PRODUCT_MATERIAL_TYPE_FERT = 'FERT';
    public static final String PRODUCT_MATERIAL_TYPE_UNBW = 'UNBW';
    public static final String PRODUCT_PACK_TYPE_MultiPack = '3';
    
    public static final String FUNCTIONAL_MODULE_PDF_FROM_SAP_TO_RETURNORDER = 'Order';
    public static final String FUNCTIONAL_MODULE_DECAY_CURVE = 'Decay Curve';
    public static final String FUNCTIONAL_MODULE_ADD_PRODUCTS = 'Add Products';
    public static final String FUNCTIONAL_MODULE_NR_PRODUCTS = 'NR Products';
    public static final String FUNCTIONAL_MODULE_TARGET = 'Targets';
    public static final String FUNCTIONAL_MODULE_DEALS = 'Deals';
    public static final String FUNCTIONAL_MODULE_PRODUCT_POPUP = 'Product Popup';
    public static final String FUNCTIONAL_MODULE_CAS_PRODUCT_CREATION_BATCH = 'CAS Product Creation Batch';
    public static final String FUNCTIONAL_MODULE_DEAL_PRODUCT_ROLLUP = 'Deal Product Rollup';
    public static final String FUNCTIONAL_MODULE_MOVE_GL_CALENDAR_ON_COUNTRY_PLAN = 'Move Country Plan Targets';
    public static final String FUNCTIONAL_MODULE_UPDATE_ACCOUNT_PLAN = 'Update Account Plan';
    public static final String FUNCTIONAL_MODULE_DELETE_ACCOUNT_PLAN = 'Delete Account Plan';
    //public static final String FUNCTIONAL_MODULE_UPDATE_SCHEDULE_DATE = 'Update Schedule Date';
    public static final String FUNCTIONAL_MODULE_UPDATE_PRODUCT_FOR_SCHEDULE_DATE = 'Update Product For Schedule Date';
    public static final String FUNCTIONAL_MODULE_UPDATE_DEAL_FOR_SCHEDULE_DATE = 'Update Deal for Schedule Date';
    public static final String FUNCTIONAL_MODULE_PROCESS_DEAL_UPDATE = 'Process Deal Update';
    public static final String FUNCTIONAL_MODULE_PROCESS_DEAL_PRODUCT_UPDATE = 'Process Deal Product Update';
    public static final String FUNCTIONAL_MODULE_DUPLICATE_PBEP_UPDATE = 'Duplicate PBEP Update';
    public static final String FUNCTIONAL_MODULE_DUPLICATE_PBEP_PRODUCT_UPDATE = 'Duplicate PBEP Product Update';
    /*public static final String FUNCTIONAL_MODULE_UPDATE_SCHEDULE_DATE = 'Update Schedule Start Date';
    public static final String FUNCTIONAL_MODULE_UPDATE_RELEASE_DATE_OR_SCHEDULES = 'Update Release Date / Schedules';*/
    // Req#628
    public static final String FUNCTIONAL_MODULE_CHANGE_TARGET_SPLIT_TEMPLATE = 'Change Target Split Template';

  //Defect : 4224
  public static final String FUNCTIONAL_MODULE_AUTOALLOCATE_TARGETS = 'Auto Allocate Targets';
  
    public static final String DIGITAL_INITIALS = 'Digital';
    public static final String PHYSICAL_INITIALS = 'Physical';
    public static final String ACCOUNT_SOLD_TO  = 'Sold To';
    public static final String TargetCustomSettings = 'PeriodForEligibleTargets';

    // String Constants used for Target creation
    public static final String Country_Plan_TYPE_CATALOG = 'Catalog';
    public static final String Country_Plan_TYPE_NEW_RELEASE = 'New_Release';
    
     // String Constants used for Target batch creation
    public static final String Country_Plan_Target = 'Country Plan Target';
    public static final String Country_Plan = 'Country Plan';
    public static final String Account_Plan = 'Account Plan';
    
    //NR Batch
    public static final String NR_Deal_Japan_Naming_INITIAL = System.Label.CRM_Japan_NR_Batch_Deal_Initial + ' ';
    public static final String NR_Deal_Japan_Market_Type_RENTAL = System.Label.CRM_Japan_NR_Batch_Deal_Market_Type_Rental + ' ';
    public static final String NR_Deal_Japan_Market_Type_SELL_THROUGH = System.Label.CRM_Japan_NR_Batch_Deal_Market_Type_Sell_Through + ' ';
    public static final String NR_Deal_Japan_Product_Type_GAMES_PHYSICAL = System.Label.CRM_Japan_NR_Batch_Deal_Product_Type_Games_Physical + ' ';
    public static final String NR_Deal_Japan_Product_Type_VIDEO_PHYSICAL = System.Label.CRM_Japan_NR_Batch_Deal_Product_Type_Video_Physical + ' ';
    public static final String NR_Deal_Japan_Product_Type_GAMES_DIGITAL = System.Label.CRM_Japan_NR_Batch_Deal_Product_Type_Games_Digital + ' ';
    public static final String NR_Deal_Japan_Product_Type_VIDEO_DIGITAL = System.Label.CRM_Japan_NR_Batch_Deal_Product_Type_Video_Digital + ' ';
    // US JAPAN : 561
    public static final String NR_Deal_Japan_Product_Type_MUSIC_PHYSICAL = System.Label.CRM_Japan_NR_Batch_Deal_Product_Type_Music_Physical + ' ';
    public static final String NR_Deal_Japan_Product_Type_MUSIC_DIGITAL = System.Label.CRM_Japan_NR_Batch_Deal_Product_Type_Music_Digital + ' ';

    // DEF JAPAN ISSUES : 8
    public static final String NR_Deal_Japan_Naming_Day = System.Label.CRM_Japan_NR_Batch_Deal_Name_Day;
    public static final String NR_Deal_Japan_Naming_Year = System.Label.CRM_Japan_NR_Batch_Deal_Name_Year;
    public static final String NR_Deal_Japan_Month_Connector = System.Label.CRM_Japan_NR_Batch_Deal_Name_Connector + ' ';
    public static final Map<String, String> NR_Deal_Japan_Month_Map =
        new Map<String, String>{
            'Jan' => System.Label.CRM_Japan_NR_Batch_Deal_Name_Month_Jan,
            'Feb' => System.Label.CRM_Japan_NR_Batch_Deal_Name_Month_Feb,
            'Mar' => System.Label.CRM_Japan_NR_Batch_Deal_Name_Month_Mar,
            'Apr' => System.Label.CRM_Japan_NR_Batch_Deal_Name_Month_Apr,
            'May' => System.Label.CRM_Japan_NR_Batch_Deal_Name_Month_May,
            'Jun' => System.Label.CRM_Japan_NR_Batch_Deal_Name_Month_Jun,
            'Jul' => System.Label.CRM_Japan_NR_Batch_Deal_Name_Month_Jul,
            'Aug' => System.Label.CRM_Japan_NR_Batch_Deal_Name_Month_Aug,
            'Sep' => System.Label.CRM_Japan_NR_Batch_Deal_Name_Month_Sep,
            'Oct' => System.Label.CRM_Japan_NR_Batch_Deal_Name_Month_Oct,
            'Nov' => System.Label.CRM_Japan_NR_Batch_Deal_Name_Month_Nov,
            'Dec' => System.Label.CRM_Japan_NR_Batch_Deal_Name_Month_Dec
        };
    public static final String NR_Deal_Naming_Convention = 'New Releases ';
    public static final String NR_Deal_For_Quarter = 'Q';
    public static final String NR_Deal_For_Month = 'M';
    public static final String Product_Record_Type_Digital = 'Digital Product';
    public static final String Product_Record_Type_Physical = 'Product';
    public static final String Country_Plan_Record_Type_NR = 'New Release';

    // Constants required for the class: CRM_GeneratePDFForCreditNotes

    public static final String CRM_WB_Company_Name_Germany = 'Warner Bros. Entertainment GmbH';
    public static final String CRM_WB_Company_UK = 'WHV UK';
    public static final String CRM_WB_Company_Germany = 'WHV UK';

    // Contants required in CRM_CreateProductsAndPBEPBatch
    public static final String CRM_Client_Avail_Status_Confirmed = 'Confirmed';
    /*public static final String CRM_DE_Catalog_Products = 'DE Catalog Products';
    
    // Constants required for COP
    public static final String CRM_DE_COP_Common_Price_Gema = 'Gema';
    public static final String CRM_DE_COP_Common_Price_GrossReceiptTaxes = 'Gross receipt taxes (FFA)';
    public static final String CRM_DE_COP_Common_Price_DoubtfulAccounts = 'Doubtful Accounts';
    
    // Constants required for Credit Note item Insert
    public static final String CRM_CREDIT_NOTE_ORDER_TYPE = 'ZMD';*/
    
    //Flag to delete config product related to SBOM and FERT Products
    public static boolean configProductDeleteFlag = true;
    
    //Flag to activate all child orders 
    public static boolean orderActivateFlag = true;

    // Desription of Schedule for UK / FR
    public static final String SCHEDULE_INITIAL = 'Initial Schedule';
    public static final String SCHEDULE_REPLEN_DELAY = 'Replen Delay Schedule';
    public static final String SCHEDULE_DECAY_TEMPLATE = 'Decay Template Schedule: ';
    public static final String SCHEDULE_PL = 'P&L Schedule';
    public static final String SCHEDULE_PL_DECAY_TEMPLATE = 'P&L Template Schedule: ';
    public static final String SCHEDULE_TYPE_BOTH = 'Both';
    public static final String SCHEDULE_TYPE_REVENUE = 'Revenue';
    public static final String SCHEDULE_TYPE_QUANTITY = 'Quantity';
    public static final String SCHEDULE_ZERO = 'Zero Quantity';

    // Label For Desription of Schedule for Japan US#483
    public static final String SCHEDULE_INITIAL_HANDLING_FEE = label.CRM_Initial_Handling_Fee;
    public static final String SCHEDULE_FINAL_PURCHASE_PRICE = label.CRM_Final_Purchase_Price;  
    public static final String SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN = label.CRM_Decay_Template_Schedule;

    //JAPAN US 515
    public static final String FRANCE_COUNTRY_CODE = 'FR';
    public static final String UK_COUNTRY_CODE = 'GB';
    
    //JAPAN DEF#3886
    public static final String FRANCE_COUNTRY = 'France';
    public static final String JAPAN_COUNTRY = 'Japan';
    // Req#818
    public static final String ITALY_COUNTRY = 'Italy';
    
    //US #516: Profile Constant
    public static final String PROFILE_CRM_Marketing_FR_BX = 'CRM - Marketing FR/BX'; 
    
    //Defect#3836:teritory code constants
    public static final String BELGIUM_COUNTRY_CODE = 'BE';
    public static final String NETHERLANDS_COUNTRY_CODE = 'NL';
    public static final String BENELUX_COUNTRY_CODE = 'BENL';
    
    //US#563
    public static final String BENELUX_PROFILE_CODE ='BX'; 
    
    //Defect#3895 : Decay Curve is miscalculating schedules
    public static final String DECAY_CURVE_TEMPLATE_STATUS_ACTIVE = 'Active';
    public static final String DECAY_CURVE_TEMPLATE_STATUS_ARCHIVED = 'Archived';
    public static final String DECAY_CURVE_TEMPLATE_STATUS_DRAFT = 'Draft';
    
    //Req: 585 : Generate Multi Order From Deal
    public static final String ORDER_STATUS_OPEN = 'Open';
    
    //Req.232 : filter on products by distribution chain status, plant status.
    public static final String PRODUCT_PLANT_STATUS_ACTIVE = '04';
    public static final String PRODUCT_PLANT_STATUS_SELL_DOWN = '05';
    public static final String PRODUCT_PLANT_STATUS_RELEASE_THIRDPARTY = '02';
    public static final String PRODUCT_PLANT_STATUS_INITIAL = '01';
    public static final String PRODUCT_SAP_DIST_STATUS_ACTIVE = '01';
    public static final String PRODUCT_SAP_DIST_STATUS_INITIAL = '11';
    public static final String PRODUCT_SAP_DIST_STATUS_ONHOLD = '04';
    public static final String PRODUCT_SAP_DIST_STATUS_NON_RETURNABLE_Z5 = 'Z5';
    public static final String PRODUCT_SAP_DIST_STATUS_NON_RETURNABLE_05 = '05';
    public static final String PRODUCT_SAP_DIST_STATUS_LOST_RIGHTS = '08';
    //--ER-007379 added Product Allocation constant--Start--//
    public static final String PRODUCT_SAP_DIST_STATUS_PRODUCT_ALLOCATION = '40';
    //--ER-007379 added Product Allocation constant--End--//
    
    //US#590 (JAPAN)
    public static final String RETURN_ORDER_RETURN_APPROVAL = 'Approved';
    public static final String RETURN_ORDER_RETURN_REJECTED = 'Rejected';
    public static final String RETURN_ORDER_RETURN_AWAITING_APPROVAL = 'Awaiting Approval';
    
    //US#371 AND Defect#4078
    public static final String CREDIT_NOTE_STATUS_PLANNED ='Planned';
    public static final String CREDIT_NOTE_STATUS_READY_TO_PAY ='Ready to pay';
    public static final String CREDIT_NOTE_STATUS_PAID = 'Paid';
    public static final String CREDIT_NOTE_STATUS_AWAITING_APPROVAL = 'Awaiting approval';
    public static final String CREDIT_NOTE_STATUS_REVISED = 'Revised';
    public static final String CREDIT_NOTE_STATUS_REJECTED = 'Rejected';
    public static final String CREDIT_NOTE_STATUS_FAILED = 'Failed';
    public static final String CREDIT_NOTE_TYPE_CREDIT_MEMO = 'ZMC';
    public static final String CREDIT_NOTE_TYPE_REVERSAL = 'ZMD';
    public static final String CREDIT_NOTE_HEADER_STATUS_IN_SAP = 'In SAP';
    public static final String CREDIT_NOTE_HEADER_STATUS_IN_FAILED = 'Failed';
    public static final String CREDIT_NOTE_STATUS_REJECTED_IN_SAP = 'Rejected In SAP';
    public static final Set<String> CREDIT_NOTE_STATUS_MOVEED_REVISED = new Set<String>{CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED};
    
    //REQ#596
    public static final String TARGET_MAINTAINED_AS_REVENUE = 'Revenue';
    public static final String TARGET_MAINTAINED_AS_QUANTITY = 'Quantity';
    
  //#776
    public static final String USA_Country = 'USA';
    public static final String CANADA_Country = 'Canada';
    
    //RecordType Skipping
    public static final Set<Id> CRM_ProductRecordTypes = new Set<Id>{
        CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL,
        //CRM_RecordTypeUtil.RT_PRODUCT_DC,
        CRM_RecordTypeUtil.RT_PRODUCT_SBOM,
        CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL
    };
    
    //US#663 - constants added to verify change.
    public static final String PRICE_TIER_CHANGED ='PriceTier';
    public static final String PROMO_PRICE_CHANGED ='PromoPrice';
    
    //US : 814 : Finance Review Process on Assortment Profitability
    public static final String ASSORTMENT_TRADE_CAMPAING_TYPE = 'Trade Promotion';
    
    //Us : 905 : US Games
    public static final String COOP_BUDGET_DEFAULT_EVENT_NAME = 'General';
    public static final String COOP_REASON_BUDGET = 'Budget';
    public static final String TACTIC_STATUS_BUDGET = 'Budget'; 
    public static final String REASON_POS_REBATE = 'POS Rebate'; 
    public static final String REASON_DIGITAL_WB_PROMO = 'Digital – WB Promo';
    public static final String REASON_DIGITAL_SITE_PROMO = 'Digital – Site Promo';
    //ER-006847 :  Add Co-op Reason Tactic: Digital – Subscription
    public static final String REASON_DIGITAL_SUBSCRIPTION = 'Digital – Subscription';
    public static final String DEAL_PRODUCT_STATUS_PLANNED = 'Planned';
    public static final String DEAL_PRODUCT_STATUS_CANCELLED = 'Cancelled';
    public static final String DEAL_PRODUCT_STATUS_PAID = 'Paid';
    public static final String DEAL_PRODUCT_STATUS_PAYMENT_IN_PROGRESS = 'Payment in Progress';
    
    //US : 926 : US Games
     public static final String FUNCTIONAL_MODULE_ADD_TACTICS_ON_CNT = 'Add Tactics on Credit Note Item';
     
    //US : 936 : US Games
    public static final String PRICEBOOK_COUNTRY_USA = 'USA';
    public static final String PRICEBOOK_COUNTRY_CAN = 'CAN';
    public static final String PRICEBOOK_COUNTRY_MEX = 'MEX';
    public static final String PRICEBOOK_PRODUCT_TYPE_PHYSICAL = 'Physical';
    public static final String CREDIT_NOTE_STATUS_RECEIVED_IN_SAP = 'Received In SAP';
    public static final Set<String> US_PRICEBOOK = new Set<String>{PRICEBOOK_COUNTRY_USA, PRICEBOOK_COUNTRY_CAN, PRICEBOOK_COUNTRY_MEX};
    
    //US : 926 : US Games
     public static final Set<String> ACCRUING_TACTIC_REASONS =
        new Set<String>{
            'Cost Markdown Rebate' , 
            'Display' , 
            'Exclusives / Premiums' , 
            'Feature' , 
            'In-Store Signage' , 
            'New Item Placement' , 
            'Operational Expense' , 
            'Online Ad / Placement' , 
            'POS Rebate' , 
            'Print Ad' , 
            'Term Based Payment'
        };
      
      //Defect : 4604 : Sprint 2 US Games
      //ER-006847 - Add Co-op Reason Tactic: Digital – Subscription
      public static final Set<String> NON_ACCRUING_TACTIC_REASONS =
        new Set<String>{
            '3rd Party Invoice Payment',
            'Digital – Site Promo',
            'Digital – WB Promo',
            'Digital – Subscription',
            'Digital Media Spend',
            'Canada – POS Rebate',
            'Canada – Display',
            'Canada – Feature',
            'Canada - In-Store Signage',
            'Canada - New Item Placement',
            'Canada - Online Ad/Placement',
            'Canada - Print Ad'
        }; 
      
    //DEF#4524
    public static final string SFDC_Batch_User = 'SFDC Batch User';
      
    //US : 905 -->  01 =Active ,11=Initial & 06=Cutout 
    public static final Set<String> sAPdistChainProductStatus = new Set<String>{'01','11','06'};
    public static final String DUPPLICATE_RECORD_ERROR_MESSAGE = 'Duplicate external id specified';
       
    //US : 930 -->  Collaboration Group Name For US Games addChatterPostUSGames
    public static final String COLLABORATIONGROUP_CHATTERPOST = 'WBIE US Channel Marketing Notifications';   
    
     //Defect #4619: Show default filter on page layout on add products page.
    //01 = Active, 04 = On Hold, 11 = Initial 
    public static final Set<String> distChainProdStatus = new Set<String>{'01','04','11'};
    //01 = Initial, 02 = Released for 3rd Party, 04 = Active, 05 = Sell-down/Sell-Off
    public static final Set<String> plantSpecificMaterialStatus = new Set<String>{'01','02','04', '05'};
    
    public static final String PRODUCT_FIELD_SAP_DIST_CHAIN_PRODUCT_STATUS ='SAP_Dist_chain_product_Status__c';
    public static final String PRODUCT_FIELD_PLANT_SPECIFIC_MATERIAL_STATUS ='Plant_Specific_Material_Status__c';
    
    //US : 962 --> All UK profile list constant
    public static final string PROFILE_CRM_Finance_UK = 'CRM - Finance - UK';
    public static final string PROFILE_CRM_LocalAdmin_UK = 'CRM - Local Admin - UK';
    public static final string PROFILE_CRM_Marketing_UK = 'CRM - Marketing - UK';
    public static final string PROFILE_CRM_Operations_UK = 'CRM - Operations - UK';
    public static final string PROFILE_CRM_Sales_UK = 'CRM - Sales - UK';
    public static final Set<String> PROFILE_CRM_UK_territory = new Set<String>{CRM_AppConstants.PROFILE_CRM_Finance_UK,CRM_AppConstants.PROFILE_CRM_LocalAdmin_UK,CRM_AppConstants.PROFILE_CRM_Marketing_UK,CRM_AppConstants.PROFILE_CRM_Operations_UK,CRM_AppConstants.PROFILE_CRM_Sales_UK};
    public static final String CRM_COUNTRY_UK = 'UK';
    public static final String UK_COUNTRY = 'United Kingdom';
    
   
    //US:984 : Advance Promo Pricing
    public static final String CONTENT_TYPE_OR_FORMAT_ALL_VALUE = 'All';
    public static final String RC_LIFECYCLE_HISTORY_EXPIRE = 'History Expired';
    
    //US : 994 : Add 'Results Filter' and 'Reset Page' features to upload/extract grids in CRMI
    public static final String SUCCESS_MSG = 'success';
    public static final String ERROR_MSG = 'error';
    
    //ER-003026
    public static final String CHECKBOX_YES ='YES';
    public static final String CHECKBOX_NO ='NO';
    
    //ER-003346
    public static final String EARLIEST_AVAIL_DATE_SOURCE_TARGET = 'Target';
    public static final String EARLIEST_AVAIL_DATE_STATUS_UNLOCKED = 'Unlocked';
    
    //ER-003396
    public static final String REASON_CANADA_POS_REBATE = 'Canada – POS Rebate';    
    //ER-003232 Product bible
    public static final String STATUS_TENTATIVE = 'Tentative';
    public static final String STATUS_CANCELLED ='Cancelled';
    
    //CREDIT NOTE RECORD TYPE DEVELOPER (API) NAMES
    public static final String CREDIT_NOTE_PHYSICAL_RC_API_NAME = 'Physical';
    public static final String CREDIT_NOTE_PHYSICAL_REVERSE_RC_API_NAME ='Physical_Reverse';
    
    //Account Class of Trade Picklist Values
    public static final String CLASS_OF_TRADE_RETAIL_COST = 'Retail Cost';
    public static final String CLASS_OF_TRADE_RETAIL_DIRECT ='Retail Direct';
    
    //Pricebook Entry Period Price Type Values
    public static final String PBEP_PRICE_TYPE_PROMOTION ='PROMOTION';
    public static final String PBEP_PRICE_TYPE_DEALER ='DEALER';
    public static final String PBEP_PRICE_TYPE_RETAIL_COST ='RETAIL COST';
    public static final String PBEP_PRICE_TYPE_MENU ='MENU';
    
    //Deal Admin Status
    public static final String DEAL_ADMIN_STATUS_COMPLETE ='Complete';
    public static final String DEAL_ADMIN_STATUS_SENT_TO_SAP = 'Sent to SAP';
    public static final String SALES_ADMIN_PROFILE_NAME ='CRM - TFM - Sales Admin';
    
    //Deal Method of Payment
    public static final String DEAL_MOP_CREDIT_MEMO ='Credit Memo';
    public static final String DEAL_MOP_CHECK ='Check';
    
    //Deal Price Type
    public static final String DEAL_PRICE_TYPE_ZPRD = 'ZPRD';
    public static final String DEAL_PRICE_TYPE_ZPFD = 'ZPFD';

    //Deal Check Paid Picklist values
    public static final String DEAL_CHECK_PAID_YES ='Yes';
    public static final String DEAL_CHECK_PAID_NO ='No';
    
    //WBIE Pricebook Names
    public static final String WBIE_US_PRICEBOOK_NAME ='WBIE - US';
    public static final String WBIE_CAN_PRICEBOOK_NAME ='WBIE - CAN';
    
    //Object API Names
    public static final String DEAL_PRODUCT_API_NAME ='OpportunityLineItem';

    //Deal Product Account Fund Segment
    public static final String DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT ='NAT';
    //--ER-007269, ER-007676 Added for DFI Status as None and Cancel for JV project --Start--//
    public static final String DEAL_PRODUCT_DFI_STATUS_NONE = 'None';
    public static final String DEAL_PRODUCT_DFI_STATUS_CANCEL = 'Cancel';
    //--ER-007269, ER-007676 Added for DFI Status as None and Cancel for JV project --Start--//
    
    public static final Set<String> CRM_DEAL_READ_ONLY_PROFILES = new Set<String>{'CRM - TFM - Credit - Entry'};
    public static final Set<String> CRM_UPLOAD_EXTRACT_READ_ONLY_PROFILES = new Set<String>{'CRM - TFM - Sales Admin', 'CRM - TFM - Reporting', 'CRM - Channel Marketing - Physical', 'CRM - Read Only - SDS'};
}