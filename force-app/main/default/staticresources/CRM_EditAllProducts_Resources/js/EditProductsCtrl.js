    //************************************************************/
    //                       APP CONTROLLER
    //************************************************************/
    
    crmApp = angular.module('crmEditProducts', ['appConfig', 'crm-components', 'sfdcDataService', 'ngSanitize','simplePagination', 'ui.utils.masks'])
    
    .controller('crmEditProductController', function($scope, $filter, getLineItemsService, addLineItemsService, saveLineItemsService, getSelectOptionsService,appConfig, Pagination, updateDealService) {
         $scope.appConfig = appConfig;
     
         var initalHeight = ($(window).height() - $('#headerDiv').height() - $('#errorDiv').height() - $('#updateDiv').height());
         $scope.height = initalHeight;
         var initialHeightNewGrid = ($(window).height() - $('#headerDiv').height() - $('#errorDiv').height());
         $scope.heightNew = initialHeightNewGrid;
         function setHeight() {
             $scope.height = (initalHeight - $("#errorDiv").height());
         }
         $scope.removeMsgBlock= function(){
             $scope.msgText = '';
             $scope.height = initalHeight;
         };
        //Added for Pagination
         $scope.sortVar ='asc';
        $scope.maxProductLimit =$scope.appConfig.maxProductLimit;

        $scope.pagination = Pagination.getNew($scope.maxProductLimit);
        //$scope.pagination.numPages = 0;
        $scope.filter = function() {
            $scope.pagination = Pagination.getNew($scope.maxProductLimit);
            $scope.filteredArray = $filter('filter')($scope.lineItems, $scope.search.text);

            if ($scope.filteredArray.length === 0) {
                $scope.pagination.numPages = 1;
            } else {
                $scope.pagination.numPages = Math.ceil($scope.filteredArray.length/$scope.pagination.perPage);
            }
            $scope.pagination.page = 0;
        } 
        $scope.isJapanDeal = $scope.appConfig.isJapan;
        $scope.isJapanForSellThrough = $scope.appConfig.isJapanForSellThrough;
        $scope.isJapanTerritory = $scope.appConfig.isJapanTerritory;
        $scope.isDigitalDeal = $scope.appConfig.isDigitalDeal;
        $scope.isConsignmentCustomer = $scope.appConfig.isConsignmentCustomer;
        //US#799 - added field to verify if user can access the cost tab based on access of production cost
        $scope.isAccessibleToUser = $scope.appConfig.isAccessibleToUser;
        //$scope.hideOrDisableFields = $scope.appConfig.hideOrDisableFields;
        $scope.isGerman = $scope.appConfig.isGerman;
        $scope.isFrance = $scope.appConfig.isFrance;
        //US:936:US Games - added to disable the promoted price input on edit all product page
        $scope.isUSCANMEXTerritory = $scope.appConfig.isUSCANMEXTerritory;
        console.log('--$scope.isFrance-->',$scope.isFrance);
        $scope.isRevenueShareAccount = $scope.appConfig.isRevenueShareAccount;
        $scope.coopReasonOptions;
        $scope.lineItems;
        $scope.isLightningExperienceOrSf1 = ((typeof sforce != 'undefined') && sforce && (!!sforce.one));
        $scope.search = {};
        $scope.updateRowsField = [];
        $scope.updateRowsFieldVal;
        $scope.updateCoopReasonVal;
        $scope.updateCoopAmountVal
        $scope.msgText;
        $scope.msgSeverity;
        $scope.quickSave;
        $scope.isMasterChecked = false;
        $scope.moreInfoProduct;
        $scope.moreInfoProductUrl;
        $scope.allLineItems;
        if($scope.isJapanDeal){
            $scope.currentTab = 'wb-tab-RentalDetails';
        }else{
            $scope.currentTab = 'wb-tab-planning';
        }
    
        //Added for Japan Rental Price Override
        $scope.overrideRentalPrices;
        //US#605 starts
        $scope.overrideCOP;
        //US#605 ends 
        $scope.dealProduct;
        $scope.showConfirmationPopUp = function(dealProduct) {
            $scope.overrideRentalPrices = false;
            dealProduct.overrideRentalPrices = false;
            $scope.dealProduct = dealProduct;
        };
        $scope.hideConfirmationPopUp = function() {
            $scope.overrideRentalPrices = null;
        };
        $scope.applyOverridePricing = function() {
            angular.forEach($scope.lineItems, function(item, i) {
                if ($scope.dealProduct.productId == item.productId) {
                    item.overrideRentalPrices = true;
                    item.isDirtyRow = true;
                }
            });
            $scope.overrideRentalPrices = true;
        };
    
        //Added for laMoulinette functionality for France
        $scope.laMoulinette;
        $scope.highLevelTarget = $scope.appConfig.highLevelTarget;
        $scope.highLevelForecast = $scope.appConfig.highLevelForecast;
        $scope.showLaMoulinettePopup = function(prodLi) {
            $scope.laMoulinette = prodLi;
        };
        $scope.hideLaMoulinettePopup = function() {
            $scope.laMoulinette = null;
        };
        $scope.applyLaMoulinette = function() {
            angular.forEach($scope.lineItems, function(item, i) {
                //if(item.isSelected) {
                if(item.replenPercent == null || item.replenPercent == undefined || isNaN(item.replenPercent)) {
                    item.replenPercent = 0;
                }
                item.initialQuantity = Math.round($scope.highLevelForecast * (item.sharePercent/100) * (1 - (item.replenPercent/100)));
                item.initialQuantity = item.initialQuantity != 0 ? item.initialQuantity : 1;
                //Added for Req - 378 : France
                item.replenQuantity = Math.round($scope.highLevelForecast * (item.sharePercent/100) * (item.replenPercent/100));
                item.isDirtyRow = true;
                //}
            });
            $scope.hideLaMoulinettePopup();
        };
        
        /* US#598 Function to check/uncheck all the untargeted deal products */
        $scope.excludeUntargetedProd = false;
        $scope.isNRDeal = $scope.appConfig.IsNRDeal;
        
        //Added Co-op Requested Amount for Germany
        $scope.flagOfCoopReqPopup;
        $scope.coopRequestedDiscount = $scope.appConfig.coopRequestedDealAmount;
        $scope.showHideCoopRequestedAmountPopup = function(flag){
            $scope.flagOfCoopReqPopup = flag;
            $scope.popUpMsgText = null; 
            $scope.msgSeverity = null;
        };
        $scope.applyCoopRequestedAmount = function() {
        $scope.totalLineItems = $scope.lineItems.length;
            $scope.counterOfApplyDiscount = 0;
            $scope.estimatedCustomerRevenue = 0;
            if (isNaN($scope.coopRequestedDiscount)) {
                $scope.popUpMsgText = $Label.enterValidFormatForNumberFields;
                $scope.msgSeverity = 'error';
            } else {
                $scope.popUpMsgText = null;
                $scope.msgSeverity = null;
                angular.forEach($scope.lineItems, function(item, i) {
                    if(item.totalPrice == null || item.totalPrice == undefined || isNaN(item.totalPrice)) {
                        item.totalPrice = 0;
                    }
                    $scope.estimatedCustomerRevenue = $scope.estimatedCustomerRevenue + parseInt(item.totalPrice);
                });
                angular.forEach($scope.lineItems, function(item, i) {
                  if(item.totalPrice == null || item.totalPrice == undefined || isNaN(item.totalPrice)) {
                    item.totalPrice = 0;
                  }
                  if(i == ($scope.totalLineItems - 1)){
                    item.nrCoopAmount = parseInt($scope.coopRequestedDiscount - $scope.counterOfApplyDiscount);
                  }else{
                    item.nrCoopAmount = parseInt((item.totalPrice/$scope.estimatedCustomerRevenue)*$scope.coopRequestedDiscount);
                    $scope.counterOfApplyDiscount = $scope.counterOfApplyDiscount + item.nrCoopAmount;
                  }
                  if($scope.updateCoopReasonVal){
                     item.coopReason = $scope.updateCoopReasonVal;
                     //item.coopReason =$scope.updateCoopAmountVal;
                  }
                  item.isDirtyRow = true;
                });
                $scope.updateCoopReasonVal = '';
                $scope.showHideCoopRequestedAmountPopup(false);
            }
        };
        
        //Added for laMoulinette functionality for France
        $scope.noSharePercent = false;
        
        //Added for Pagination
      
       if($scope.isJapanDeal){
            $scope.updateRowFieldOptions = [
                {label:initialQuantityLabel, value:"initialQuantity"},
                {label:handlingFeeLabel, value:"handlingFee"},
                {label:rentalPriceLabel, value:"rentalPrice"},
                {label:revenueShareLabel, value:"revenueShare"},
                {label:numberOfRentalsLabel, value:"numberOfRentals"},
                {label:finalPurchasePriceLabel, value:"finalPurchasePrice"},
                {label:finalPurchaseLabel, value:"finalPurchase"},
                {label:returnsLabel, value:"returns", removeAccess : mapCostFieldsAccess[returnsLabel]},
                {label:papLabel, value:"pap", removeAccess : mapCostFieldsAccess[papLabel]},
                {label:salesAllowanceLabel, value:"salesAllowance", removeAccess : mapCostFieldsAccess[salesAllowanceLabel]},
                {label:merchandisingLabel, value:"merchandising", removeAccess : mapCostFieldsAccess[merchandisingLabel]},
                {label:distributionCostLabel, value:"distributionCost", removeAccess : mapCostFieldsAccess[distributionCostLabel]},
                {label:returnCostLabel, value:"returnCost", removeAccess : mapCostFieldsAccess[returnCostLabel]},
                {label:productionCostLabel, value:"productionCost", removeAccess : mapCostFieldsAccess[productionCostLabel]},
                {label:royaltyFeeFixedLabel, value:"royalFeeFixed", removeAccess : mapCostFieldsAccess[royaltyFeeFixedLabel]},
                {label:masterNegativeLabel, value:"masterNegative", removeAccess : mapCostFieldsAccess[masterNegativeLabel]}
            ];
        }
        else{
            if($scope.isDigitalDeal){
                if($scope.isJapan){
                    $scope.updateRowFieldOptions = [{label:initialQuantityLabel, value:"initialQuantity" }, {label:replenQuantityLabel, value:"replenQuantity"},{label:replenDelayDaysLabel, value:"replenDelayDays"}, {label:promotedPriceLabel, value:"promotedPrice"},{label:priceTierLabel, value:"priceTier"}, {label:promotedPriceByPercentLabel, value:"promotedPriceByPercent"},{label:returnsLabel, value:"returns" , removeAccess : mapCostFieldsAccess[returnsLabel]},{label:papLabel, value:"pap" , removeAccess : mapCostFieldsAccess[papLabel]},{label:salesAllowanceLabel, value:"salesAllowance" , removeAccess : mapCostFieldsAccess[salesAllowanceLabel]},{label:merchandisingLabel, value:"merchandising" , removeAccess : mapCostFieldsAccess[merchandisingLabel]},{label:distributionCostLabel, value:"distributionCost" , removeAccess : mapCostFieldsAccess[distributionCostLabel]},{label:returnCostLabel, value:"returnCost" , removeAccess : mapCostFieldsAccess[returnCostLabel]},{label:productionCostLabel, value:"productionCost" , removeAccess : mapCostFieldsAccess[productionCostLabel]},{label:royaltyFeeFixedLabel, value:"royalFeeFixed" , removeAccess : mapCostFieldsAccess[royaltyFeeFixedLabel]},{label:masterNegativeLabel, value:"masterNegative" , removeAccess : mapCostFieldsAccess[masterNegativeLabel]}];
                }else{
                    $scope.updateRowFieldOptions = [{label:quantityLabel, value:"replenQuantity"} ,{label:replenDelayDaysLabel, value:"replenDelayDays"},{label:promotedPriceLabel, value:"promotedPrice" }, {label:priceTierLabel, value:"priceTier"},{label:promotedPriceByPercentLabel, value:"promotedPriceByPercent"},{label:returnsLabel, value:"returns" , removeAccess : mapCostFieldsAccess[returnsLabel]},{label:papLabel, value:"pap" , removeAccess : mapCostFieldsAccess[papLabel]},{label:salesAllowanceLabel, value:"salesAllowance", removeAccess : mapCostFieldsAccess[salesAllowanceLabel]},{label:merchandisingLabel, value:"merchandising" , removeAccess : mapCostFieldsAccess[merchandisingLabel]},{label:distributionCostLabel, value:"distributionCost" , removeAccess : mapCostFieldsAccess[distributionCostLabel]},{label:productionCostLabel, value:"productionCost" , removeAccess : mapCostFieldsAccess[productionCostLabel]},{label:royaltyFeeFixedLabel, value:"royalFeeFixed" , removeAccess : mapCostFieldsAccess[royaltyFeeFixedLabel]},{label:masterNegativeLabel, value:"masterNegative"  , removeAccess : mapCostFieldsAccess[masterNegativeLabel]}];
                }
            }
            else if($scope.isJapanForSellThrough){
                $scope.updateRowFieldOptions = [{label:initialQuantityLabel, value:"initialQuantity"}, {label:replenQuantityLabel, value:"replenQuantity"}, {label:replenDelayDaysLabel, value:"replenDelayDays"}, {label:promotedPriceLabel, value:"promotedPrice"}, {label:promotedPriceByPercentLabel, value:"promotedPriceByPercent"},{label:initialBackOrderQuantityLabel, value:"initialBackOrderQuantity"},{label:salesAllowanceLabel, value:"salesAllowance", removeAccess : mapCostFieldsAccess[salesAllowanceLabel]},{label:merchandisingLabel, value:"merchandising" , removeAccess : mapCostFieldsAccess[merchandisingLabel]},{label:distributionCostLabel, value:"distributionCost" , removeAccess : mapCostFieldsAccess[distributionCostLabel]},{label:returnCostLabel, value:"returnCost"},{label:productionCostLabel, value:"productionCost", active:false, removeAccess : mapCostFieldsAccess[productionCostLabel]},{label:royaltyFeeFixedLabel, value:"royalFeeFixed"},{label:masterNegativeLabel, value:"masterNegative"  , removeAccess : mapCostFieldsAccess[masterNegativeLabel]}];
            }else if($scope.isGerman){
                $scope.updateRowFieldOptions = [{label:initialQuantityLabel, value:"initialQuantity"}, {label:replenQuantityLabel, value:"replenQuantity"}, {label:replenDelayDaysLabel, value:"replenDelayDays"}, {label:promotedPriceLabel, value:"promotedPrice"}, {label:promotedPriceByPercentLabel, value:"promotedPriceByPercent"},{label:initialBackOrderQuantityLabel, value:"initialBackOrderQuantity"},{label:salesAllowanceLabel, value:"salesAllowance", removeAccess : mapCostFieldsAccess[salesAllowanceLabel]},{label:returnsLabel, value:"returns" , removeAccess : mapCostFieldsAccess[returnsLabel]},{label:papLabel, value:"pap" , removeAccess : mapCostFieldsAccess[papLabel]},{label:merchandisingLabel, value:"merchandising" , removeAccess : mapCostFieldsAccess[merchandisingLabel]},{label:distributionCostLabel, value:"distributionCost" , removeAccess : mapCostFieldsAccess[distributionCostLabel]},{label:productionCostLabel, value:"productionCost", active:false , removeAccess : mapCostFieldsAccess[productionCostLabel]},{label:royaltyFeeFixedLabel, value:"royalFeeFixed"  , removeAccess : mapCostFieldsAccess[royaltyFeeFixedLabel]},{label:masterNegativeLabel, value:"masterNegative"  , removeAccess : mapCostFieldsAccess[masterNegativeLabel]},{label:gemaLabel, value:"gema"  , removeAccess : mapCostFieldsAccess[gemaLabel]},{label:grossReceiptTaxesFFALabel, value:"grossReceiptTaxesFFA"  , removeAccess : mapCostFieldsAccess[grossReceiptTaxesFFALabel]},{label:doubtfulAccountsLabel, value:"doubtfulAccounts"  , removeAccess : mapCostFieldsAccess[doubtfulAccountsLabel]},{label:cashDiscountsLabel, value:"cashDiscounts"  , removeAccess : mapCostFieldsAccess[cashDiscountsLabel]}];
            }else{
                if($scope.isUSCANMEXTerritory)
                    $scope.updateRowFieldOptions = [{label:initialQuantityLabel, value:"initialQuantity"}, {label:replenQuantityLabel, value:"replenQuantity"},{label:replenDelayDaysLabel, value:"replenDelayDays"}, {label:returnsLabel, value:"returns" , removeAccess : mapCostFieldsAccess[returnsLabel]},{label:papLabel, value:"pap" , removeAccess : mapCostFieldsAccess[papLabel]},{label:salesAllowanceLabel, value:"salesAllowance", removeAccess : mapCostFieldsAccess[salesAllowanceLabel]},{label:merchandisingLabel, value:"merchandising" , removeAccess : mapCostFieldsAccess[merchandisingLabel]},{label:distributionCostLabel, value:"distributionCost" , removeAccess : mapCostFieldsAccess[distributionCostLabel]},{label:productionCostLabel, value:"productionCost", active:false,removeAccess : mapCostFieldsAccess[productionCostLabel]},{label:royaltyFeeFixedLabel, value:"royalFeeFixed"},{label:masterNegativeLabel, value:"masterNegative"  , removeAccess : mapCostFieldsAccess[masterNegativeLabel]}];
                else 
                $scope.updateRowFieldOptions = [{label:initialQuantityLabel, value:"initialQuantity"}, {label:replenQuantityLabel, value:"replenQuantity"},{label:replenDelayDaysLabel, value:"replenDelayDays"}, {label:promotedPriceLabel, value:"promotedPrice"}, {label:promotedPriceByPercentLabel, value:"promotedPriceByPercent"},{label:returnsLabel, value:"returns" , removeAccess : mapCostFieldsAccess[returnsLabel]},{label:papLabel, value:"pap" , removeAccess : mapCostFieldsAccess[papLabel]},{label:salesAllowanceLabel, value:"salesAllowance", removeAccess : mapCostFieldsAccess[salesAllowanceLabel]},{label:merchandisingLabel, value:"merchandising" , removeAccess : mapCostFieldsAccess[merchandisingLabel]},{label:distributionCostLabel, value:"distributionCost" , removeAccess : mapCostFieldsAccess[distributionCostLabel]},{label:productionCostLabel, value:"productionCost", active:false,removeAccess : mapCostFieldsAccess[productionCostLabel]},{label:royaltyFeeFixedLabel, value:"royalFeeFixed"},{label:masterNegativeLabel, value:"masterNegative"  , removeAccess : mapCostFieldsAccess[masterNegativeLabel]}];
            }
        }
        if ($scope.isConsignmentCustomer) {
            $scope.updateRowFieldOptions.push({label:plQuantityLabel, value:"plQuantity"});
        }
    
        // added as a part of US916
        getSelectOptionsService(appConfig.apexController, 'Opportunity', 'Reason__c', $Label.selectNoneValueForPicklist).then(function(data) {
            $scope.coopReasonOptions = data;
        });
        
        $scope.previousUpdateRowFieldOptions = $scope.updateRowFieldOptions;
        $scope.changeUpdateAllRowList = function(){
        $scope.updateRowsField = [];
        $scope.updateRowsFieldVal = null;
        $scope.updateCoopReasonVal = null;
        //US#172 starts
        $scope.updatePriceTierVal = null;
        //US#172 ends
        if($scope.currentTab == 'wb-tab-nrCoop'){
           $scope.updateRowFieldOptions = [{label:coopRequestedAmountLabel, value:"coopRequestedAmount"},{label:coopReason, value:"coopReason"},];
        }else{
            $scope.updateRowFieldOptions = $scope.previousUpdateRowFieldOptions;
        }
        }
       
        // Method to update all records based on selected field to update
        $scope.updateAllRows = function() {
            var isAnyRowSelected = false
            
            angular.forEach($scope.lineItems, function(item, i) {
                if(item.isSelected) {
                    isAnyRowSelected = true;
                
                    if ($scope.updateRowsField[0] != null && $scope.updateRowsField[0] != undefined) {
                        if (!$scope.updateRowsFieldVal) {
                            if ($scope.updateRowsField[0].value == 'promotedPriceByPercent') {
                                item.isDirtyRow = true;
                                item.discount = parseInt($scope.updateRowsFieldVal);
                                item.promotedPrice = item.accountPrice;
                                //item.promotedPrice = +(item.promotedPrice.toFixed(2));
                                if ($scope.isJapanTerritory) {
                                    item.promotedPrice = Math.round(item.promotedPrice);
                                } else {
                                    item.promotedPrice = +(item.promotedPrice.toFixed(2));
                                }
                                $scope.validateFormatOnChange(item, 'promotedPrice');
                                $scope.handleEstimatedPriceChange(item, 'promoPriceChange');
                            } else if($scope.updateRowsField[0].value == 'priceTier' && $scope.updatePriceTierVal){
                                if(item.lstPriceTier.includes($scope.updatePriceTierVal)){ 
                                //US#172 DEF#4454
                                    item.isDirtyRow = true;
                                    item.priceTier = $scope.updatePriceTierVal;
                                }
                            }else if($scope.updateRowsField[0].value == 'coopReason' && $scope.updateCoopReasonVal){
                                item.isDirtyRow = true;
                                item.coopReason = $scope.updateCoopReasonVal;
                            }else if($scope.updateRowsField[0].value == 'coopRequestedAmount'){ // Defect: 4179 (German UAT)
                                item.isDirtyRow = true;
                                if($scope.updateCoopReasonVal){
                                    item.nrCoopAmount = $scope.updateRowsFieldVal;
                                    $scope.validateFormatOnChange(item, 'nrCoopAmount');
                                }else{
                                    item.nrCoopAmount = 0;
                                }
                            }else{
                                $scope.addPageMessage($Label.enterValueToUpdateMsg, 'error');
                            }
                        } else {
                            $scope.addPageMessage(null, null);
                            if($scope.updateRowsField[0].value == 'initialQuantity' && $scope.updateRowsFieldVal && !item.isManuallySchedule) {
                                item.isDirtyRow = true;
                                item.initialQuantity = parseInt($scope.updateRowsFieldVal);
                                if ($scope.currentTab == 'wb-tab-RentalDetails') {
                                    $scope.validateFormatOnChange(item, 'initialQuantityJapan');
                                } else {
                                    $scope.validateFormatOnChange(item, 'initialQuantity');
                                }
                                $scope.handleEstimatedPriceChange(item, 'initialQuantityChange');
                            }else if($scope.updateRowsField[0].value == 'initialBackOrderQuantity' && $scope.updateRowsFieldVal && !item.isManuallySchedule && $scope.isJapanForSellThrough) {
                                item.isDirtyRow = true;
                                item.initialBackOrderQuantity = parseInt($scope.updateRowsFieldVal);
                                $scope.validateFormatOnChange(item, 'initialBackOrderQuantity');
                                $scope.handleEstimatedPriceChange(item, 'initialQuantityChange');
                            } 
                            /*else if($scope.updateRowsField[0].value == 'discount' && $scope.updateRowsFieldVal) {
                                if(item.accountPrice) {
                                    item.isDirtyRow = true;
                                    item.discount = parseInt($scope.updateRowsFieldVal);
                                    item.promotedPrice = item.accountPrice * (1 - (item.discount / 100));
                                    item.promotedPrice = +(item.promotedPrice.toFixed(2));
                                }
                            }*/ else if ($scope.updateRowsField[0].value == 'promotedPriceByPercent' && $scope.updateRowsFieldVal) {
                                item.isDirtyRow = true;
                                if ($scope.isJapanTerritory) {
                                    item.discount = parseInt($scope.updateRowsFieldVal);
                                } else {
                                    item.discount = +($scope.updateRowsFieldVal.toFixed(2));
                                }
                                item.promotedPrice = item.accountPrice * (1 - (item.discount / 100));
                                //item.promotedPrice = +(item.promotedPrice.toFixed(2));
                                if ($scope.isJapanTerritory) {
                                    item.promotedPrice = Math.round(item.promotedPrice);
                                } else {
                                    item.promotedPrice = +(item.promotedPrice.toFixed(2));
                                }
                                $scope.validateFormatOnChange(item, 'promotedPrice');
                                $scope.handleEstimatedPriceChange(item, 'promoPriceChange');
                            } else if ($scope.updateRowsField[0].value == 'replenQuantity' && $scope.updateRowsFieldVal && !item.isManuallySchedule) {
                                item.isDirtyRow = true;
                                item.replenQuantity = parseInt($scope.updateRowsFieldVal);
                                if($scope.isDigitalDeal){
                                    $scope.validateFormatOnChange(item, 'replenQuantityD');
                                } else {
                                    $scope.validateFormatOnChange(item, 'replenQuantityP');
                                }
                                $scope.handleEstimatedPriceChange(item, 'quantityChange');
                            }else if ($scope.updateRowsField[0].value == 'replenDelayDays' && $scope.updateRowsFieldVal && !item.isManuallySchedule) {
                                //US#605 Adding replen delay days
                                item.isDirtyRow = true;
                                item.replenDelayDays = parseInt($scope.updateRowsFieldVal);
                                //$scope.handleEstimatedPriceChange(item, 'quantityChange');
                            } else if ($scope.isConsignmentCustomer && $scope.updateRowsField[0].value == 'plQuantity' && $scope.updateRowsFieldVal && !item.isManuallySchedule) {
                                item.isDirtyRow = true;
                                item.plQuantity = parseInt($scope.updateRowsFieldVal);
                                $scope.validateFormatOnChange(item, 'plQuantity');
                            } else if($scope.updateRowsField[0].value == 'promotedPrice' && $scope.updateRowsFieldVal && item.accountPrice > 0){
                                item.isDirtyRow = true;
                                item.promotedPrice = $scope.updateRowsFieldVal; //parseFloat($scope.updateRowsFieldVal);
                                item.discount = (1 - (item.promotedPrice/item.accountPrice))*100;
                                if ($scope.isJapanTerritory) {
                                    item.discount = parseInt(item.discount);
                                } else {
                                    item.discount = +(item.discount.toFixed(2));
                                }
                                $scope.validateFormatOnChange(item, 'promotedPrice');
                                $scope.handleEstimatedPriceChange(item, 'promoPriceChange');
                            } else if ($scope.updateRowsField[0].value == 'merchandising' && $scope.updateRowsFieldVal) { //US#605 Starts

                                item.isDirtyRow = true;
                                item.merchandising = parseFloat($scope.updateRowsFieldVal);
                                $scope.validateFormatOnChange(item, 'merchandising');
                                $scope.setOverrideCostsFlag(item);
                            } else if ($scope.updateRowsField[0].value == 'distributionCost' && $scope.updateRowsFieldVal) {
                                item.isDirtyRow = true;
                                item.distributionCost = parseFloat($scope.updateRowsFieldVal);
                                $scope.validateFormatOnChange(item, 'distributionCost');
                                $scope.setOverrideCostsFlag(item);
                            } else if ($scope.updateRowsField[0].value == 'returnCost' && $scope.updateRowsFieldVal && $scope.isJapanTerritory) {
                                item.isDirtyRow = true;
                                item.returnCost = parseFloat($scope.updateRowsFieldVal);
                                $scope.validateFormatOnChange(item, 'returnCost');
                                $scope.setOverrideCostsFlag(item);
                            } else if ($scope.updateRowsField[0].value == 'productionCost' && $scope.updateRowsFieldVal) {
                                item.isDirtyRow = true;
                                item.productionCost = parseFloat($scope.updateRowsFieldVal);
                                $scope.validateFormatOnChange(item, 'productionCost');
                                $scope.setOverrideCostsFlag(item);
                            } else if ($scope.updateRowsField[0].value == 'royalFeeFixed' && $scope.updateRowsFieldVal) {
                                item.isDirtyRow = true;
                                item.royalFeeFixed = parseFloat($scope.updateRowsFieldVal);
                                $scope.validateFormatOnChange(item, 'royalFeeFixed');
                                $scope.setOverrideCostsFlag(item);
                            } else if ($scope.updateRowsField[0].value == 'masterNegative' && $scope.updateRowsFieldVal) {
                                item.isDirtyRow = true;
                                item.masterNegative = parseFloat($scope.updateRowsFieldVal);
                                $scope.validateFormatOnChange(item, 'masterNegative');
                                $scope.setOverrideCostsFlag(item);
                            }else if ($scope.updateRowsField[0].value == 'salesAllowance' && $scope.updateRowsFieldVal) {
                                item.isDirtyRow = true;
                                item.salesAllowance = parseFloat($scope.updateRowsFieldVal);
                                $scope.validateFormatOnChange(item, 'salesAllowance');
                                $scope.setOverrideCostsFlag(item);
                            }else if ($scope.updateRowsField[0].value == 'returns' && $scope.updateRowsFieldVal) {
                                item.isDirtyRow = true;
                                item.returns = parseFloat($scope.updateRowsFieldVal);
                                $scope.validateFormatOnChange(item, 'returns');
                                $scope.setOverrideCostsFlag(item);
                            }else if($scope.updateRowsField[0].value == 'pap' && $scope.updateRowsFieldVal) {
                                    item.isDirtyRow = true;
                                    item.pap = parseFloat($scope.updateRowsFieldVal);
                                    $scope.validateFormatOnChange(item, 'pap');
                                    $scope.setOverrideCostsFlag(item);
                            }else if ($scope.isGerman){
                                if ($scope.updateRowsField[0].value == 'gema' && $scope.updateRowsFieldVal) {
                                    item.isDirtyRow = true;
                                    item.gema = parseFloat($scope.updateRowsFieldVal);
                                    $scope.validateFormatOnChange(item, 'gema');
                                    $scope.setOverrideCostsFlag(item);
                                }else if ($scope.updateRowsField[0].value == 'grossReceiptTaxesFFA' && $scope.updateRowsFieldVal) {
                                    item.isDirtyRow = true;
                                    item.grossReceiptTaxesFFA = parseFloat($scope.updateRowsFieldVal);
                                    $scope.validateFormatOnChange(item, 'grossReceiptTaxesFFA');
                                    $scope.setOverrideCostsFlag(item);
                                }else if ($scope.updateRowsField[0].value == 'doubtfulAccounts' && $scope.updateRowsFieldVal) {
                                    item.isDirtyRow = true;
                                    item.doubtfulAccounts = parseFloat($scope.updateRowsFieldVal);
                                    $scope.validateFormatOnChange(item, 'doubtfulAccounts');
                                    $scope.setOverrideCostsFlag(item);
                                }else if ($scope.updateRowsField[0].value == 'cashDiscounts' && $scope.updateRowsFieldVal) {
                                    item.isDirtyRow = true;
                                    item.cashDiscounts = parseFloat($scope.updateRowsFieldVal);
                                    $scope.validateFormatOnChange(item, 'cashDiscounts');
                                    $scope.setOverrideCostsFlag(item);
                                } //US#605 Ends
                                else if($scope.updateRowsField[0].value == 'coopRequestedAmount' && $scope.updateRowsFieldVal){
                                    item.isDirtyRow = true;
                                    item.nrCoopAmount = $scope.updateRowsFieldVal;
                                    $scope.validateFormatOnChange(item, 'nrCoopAmount');
                                }else if($scope.updateRowsField[0].value == 'coopReason'){
                                    if($scope.updateCoopReasonVal){
                                        item.isDirtyRow = true;
                                        item.coopReason = $scope.updateCoopReasonVal;
                                    }else {
                                        $scope.addPageMessage($Label.enterValueToUpdateMsg, 'error');
                                    }
                                }else if($scope.updateRowsField[0].value == 'priceTier' && $scope.updatePriceTierVal){
                                    if(item.lstPriceTier.includes($scope.updatePriceTierVal)){ 
                                    //US#172 DEF#4454
                                        item.isDirtyRow = true; 
                                        item.priceTier = $scope.updatePriceTierVal;
                                    }
                                }
                               //US#605 Ends
                            }else if($scope.updateRowsField[0].value == 'priceTier' && $scope.updatePriceTierVal){
                             //US#172
                                if(item.lstPriceTier.includes($scope.updatePriceTierVal)){ 
                                    item.isDirtyRow = true;
                                    item.priceTier = $scope.updatePriceTierVal;
                                }
                            }else if ($scope.isJapanDeal) {
                                if (item.overrideRentalPrices == null || item.overrideRentalPrices == false || item.overrideRentalPrices == undefined) {
                                    $scope.addPageMessage($Label.setOverridePricingToChangeRentalPricing, 'error');
                                } else if (item.overrideRentalPrices == true) {
                                    if ($scope.updateRowsField[0].value == 'handlingFee' && $scope.updateRowsFieldVal) {
                                        item.isDirtyRow = true;
                                        item.handlingFee = parseInt($scope.updateRowsFieldVal);
                                    $scope.validateFormatOnChange(item, 'handlingFee');
                                    } else if ($scope.updateRowsField[0].value == 'rentalPrice' && $scope.updateRowsFieldVal) {
                                        item.isDirtyRow = true;
                                        item.rentalPrice = parseInt($scope.updateRowsFieldVal);
                                    $scope.validateFormatOnChange(item, 'rentalPrice');
                                    } else if ($scope.updateRowsField[0].value == 'revenueShare' && $scope.updateRowsFieldVal) {
                                        item.isDirtyRow = true;
                                        item.revenueShare = parseInt($scope.updateRowsFieldVal);
                                    $scope.validateFormatOnChange(item, 'revenueShare');
                                    } else if ($scope.updateRowsField[0].value == 'numberOfRentals' && $scope.updateRowsFieldVal) {
                                        item.isDirtyRow = true;
                                        item.numberOfRentals = parseInt($scope.updateRowsFieldVal);
                                    $scope.validateFormatOnChange(item, 'numberOfRentals');
                                    } else if ($scope.updateRowsField[0].value == 'finalPurchasePrice' && $scope.updateRowsFieldVal) {
                                        item.isDirtyRow = true;
                                        item.finalPurchasePrice = parseInt($scope.updateRowsFieldVal);
                                    $scope.validateFormatOnChange(item, 'finalPurchasePrice');
                                    } else if ($scope.updateRowsField[0].value == 'finalPurchase' && $scope.updateRowsFieldVal) {
                                        item.isDirtyRow = true;
                                        item.finalPurchase = parseInt($scope.updateRowsFieldVal);
                                    $scope.validateFormatOnChange(item, 'finalPurchase');
                                    }
                                }
                            }
                        }
                    } else {
                        $scope.addPageMessage($Label.selectFieldToUpdateMsg, 'error');
                    }
                }
            });
    
            // If any row is not selected to update the selected records then show a message
            if (!isAnyRowSelected) {
                $scope.addPageMessage($Label.selectRecordForAnyOperationMsg, 'error');
            }
        };
        
        //US#575 //DEF#4368
        $scope.reverseCheck;
        $scope.selectAllRecords = function(revcheck){ 
            var isAnyRowSelected = false;
            var arrSelectAll = ($scope.filteredArray === undefined || $scope.filteredArray === null || $scope.filteredArray === '') ? $scope.lineItems :$scope.filteredArray;
            $scope.reverseCheck =  ($scope.reverseCheck === undefined || $scope.reverseCheck === null || $scope.reverseCheck === false) ? revcheck :false;
               
          /*  angular.forEach(arrSelectAll, function(item, i) {
                 if(( $scope.reverseCheck)) {
                    isAnyRowSelected = true;
                    item.isDirtyRow = true;
                    item.isSelected =true;
                } else {
                    isAnyRowSelected = false;
                    item.isDirtyRow = false; 
                    item.isSelected =false;
                }
             });  */
            for(var i = $scope.pagination.page * $scope.pagination.perPage; (i < (($scope.pagination.page * $scope.pagination.perPage) + $scope.pagination.perPage) && i < $scope.filteredlineItems.length); i++){
               if($scope.reverseCheck){ 
                    isAnyRowSelected = true;
                    arrSelectAll[i].isDirtyRow = true;
                    arrSelectAll[i].isSelected =true;
                }else {
                    isAnyRowSelected = false;
                    arrSelectAll[i].isDirtyRow = false; 
                    arrSelectAll[i].isSelected =false;
                }}
             console.log('arrSelectAll************'+$scope.filteredArray+'/////////////////'+arrSelectAll.length);
        }
        
        
        
        // US#605 Set OverrideCost flag if any of the Cost tab field are updated.
          
         $scope.setOverrideCostsFlag = function(lineItem){

            if(lineItem.overrideCOP == null || lineItem.overrideCOP == false || lineItem.overrideCOP == undefined)
                {
                   lineItem.isDirtyRow = true;
                   lineItem.overrideCOP =true;
                   
                }
             
         }
        // Method to delete all selected records
        $scope.deleteAllRows = function(){
            var isAnyRowSelected = false;
            angular.forEach($scope.lineItems, function(item, i) {
                if(item.isSelected) {
                    item.isDirtyRow = true;
                    item.totalQty = 0;
                    isAnyRowSelected = true;
                }
            });
    
            // If no rows are selected add a message to select any record else delete the records
            if (isAnyRowSelected) {
                $scope.addPageMessage(null, null);
                $scope.deleteData(true);
            } else {
                $scope.addPageMessage($Label.selectRecordForAnyOperationMsg, 'error');
            }
        };
    
        // Method to copy suggested Replen into Replen Quantity only if Suggested Replen is a positive value
        $scope.copySelectedPriceRows = function(){
            var isAnyRowSelected = false;
    
            angular.forEach($scope.lineItems, function(item, i) {
                if(item.isSelected) {
                    isAnyRowSelected = true;
                    var suggestedReplen = undefined;
                    if($scope.isJapanForSellThrough && item.initialBackOrderQuantity != undefined) {
                        if (item.initialQuantity == undefined && item.targetUnit != undefined) {
                            suggestedReplen = item.targetUnit - item.initialBackOrderQuantity;
                        } else if (item.initialQuantity != undefined && item.targetUnit != undefined){
                            suggestedReplen = item.targetUnit - (parseInt(item.initialQuantity) + parseInt(item.initialBackOrderQuantity));
                        }
                    } else {
                        if (item.initialQuantity == undefined && item.targetUnit != undefined){
                            suggestedReplen = item.targetUnit;
                        } else if (item.initialQuantity != undefined && item.targetUnit != undefined){
                            suggestedReplen = item.targetUnit - item.initialQuantity;
                        }
                    }
    
                    if(suggestedReplen != undefined && suggestedReplen > 0 && !item.isManuallySchedule){
                        item.isDirtyRow = true;
                        item.replenQuantity = suggestedReplen;
                        if($scope.isDigitalDeal){
                            $scope.validateFormatOnChange(item, 'replenQuantityD');
                        } else {
                            $scope.validateFormatOnChange(item, 'replenQuantityP');
                        }
                        $scope.handleEstimatedPriceChange(item, 'quantityChange');
                        if (item.replenDelayDays == null || item.replenDelayDays == undefined || isNaN(item.replenDelayDays)) {
                            item.replenDelayDays = 7;
                        }
                    }
                }
            });
    
            // If any row is not selected to update the selected records then show a message
            if (!isAnyRowSelected) {
                $scope.addPageMessage($Label.selectRecordForAnyOperationMsg, 'error');
            } else {
                // Clear the error if valid record set after invoking the error message
                $scope.addPageMessage(null, null);
            }
        };
    
        // Method to calculate suggested Replen
        $scope.calculateSuggestedReplen = function(item){
            if($scope.isJapanForSellThrough && item.initialBackOrderQuantity != undefined) {
                if (item.initialQuantity == undefined && item.targetUnit != undefined) {
                    item.suggestedPrice = item.targetUnit - item.initialBackOrderQuantity;
                } else if (item.initialQuantity != undefined && item.targetUnit != undefined){
                    item.suggestedPrice = item.targetUnit - (parseInt(item.initialQuantity) + parseInt(item.initialBackOrderQuantity));
                }
            } else {
                if (item.initialQuantity == undefined && item.targetUnit != undefined){
                    item.suggestedPrice = item.targetUnit;
                } else if (item.initialQuantity != undefined && item.targetUnit != undefined){
                    item.suggestedPrice = item.targetUnit - item.initialQuantity;
                }
            }
        };
    
        /*$scope.setDefaultValue = function(lineItem, changeField){
            if (changeField == 'Initial_Quantity' && lineItem.initialQuantity == null) {
                lineItem.initialQuantity = 0;
                console.log('--lineItem.initialQuantity-->'+lineItem.initialQuantity);
            } else if (changeField == 'Replen_Quantity' &&  lineItem.replenQuantity == null) {
                lineItem.replenQuantity = 0;
                console.log('--lineItem.replenQuantity-->'+lineItem.replenQuantity);
            } else if (changeField == 'Initial_Back_Order_Quantity' &&  lineItem.initialBackOrderQuantity == null) {
                lineItem.initialBackOrderQuantity = 0;
                console.log('--lineItem.initialBackOrderQuantity-->'+lineItem.initialBackOrderQuantity);
            }
        };*/
    
        $scope.checkUncheckAll = function() {
            /*angular.forEach($filter('filter')($scope.lineItems, $scope.search.text), function(item, i) {
            item.isSelected = $scope.isMasterChecked;
        });*/

        for(var i = $scope.pagination.page * $scope.pagination.perPage; (i < (($scope.pagination.page * $scope.pagination.perPage) + $scope.pagination.perPage) && i < $scope.filteredlineItems.length); i++){
            //item.isSelected = $scope.isMasterChecked;
            $scope.filteredlineItems[i].isSelected = $scope.isMasterChecked;
        }
    };
    
        // Function to calculate Discount and Promoted Price on Plan Tab
        $scope.handlePriceChange = function(lineItem, changeType){
            if(lineItem.accountPrice) {
                lineItem.isDirtyRow = true;
                if (changeType == 'promoPriceChange' && !isNaN(lineItem.promotedPrice)) {
                    lineItem.discount = (1 - (lineItem.promotedPrice/lineItem.accountPrice))*100;
                    //lineItem.discount = +(lineItem.discount.toFixed(2));
                    if ($scope.isJapanTerritory) {
                        lineItem.discount = Math.round(lineItem.discount);
                    } else {
                        lineItem.discount = +(lineItem.discount.toFixed(2));
                    }
                }/* else if (changeType == 'discountChange') {
                    lineItem.promotedPrice = lineItem.accountPrice * (1 - (lineItem.discount / 100));
                    lineItem.promotedPrice = +(lineItem.promotedPrice.toFixed(2));
                }*/
            } else {
                //lineItem.promotedPrice = 0; Commented for DEF:4437 unable to update promoted price on edit all page when account price is 0
                lineItem.discount = 0;
            }
        };
    
        // Function to calculate Estimated Revenue (totalPrice)
        $scope.handleEstimatedPriceChange = function(lineItem, changeType){
            lineItem.isDirtyRow = true;
            if (changeType == 'promoPriceChange') {
                if (!isNaN(lineItem.promotedPrice)) {
                    if ($scope.isDigitalDeal) {
                        if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0) {
                            lineItem.totalPrice = lineItem.promotedPrice * lineItem.replenQuantity;
                            lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                        } else {
                            lineItem.totalPrice = 0;
                        }
                        if ($scope.isJapanTerritory) {
                            lineItem.totalPrice = Math.round(lineItem.totalPrice);
                        }
                    }else{
                        if($scope.isJapanForSellThrough && lineItem.initialBackOrderQuantity != null &&  lineItem.initialBackOrderQuantity != undefined && !isNaN(lineItem.initialBackOrderQuantity)){
                            if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0
                                && lineItem.initialQuantity != null && lineItem.initialQuantity != undefined && !isNaN(lineItem.initialQuantity) && lineItem.initialQuantity > 0
                            ) {
                                lineItem.totalPrice = lineItem.promotedPrice * (parseInt(lineItem.initialBackOrderQuantity) + parseInt(lineItem.replenQuantity) + parseInt(lineItem.initialQuantity));
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            } else if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0) {
                                lineItem.totalPrice = lineItem.promotedPrice * (parseInt(lineItem.replenQuantity) + parseInt(lineItem.initialBackOrderQuantity));
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            } else if (lineItem.initialQuantity != null && lineItem.initialQuantity != undefined && !isNaN(lineItem.initialQuantity) && lineItem.initialQuantity > 0) {
                                lineItem.totalPrice = lineItem.promotedPrice * (parseInt(lineItem.initialQuantity) + parseInt(lineItem.initialBackOrderQuantity));
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            } else {
                                lineItem.totalPrice = lineItem.promotedPrice * lineItem.initialBackOrderQuantity;
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            }
                        }else{
                            if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0
                                && lineItem.initialQuantity != null && lineItem.initialQuantity != undefined && !isNaN(lineItem.initialQuantity) && lineItem.initialQuantity > 0
                            ) {
                                lineItem.totalPrice = lineItem.promotedPrice * (parseInt(lineItem.replenQuantity) + parseInt(lineItem.initialQuantity));
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            } else if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0) {
                                lineItem.totalPrice = lineItem.promotedPrice * lineItem.replenQuantity;
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            } else if (lineItem.initialQuantity != null && lineItem.initialQuantity != undefined && !isNaN(lineItem.initialQuantity) && lineItem.initialQuantity > 0) {
                                lineItem.totalPrice = lineItem.promotedPrice * lineItem.initialQuantity;
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            } else {
                                lineItem.totalPrice = 0;
                            }
                        }
                    }
                    $scope.validateFormatOnChange(lineItem, 'totalPrice');
                    if ($scope.isJapanTerritory) {
                        lineItem.totalPrice = Math.round(lineItem.totalPrice);
                    }
                }
            } else if(changeType == 'initialQuantityChange') {
                if (!isNaN(lineItem.initialQuantity)) {
                    if($scope.isJapanForSellThrough && lineItem.initialBackOrderQuantity != null &&  lineItem.initialBackOrderQuantity != undefined && !isNaN(lineItem.initialBackOrderQuantity)){
                        if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0
                            && lineItem.initialQuantity != null && lineItem.initialQuantity != undefined && !isNaN(lineItem.initialQuantity) && lineItem.initialQuantity > 0
                        ) {
                            lineItem.totalPrice = lineItem.promotedPrice * (parseInt(lineItem.replenQuantity) + parseInt(lineItem.initialQuantity) + parseInt(lineItem.initialBackOrderQuantity));
                            lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                        } else if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0) {
                            lineItem.totalPrice = lineItem.promotedPrice * (parseInt(lineItem.replenQuantity) + parseInt(lineItem.initialBackOrderQuantity));
                            lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                        } else if (lineItem.initialQuantity != null && lineItem.initialQuantity != undefined && !isNaN(lineItem.initialQuantity) && lineItem.initialQuantity > 0) {
                            lineItem.totalPrice = lineItem.promotedPrice *(parseInt(lineItem.initialQuantity) + parseInt(lineItem.initialBackOrderQuantity));
                            lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                        } else {
                            lineItem.totalPrice = lineItem.promotedPrice * lineItem.initialBackOrderQuantity;
                            lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                        }
                    } else{
                        if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0
                            && lineItem.initialQuantity != null && lineItem.initialQuantity != undefined && !isNaN(lineItem.initialQuantity) && lineItem.initialQuantity > 0
                        ) {
                            lineItem.totalPrice = lineItem.promotedPrice * (parseInt(lineItem.replenQuantity) + parseInt(lineItem.initialQuantity));
                            lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                        } else if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0) {
                            lineItem.totalPrice = lineItem.promotedPrice * lineItem.replenQuantity;
                            lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                        } else if (lineItem.initialQuantity != null && lineItem.initialQuantity != undefined && !isNaN(lineItem.initialQuantity) && lineItem.initialQuantity > 0) {
                            lineItem.totalPrice = lineItem.promotedPrice * lineItem.initialQuantity;
                            lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                        } else {
                            lineItem.totalPrice = 0;
                        }
                    }
                    $scope.validateFormatOnChange(lineItem, 'totalPrice');
                    if ($scope.isJapanTerritory) {
                        lineItem.totalPrice = Math.round(lineItem.totalPrice);
                    }
                }
            } else if(changeType == 'quantityChange') { 
                if (!isNaN(lineItem.replenQuantity)) {
                    if ($scope.isDigitalDeal) {
                        lineItem.replenDelayDays = 0;
                        if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0) {
                            lineItem.totalPrice = lineItem.promotedPrice * lineItem.replenQuantity;
                            lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                        }
                    } else {
                        if($scope.isJapanForSellThrough && lineItem.initialBackOrderQuantity != null &&  lineItem.initialBackOrderQuantity != undefined && !isNaN(lineItem.initialBackOrderQuantity)){
                            if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0
                                && lineItem.initialQuantity != null && lineItem.initialQuantity != undefined && !isNaN(lineItem.initialQuantity) && lineItem.initialQuantity > 0
                            ) {
                                lineItem.totalPrice = lineItem.promotedPrice * (parseInt(lineItem.replenQuantity) + parseInt(lineItem.initialQuantity) + parseInt(lineItem.initialBackOrderQuantity));
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            } else if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0) {
                                lineItem.totalPrice = lineItem.promotedPrice * (parseInt(lineItem.replenQuantity) + parseInt(lineItem.initialBackOrderQuantity));
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            } else if (lineItem.initialQuantity != null && lineItem.initialQuantity != undefined && !isNaN(lineItem.initialQuantity) && lineItem.initialQuantity > 0) {
                                lineItem.totalPrice = lineItem.promotedPrice * (parseInt(lineItem.initialQuantity) + parseInt(lineItem.initialBackOrderQuantity));
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            } else {
                                lineItem.totalPrice = lineItem.promotedPrice * lineItem.initialBackOrderQuantity;
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            }
                        }else{
                            if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0
                                && lineItem.initialQuantity != null && lineItem.initialQuantity != undefined && !isNaN(lineItem.initialQuantity) && lineItem.initialQuantity > 0
                            ) {
                                lineItem.totalPrice = lineItem.promotedPrice * (parseInt(lineItem.replenQuantity) + parseInt(lineItem.initialQuantity));
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            } else if (lineItem.replenQuantity != null && lineItem.replenQuantity != undefined && !isNaN(lineItem.replenQuantity) && lineItem.replenQuantity > 0) {
                                lineItem.totalPrice = lineItem.promotedPrice * lineItem.replenQuantity;
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            } else if (lineItem.initialQuantity != null && lineItem.initialQuantity != undefined && !isNaN(lineItem.initialQuantity) && lineItem.initialQuantity > 0) {
                                lineItem.totalPrice = lineItem.promotedPrice * lineItem.initialQuantity;
                                lineItem.totalPrice = parseFloat(lineItem.totalPrice).toFixed(2);
                            } else {
                                lineItem.totalPrice = 0;
                            } 
                        }
                        /*if (lineItem.replenQuantity == null || lineItem.replenQuantity == undefined || isNaN(lineItem.replenQuantity) || lineItem.replenQuantity <= 0) {
                            lineItem.replenDelayDays = undefined;
                        } else {*/
                            if (lineItem.replenDelayDays == null || lineItem.replenDelayDays == undefined || isNaN(lineItem.replenDelayDays)) {
                                lineItem.replenDelayDays = 7;
                            }
                        //}
                    }
                    $scope.validateFormatOnChange(lineItem, 'totalPrice');
                    if ($scope.isJapanTerritory) {
                        lineItem.totalPrice = Math.round(lineItem.totalPrice);
                    }
                }
            } else if(changeType == 'estimatedPriceChange') {
                if (!isNaN(lineItem.totalPrice)) {
                    if ((lineItem.totalPrice != null && lineItem.totalPrice != undefined && !isNaN(lineItem.totalPrice) && lineItem.totalPrice > 0)
                        && (lineItem.promotedPrice != null && lineItem.promotedPrice != undefined && !isNaN(lineItem.promotedPrice) && lineItem.promotedPrice > 0)) {
                        if ($scope.isDigitalDeal) {
                            lineItem.replenQuantity = Math.round(lineItem.totalPrice / lineItem.promotedPrice);
                        } else {
                            if($scope.isJapanForSellThrough){
                                if (lineItem.initialQuantity == null || lineItem.initialQuantity == undefined || isNaN(lineItem.initialQuantity )){
                                    if(lineItem.initialBackOrderQuantity == null ||  lineItem.initialBackOrderQuantity == undefined || isNaN(lineItem.initialBackOrderQuantity)) 
                                    {
                                        lineItem.replenQuantity = Math.round((lineItem.totalPrice / lineItem.promotedPrice));
                                    }else{
                                        lineItem.replenQuantity = Math.round((lineItem.totalPrice / lineItem.promotedPrice) - lineItem.initialBackOrderQuantity);
                                    }  
                                }else{
                                    if(lineItem.initialBackOrderQuantity == null ||  lineItem.initialBackOrderQuantity == undefined || isNaN(lineItem.initialBackOrderQuantity)) 
                                    {
                                        lineItem.replenQuantity = Math.round((lineItem.totalPrice / lineItem.promotedPrice) - lineItem.initialQuantity );
                                    }else{
                                        lineItem.replenQuantity = Math.round((lineItem.totalPrice / lineItem.promotedPrice) - (parseInt(lineItem.initialQuantity) + parseInt(lineItem.initialBackOrderQuantity)));
                                    } 
                                }
                            }else{
                                if (lineItem.initialQuantity == null || lineItem.initialQuantity == undefined || isNaN(lineItem.initialQuantity)) {
                                    lineItem.replenQuantity = Math.round((lineItem.totalPrice / lineItem.promotedPrice));
                                } else {
                                    lineItem.replenQuantity = Math.round((lineItem.totalPrice / lineItem.promotedPrice) - lineItem.initialQuantity);
                                }
                            }
                        }
                        if ((lineItem.totalPrice != null && lineItem.totalPrice != undefined && !isNaN(lineItem.totalPrice) && lineItem.totalPrice > 0)
                        && (lineItem.estContribution != null && lineItem.estContribution != undefined && !isNaN(lineItem.estContribution) && lineItem.estContribution > 0)) {
                            lineItem.estContributionPercent = lineItem.estContribution / lineItem.totalPrice;
                        } else {
                            lineItem.estContributionPercent = 0;
                        }
                    } else {
                        if (lineItem.replenQuantity != null) {
                            lineItem.replenQuantity = 0;
                        }
                        if (lineItem.initialQuantity != null) {
                            lineItem.initialQuantity = 0;
                        }
                        if (lineItem.initialBackOrderQuantity != null) {
                            lineItem.initialBackOrderQuantity = 0;
                        }
                    }
                    if($scope.isDigitalDeal){
                        $scope.validateFormatOnChange(lineItem, 'replenQuantityD');
                    } else {
                        $scope.validateFormatOnChange(lineItem, 'replenQuantityP');
                    }
                }
    
                if ($scope.isDigitalDeal) {
                    lineItem.replenDelayDays = 0;
                } else {
                    /*if (lineItem.replenQuantity == null || lineItem.replenQuantity == undefined || isNaN(lineItem.replenQuantity) || lineItem.replenQuantity <= 0) {
                        lineItem.replenDelayDays = undefined;
                    } else {*/
                        if (lineItem.replenDelayDays == null || lineItem.replenDelayDays == undefined || isNaN(lineItem.replenDelayDays)) {
                            lineItem.replenDelayDays = 7;
                        }
                    //}
                }
            }
        };
    
        $scope.initErrorMsg = function(){
            $scope.msgText = null;
            $scope.msgSeverity = null;
        }
    

        // Function to initially load the deal products for a deal
        $scope.loadLineItems = function(){
        $.when(
                $.getJSON(subTagsLink, function(data){Globalize.load(data)} ),
                $.getJSON(numberingSystemLink, function(data){Globalize.load(data)} ),
                $.getJSON(numberLocaleLink, function(data){Globalize.load(data)} )
            ).then(function() {
                var locale = $scope.appConfig.userLocale; //'de';
                console.log('--locale->',locale);
                var de = Globalize.locale(locale);
                console.log('--Globalize.locale->',de);
          
                $scope.msgText = null;
                $scope.popUpMsgText = null;
                $scope.showSpinner = true;
                var startTime = new Date();
                //Added for La Moulinette for France
                var hasSharePercent = false;
                //Added for La Moulinette for France
                getLineItemsService($scope.appConfig.apexController, $scope.appConfig.recordId).then(
                    function(data){
                    var endTime = new Date();
                    console.log('Time Elapsed (ms) in GetLineItem is', (endTime - startTime));
                    $scope.lineItems = data; //US#598
                    $scope.allLineItems=data;    
                    //Added for Pagination

                    $scope.pagination.numPages = Math.ceil($scope.lineItems.length/$scope.pagination.perPage);

                    //Added for Pagination
                    
                    angular.forEach($scope.lineItems, function(item, i) {
                        item.coopReason = $filter('decodehtml')(item.coopReason);
                         //US#172
                        item.priceTier = $filter('decodehtml')(item.priceTier);

                        if(item.sharePercent != 0.0){
                           hasSharePercent = true;
                        }

                    });
                    $scope.showSpinner = false;

                    if(!hasSharePercent){
                        $scope.noSharePercent = true;

                    }else{
                        $scope.noSharePercent = false;

                    }
                },
                function(error){
                    console.log(error);
                    $scope.msgText = error.message;
                    $scope.msgSeverity = 'error';
                    $scope.showSpinner = false;
                });
            });
        };
    
         $scope.navigateToURL = function(url) {
            var isLightningExperienceOrSf1 = ((typeof sforce != 'undefined') && sforce && (!!sforce.one));
    
            if ($scope.isLightningExperienceOrSf1)
                if($scope.appConfig.recordType ==='Opportunity')
                    window.open('/lightning/r/Opportunity/'+$scope.appConfig.recordId+'/view?fr=1','_parent');
                else
                    sforce.one.navigateToURL(url); 
            else
                document.location.href = url;
        };
    
        // Method to set error message and its severity to display on page
        $scope.addPageMessage =  function(msg, sev) {
            $scope.msgText = msg;
            $scope.msgSeverity = sev;
        };
    
        // Method to validate the data and set proper error message for invalid data
        $scope.inValidData = function(lineItems) {
            $scope.msgText = null;
            angular.forEach(lineItems, function(item, i) {

                if ($scope.currentTab == 'wb-tab-planning') {
                    //US#663 - added price tier check
                    if ((item.promotedPrice == null || item.promotedPrice == undefined || isNaN(item.promotedPrice))
                    && (item.priceTier === null || item.priceTier === undefined || item.priceTier === '')
                    ) {
                        $scope.addPageMessage($Label.enterPromotedPriceDataMsg, 'error');
                    } 
                    /*else if (
                        $scope.isDigitalDeal &&
                        (item.replenQuantity == null || item.replenQuantity == undefined || isNaN(item.replenQuantity)) &&
                        !item.isManuallySchedule
                    ) {
                        $scope.addPageMessage($Label.enterQuantityDataMsg, 'error');
                    } else if (
                        !item.isManuallySchedule &&
                        !$scope.isDigitalDeal &&
                        (item.initialQuantity == null || item.initialQuantity == undefined || isNaN(item.initialQuantity)) &&
                        (item.replenQuantity == null || item.replenQuantity == undefined || isNaN(item.replenQuantity))
                    ) {
                        if (!$scope.isJapanForSellThrough || ($scope.isJapanForSellThrough && item.initialBackOrderQuantity == null)) {
                            $scope.addPageMessage($Label.enterPhysicalDealQuantityDataMsg, 'error');
                        }
                    } */
                    else if (
                        !item.isManuallySchedule &&
                        !$scope.isDigitalDeal &&
                        (item.decayCurveTemplateName == null || item.decayCurveTemplateName == undefined) &&
                        (item.replenDelayDays == null || item.replenDelayDays == undefined || isNaN(item.replenDelayDays))
                    ) {
                        $scope.addPageMessage($Label.enterValueForDecayCureveCalculationMsg, 'error');
                    }
                    else if (
                        (item.nrCoopAmount != null && item.nrCoopAmount != undefined && !isNaN(item.nrCoopAmount)) &&
                        (item.coopReason == null || item.coopReason == undefined || item.coopReason == '') &&
                        (item.coopComments == null || item.coopComments == undefined || item.coopComments == '')
                    ) {
                        $scope.addPageMessage($Label.enterValueForNRCoopMsg, 'error');
                    }
                }else if ($scope.currentTab == 'wb-tab-nrCoop') {
                    if (
                        (item.nrCoopAmount != null && item.nrCoopAmount != undefined && !isNaN(item.nrCoopAmount)) &&
                        (item.coopReason == null || item.coopReason == undefined || item.coopReason == '') &&
                        (item.coopComments == null || item.coopComments == undefined || item.coopComments == '')
                    ) {
                        $scope.addPageMessage($Label.enterValueForNRCoopMsg, 'error');
                    }
                    else if (item.promotedPrice == null || item.promotedPrice == undefined || isNaN(item.promotedPrice)) {
                        $scope.addPageMessage($Label.enterPromotedPriceDataMsg, 'error');
                    } 
                    /*else if (
                        $scope.isDigitalDeal &&
                        (item.replenQuantity == null || item.replenQuantity == undefined || isNaN(item.replenQuantity)) &&
                        !item.isManuallySchedule
                    ) {
                        $scope.addPageMessage($Label.enterQuantityDataMsg, 'error');
                    } else if (
                        !item.isManuallySchedule &&
                        !$scope.isDigitalDeal &&
                        (item.initialQuantity == null || item.initialQuantity == undefined || isNaN(item.initialQuantity)) &&
                        (item.replenQuantity == null || item.replenQuantity == undefined || isNaN(item.replenQuantity))
                    ) {
                        $scope.addPageMessage($Label.enterPhysicalDealQuantityDataMsg, 'error');
                    } */
                    else if (
                        !item.isManuallySchedule &&
                        !$scope.isDigitalDeal &&
                        (item.replenQuantity != null && item.replenQuantity != undefined && !isNaN(item.replenQuantity) && item.replenQuantity > 0) &&
                        (item.decayCurveTemplateName == null || item.decayCurveTemplateName == undefined) &&
                        (item.replenDelayDays == null || item.replenDelayDays == undefined || isNaN(item.replenDelayDays))
                    ) {
                        $scope.addPageMessage($Label.enterValueForDecayCureveCalculationMsg, 'error');
                    }
                } 
               /*else if ($scope.currentTab == ' wb-tab-consignment') {
                    if (
                        !item.isManuallySchedule &&
                        !$scope.isDigitalDeal &&
                        (item.initialQuantity == null || item.initialQuantity == undefined || isNaN(item.initialQuantity)) &&
                        (item.replenQuantity == null || item.replenQuantity == undefined || isNaN(item.replenQuantity))
                    ) {
                        $scope.addPageMessage($Label.enterPhysicalDealQuantityDataMsg, 'error');
                    }
                }
                else if ($scope.currentTab == 'wb-tab-RentalDetails') {
                }*/
    
                // Error should be added in all tabs of Japan Rental deal
                if ($scope.isJapanDeal) {
                    /*if (item.initialQuantity == null || item.initialQuantity == undefined || isNaN(item.initialQuantity) || item.initialQuantity == '') {
                        $scope.addPageMessage($Label.enterQuantityDataMsg, 'error');
                    } else */
                    if (item.overrideRentalPrices == true && $scope.isRevenueShareAccount == true && (item.handlingFee == null || item.handlingFee == undefined || isNaN(item.handlingFee))) {
                        $scope.addPageMessage($Label.enterRentalFieldsDataMsg, 'error');
                    } else if (item.overrideRentalPrices == true && $scope.isRevenueShareAccount == false && (item.handlingFee == null || item.handlingFee == undefined || isNaN(item.handlingFee) || item.handlingFee == 0)) {
                        $scope.addPageMessage($Label.enterValidHandlingFeeDataMsg, 'error');
                    }
    
                    if (item.overrideRentalPrices == true && $scope.isRevenueShareAccount == true) {
                        if (item.rentalPrice == null || item.rentalPrice == undefined || isNaN(item.rentalPrice) || item.rentalPrice == 0) {
                            $scope.addPageMessage($Label.enterRentalFieldsDataMsg, 'error');
                        } else if (item.revenueShare == null || item.revenueShare == undefined || isNaN(item.revenueShare) || item.revenueShare == 0) {
                            $scope.addPageMessage($Label.enterRentalFieldsDataMsg, 'error');
                        } else if (item.numberOfRentals == null || item.numberOfRentals == undefined || isNaN(item.numberOfRentals) || item.numberOfRentals == 0) {
                            $scope.addPageMessage($Label.enterRentalFieldsDataMsg, 'error');
                        } else if (item.finalPurchasePrice == null || item.finalPurchasePrice == undefined || isNaN(item.finalPurchasePrice) || item.finalPurchasePrice == 0) {
                            $scope.addPageMessage($Label.enterRentalFieldsDataMsg, 'error');
                        } else if (item.finalPurchase == null || item.finalPurchase == undefined || isNaN(item.finalPurchase) || item.finalPurchase == 0) {
                            $scope.addPageMessage($Label.enterRentalFieldsDataMsg, 'error');
                        } else if (item.decayCurveTemplateName == null || item.decayCurveTemplateName == undefined || item.decayCurveTemplateName == '') {
                            $scope.addPageMessage($Label.enterValueForDecayCurveTemplateJapanMsg, 'error');
                        }
                    }
                }
                //Internet Explorer compatibility Defect ID : 4508 Ankita
                var arrValues = Object.keys(item.inValidFormatMap).map(function(key) {return item.inValidFormatMap[key];}); 
                //Object.values(item.inValidFormatMap).length
                if ($scope.msgText == null &&  arrValues.length > 0) {
                    $scope.addPageMessage($Label.enterValidFormatForNumberFields, 'error');
                }
            });

            return $scope.msgText;
        }
        
        //Move focus to next component and add Product
        $scope.moveFocusAndAdd = function() {
            $scope.addProduct();
        }
        
    // Method to validate the input number format
    $scope.validateFormat = function(lineItem, fieldName) {
        var inputElement = document.getElementById(fieldName +'-'+lineItem.lineItemId);
        if (lineItem.inValidFormatMap[fieldName +'-'+lineItem.lineItemId]) {
            inputElement.style.borderWidth = "2px";
            inputElement.style.borderColor = 'red';
        } else {
            inputElement.style.borderWidth = null;
            inputElement.style.borderColor = null;
        }
    }
    
    $scope.validateFormatOnChange = function(lineItem, fieldName) {
        if (lineItem.inValidFormatMap[fieldName + '-' + lineItem.lineItemId]) {
            delete lineItem.inValidFormatMap[fieldName + '-' + lineItem.lineItemId];
            $scope.validateFormat(lineItem, fieldName);
        }
    }
    
    // Method to validate the inut number format
    $scope.validateCoop = function(fieldName) {
        $scope.popUpMsgText = null;
        $scope.msgSeverity = null
        var inputElement = document.getElementById(fieldName);
        if (isNaN($scope.coopRequestedDiscount)) {
            inputElement.style.borderWidth = "2px";
            inputElement.style.borderColor = 'red';
        } else {
            inputElement.style.borderWidth = null;
            inputElement.style.borderColor = null;
        }
    }
 
        // Method to validate the data and set proper error message for invalid data
        $scope.inValidMaterialNumber = function(search) {
            $scope.msgText = null;
            if (search.materialNumber == null || search.materialNumber == undefined || isNaN(search.materialNumber) || search.materialNumber == 0) {
                      $scope.addPageMessage($Label.enterMaterialNumberDataMsg , 'error');
            }

            return $scope.msgText;
         }
        // Bind the add Product function to the SFDC controller to commit the records
        $scope.addProduct = function() {
            $scope.msgText = null;
            $scope.showSpinner = true;

            if (!$scope.inValidMaterialNumber($scope.search)) {
            addLineItemsService($scope.appConfig.apexController, $scope.appConfig.recordId, $scope.search)
              .then(function(data) {
                  $scope.lineItems = data;
                  $scope.showSpinner = false;
                  $scope.search.materialNumber = null;
              },
              function(data){
                  $scope.addPageMessage(data.message, 'error');
                  $scope.showSpinner = false;
                  $scope.search.materialNumber = null;
              });
            }else {
                $scope.showSpinner = false;
                $scope.search.materialNumber = null;
            }
       };
    
        // Bind the save function to the SFDC controller to commit the records
        $scope.saveData = function(qSave) {
            $scope.msgText = null;
            $scope.showSpinner = true;
            $scope.quickSave = qSave;
            $scope.spinnerText ='';
        var cleanedGridData = [];
        var lineItemRecords = [];
            if (!$scope.inValidData($scope.lineItems)) {
                var bSaveLineItem = true;
                if($scope.isFrance || $scope.isGerman){
                    updateDealService($scope.appConfig.apexController, $scope.appConfig.recordId, $scope.highLevelForecast)
                    .then(function() {
                        bSaveLineItem = true;
                    },
                    function(data){
                        bSaveLineItem = false;
                        $scope.addPageMessage(data.message, 'error');
                        $scope.showSpinner = false;
                        $scope.spinnerText = '';
                    });
                }
                if(bSaveLineItem){
                cleanedGridData = $scope.lineItems;
                lineItemRecords = angular.copy($scope.lineItems);

                (function runSaveToSalesforce(rowsToProcess, returnedResults, failedRecCount) {
                    console.log(rowsToProcess.length, returnedResults.length);

                    if (typeof rowsToProcess == 'undefined' || rowsToProcess.length == 0) {
                        $scope.showSpinner = false;
                        return;
                    }                
                    var chunkSize = 100, // Recursive batch size
                    chunkedData = rowsToProcess.splice(0, chunkSize);
                    console.log('---chunkedData-->',chunkedData.length);
                    
                    saveLineItemsService($scope.appConfig.apexController, $scope.appConfig.recordId,chunkedData, $scope.quickSave)
                    .then(function(data) {

                        if (cleanedGridData.length > 0) {
                            returnedResults = returnedResults.concat(data);
                            angular.forEach(data, function(item, i) {
                                item.coopReason = $filter('decodehtml')(item.coopReason);
                                 //US#172
                                item.priceTier = $filter('decodehtml')(item.priceTier); 
                            });
                            
                            $scope.spinnerText =returnedResults.length + ' / ' + (rowsToProcess.length + returnedResults.length);
                            
                            runSaveToSalesforce(rowsToProcess, returnedResults, failedRecCount);
                        }else{
                             //console.log('--data final -----> : ',data.length);
                             $scope.lineItems = returnedResults.concat(data);
                             console.log('-----$scope.lineItems --------------- :',$scope.lineItems.length);
                        if (qSave) {
                            angular.forEach($scope.lineItems, function(item, i) {
                                item.coopReason = $filter('decodehtml')(item.coopReason);
                                 //US#172
                                item.priceTier = $filter('decodehtml')(item.priceTier); 
                            }); 
                             $scope.addPageMessage($Label.updateSuccessMsg, 'success');
                             $scope.showSpinner = false;
                        } else {
                            $scope.navigateToURL(appConfig.onSaveSuccessUrl);
                        }
                        }
                    },
                    function(data){
                        console.log('lineItemRecords records reuturned -----------',lineItemRecords);
                        $scope.lineItems = lineItemRecords;
                        $scope.addPageMessage(data.message, 'error');
                        $scope.showSpinner = false;
                        $scope.spinnerText = '';
                    });
                })(cleanedGridData,[],0);
                }
            } else {
                $scope.showSpinner = false;
            }
        };
    
        // Bind the delete records to save function of SFDC controller to delete the records and show deleted message after successful delete
        $scope.deleteData = function(qDelete) {
            $scope.msgText = null;
            $scope.showSpinner = true;
            saveLineItemsService($scope.appConfig.apexController, $scope.appConfig.recordId, $scope.lineItems, true)
                .then(function(data) {
                $scope.lineItems = data;
                if (qDelete) {
                    $scope.addPageMessage($Label.delectSuccessMsg, 'success');
                    $scope.showSpinner = false;
                }
            },
            function(data){
              $scope.addPageMessage(data.message, 'error');
              $scope.showSpinner = false;
            }
          );
        };
    
        // Method to display ProductMoreInfo in a popup
        $scope.showMoreInfoPopup = function(prodLi) {
            $scope.moreInfoProduct = prodLi;
            $scope.moreInfoProductUrl = '/apex/CRM_ProductMoreinfo?dealOrOrderId='+ prodLi.dealOrOrderId +'&priceBookEntryID='+prodLi.pricebookEntryId;
        };
    
        // Method to hide ProductMoreInfo popup
        $scope.hideMoreInfoPopup = function() {
            $scope.moreInfoProduct = null;
            $scope.moreInfoProductUrl = null;
        };
    
        // Method to open Edit Schedule / Establish Schedule in a new tab
        $scope.showEditSchedulesPopup = function(prodLi) {
            var editSchedulesPageUrl;
    
            if (prodLi.scheduleEnabled) {
                editSchedulesPageUrl = '/oppitm/scheduleedit.jsp?id=' + prodLi.lineItemId;
            } else {
                editSchedulesPageUrl = '/oppitm/establishschedule.jsp?id=' + prodLi.lineItemId;
            }
    
            if (editSchedulesPageUrl) {
                window.open(editSchedulesPageUrl, '_blank');
                //$scope.moreInfoProduct = prodLi;
                //$scope.moreInfoProductUrl = editSchedulesPageUrl;
            }
        };
    })
        .factory("addLineItemsService", ['$q', '$rootScope', function($q, $rootScope) {
          return function(apexController, recordId, search) {
                var deferred = $q.defer();
                // Save the products to the salesforce controller
                apexController.addLineItems(recordId, search,
                    function(result, event) {
                        $rootScope.$apply(function() {
                          if (event.status) {
                            deferred.resolve(result);
                          } else {
                            deferred.reject(event);
                          }
                        })
                    }
                );
                return deferred.promise;
            }
        }])
        .factory("getLineItemsService", ['$q', '$rootScope', function($q, $rootScope) {
            return function(apexController, opportunityId, priceBookId) {
                var deferred = $q.defer();
                // Load the products from the salesforce controller
            apexController.getLineItems(opportunityId,null,
                    function(result, event) {
                        $rootScope.$apply(function() {
                            if (event.status) {
                                deferred.resolve(result);
                            } else {
                                deferred.reject(event);
                            }
                        });
                    }
                );
    
                return deferred.promise;
            }
        }])
        .factory("updateDealService", ['$q', '$rootScope', function($q, $rootScope) {
            return function(apexController, opportunityId, highLevelForecast) {
                var deferred = $q.defer();
                // Load the products from the salesforce controller
                apexController.updateDeal(opportunityId, highLevelForecast,
                    function(result, event) {
                        $rootScope.$apply(function() {
                            if (event.status) {
                                deferred.resolve(result);
                            } else {
                                deferred.reject(event);
                            }
                        });
                    }
                );
    
                return deferred.promise;
            }
        }])
        .factory("saveLineItemsService", ['$q', '$rootScope', function($q, $rootScope) {
            return function(apexController, recordId, lineItems, quickSave) {
                var deferred = $q.defer(); 
    
                var selectedLineItems = $.grep(lineItems, function(x){
                    if(x.scheduleEnabled == null){
                        x.scheduleEnabled = false;
                    }
                //console.log('--x value --> :',x);
                //return (x.isDirtyRow == true);
                return x;
                });
    
                // Rip the two fields that are needed
                var lineItemsSave = $.map(selectedLineItems, function(x) {
                    //var coopReasonList = [{"label": x.coopReason.label, "value":x.coopReason.value, "selected": x.coopReason.selected}];
                    return {
                        targetUnit: x.targetUnit,
                        initialQuantity: x.initialQuantity,
                        initialBackOrderQuantity: x.initialBackOrderQuantity,
                        isManuallySchedule: x.isManuallySchedule,
                        replenDelayDays: x.replenDelayDays,
                        replenQuantity: x.replenQuantity,
                        decayCurveTemplate: x.decayCurveTemplate,
                        nrCoopAmount: x.nrCoopAmount,
                        coopReason: x.coopReason,
                        coopComments: x.coopComments,
                        lineItemId: x.lineItemId,
                        isDirtyRow: x.isDirtyRow,
                        totalQty: x.totalQty,
                        posQuantity: x.posQuantity,
                        pap: x.pap,
                        promotedPrice: x.promotedPrice,
                        //discount: x.discount,
                        customerRetailPrice: x.customerRetailPrice,
                        pricebookEntryId: x.pricebookEntryId, 
                        listPrice: x.listPrice,
                        returns: x.returns,
                        salesAllowance: x.salesAllowance,
                        coop: x.coop,
                        merchandising: x.merchandising,
                        distributionCost: x.distributionCost,
                        returnCost: x.returnCost,
                        productionCost: x.productionCost,
                        royalFeeFixed: x.royalFeeFixed,
                        masterNegative: x.masterNegative, 
                        minimumContribution: x.minimumContribution,
                        cutOffDate: x.cutOffDate,
                        startDate: x.startDate,
                        scheduleEnabled: x.scheduleEnabled,
                        allocationOverride: x.allocationOverride,
                        plDecayCurveTemplate : x.plDecayCurveTemplate,
                        plQuantity : x.plQuantity,
                        handlingFee: x.handlingFee,
                        rentalPrice: x.rentalPrice,
                        revenueShare: x.revenueShare,
                        numberOfRentals: x.numberOfRentals,
                        finalPurchasePrice: x.finalPurchasePrice,
                        finalPurchase: x.finalPurchase,
                        overrideRentalPrices: x.overrideRentalPrices,
                        consignmentMultiplier: x.consignmentMultiplier,
                        gema: x.gema,
                        grossReceiptTaxesFFA: x.grossReceiptTaxesFFA,
                        doubtfulAccounts: x.doubtfulAccounts,
                        cashDiscounts: x.cashDiscounts,
                        priceTier: x.priceTier,  //US#172
                        permanentPriceTier: x.permanentPriceTier //US#663 - added new field
                    }
                });
    
                // Save the products to the salesforce controller
                apexController.saveLineItems(recordId, lineItemsSave, quickSave,
                    function(result, event) {
                        $rootScope.$apply(function() {
                          if (event.status) {
                            deferred.resolve(result);
                          } else {
                             console.log('**********11111111111111111***********'); 
                            deferred.reject(event);
                          }
                        });
                    },{
                       escape: false,
                       timeout: 120000 
                    }
                );
            
            return deferred.promise;
        };
    }]);