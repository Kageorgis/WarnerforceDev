//************************************************************/
//                       APP CONTROLLER
//************************************************************/

crmApp = angular.module('crmAddProduct', ['sfdcDataService','appConfig', 'infinite-scroll', 'crm-components', 'ngSanitize' ])

.controller('crmAddProductController', function($scope, $rootScope, getProductsService, getImageService, saveProductsService, getPricebooksService, getSelectOptionsService,getSelectOptionsServiceWithSobject,displayDealProdMoreInformationService, appConfig) {
  //4619 - added extra service method getSelectOptionsServiceWithSobject on controller declaration
  $scope.appConfig = appConfig;
  //$rootScope.appConfig = appConfig;
  //US#253 starts
  $scope.showDetail = false;
  $scope.productIds = [];
  //US#253 ends
  $scope.sidebarOn = true;
  $scope.totalDisplayed = 30;
  
  
  /* SCRIPT TO SHOW PRODUCT MOREINFO POPUP */
  $scope.moreInfoProduct;
  $scope.moreInfoProductUrl;

  $scope.showMoreInfoPopup = function(prodLi) {
    $scope.moreInfoProduct = prodLi;
    $scope.moreInfoProductUrl = '/apex/CRM_ProductMoreinfo?dealOrOrderId='+ appConfig.recordId +'&priceBookEntryID='+prodLi.pricebookEntryId;
  };
  //US#253 starts 
  
   // Bind the save function to the SFDC controller to commit the records
  $scope.displayMoreInformation = function() {
    if($scope.showDetail === false){
        $scope.showDetail = true;
                            
    $scope.pageMsg = null;
    $scope.showSpinner = true;
        displayDealProdMoreInformationService(appConfig.apexController, appConfig.recordId,  $scope.productIds).then(function(data) {
        angular.forEach(data.products, function(item, i) {
             if($scope.products[i].productId === item.productId){
                  $scope.products[i].lastPromotedPrice =item.lastPromotedPrice;
                  $scope.products[i].threeMonthOrderHistory =item.threeMonthOrderHistory; 
             }
        });
        
         $scope.showSpinner = false;
         console.debug('In show info:::$scope.products length:::::'+$scope.products.length);
         if(data.maxLimitExceeded){
           $scope.addPageMessage($Label.maxLimitReached, 'error');
        }
    },
    function(error) {
      $scope.addPageMessage(error.message, 'error');
      $scope.showSpinner = false;
    });
    }else if($scope.showDetail === true){
        $scope.showDetail = false;
    }
  };
  
  //US#253 ends
  $scope.hideMoreInfoPopup = function() {
    $scope.moreInfoProduct = null;
    $scope.moreInfoProductUrl = null;
  };
  /***************************************/
  
  // For updating the view mode to list/grid
  $scope.viewMode = 'grid';
  
  $scope.search = {};
  $scope.search.bundleProductsOnly = ($scope.appConfig.dealBundleId) ? true : false;
  
  $scope.toggleSearch = function() {
    $scope.sidebarOn = !$scope.sidebarOn;
  };
  
  $scope.setViewMode = function(mode) {
    $scope.viewMode = mode;
  }
  
  $scope.increaseTotalDisplayed = function() {
    var INCREMENT_BY = 10;
    $scope.fetchProductImages($scope.totalDisplayed, $scope.totalDisplayed + INCREMENT_BY - 1);
    $scope.totalDisplayed += INCREMENT_BY;
  };

  $scope.selectOptions = {
    StreetDates : [{"label": "Next Month", "value":"30", "selected": false}, {"label": "Next 3 Months", "value":"90", "selected": false}]
  };
  
  $scope.pageMsg = null;
  $scope.msgSeverity;
  
  // default tab for more product info popup box
  $scope.moreinfo = {tab : 'overview'};
  $scope.showSpinner = false;
  
  $scope.clearFilters = function() {
    $scope.search = {};
    
    
    /* CLEAR FILTER SELECTION*/     
    angular.forEach($scope.selectOptions.productTypes, function (item, index) {  item["selected"] = false; });
    angular.forEach($scope.selectOptions.productMarkets, function (item, index) {  item["selected"] = false; });
    angular.forEach($scope.selectOptions.productFormats, function (item, index) {  item["selected"] = false; });
    angular.forEach($scope.selectOptions.productGenres, function (item, index) {  item["selected"] = false; });
    angular.forEach($scope.selectOptions.distChainProdStatus, function (item, index) {  item["selected"] = false; });
    angular.forEach($scope.selectOptions.releaseCategories, function (item, index) {  item["selected"] = false; });
    angular.forEach($scope.selectOptions.prodLanguages, function (item, index) {  item["selected"] = false; });
    angular.forEach($scope.selectOptions.franchiseTypes, function (item, index) {  item["selected"] = false; });
    angular.forEach($scope.selectOptions.productRatings, function (item, index) {  item["selected"] = false; });
    angular.forEach($scope.selectOptions.StreetDates, function (item, index) {  item["selected"] = false; });
    //US#232
    angular.forEach($scope.selectOptions.plantStatus, function (item, index) {  item["selected"] = false; });
    $scope.search.pageCount = 1;
    $scope.loadProducts();
  };

    $scope.refineFilters = function() {
        $scope.search.pageCount = 1;
        //Defect#4116(German UAT)
        $scope.search.sortByField = 'Product2.Name';
        $scope.search.sortOrder = 'ASC';
        $scope.loadProducts();
    };

  $scope.sortProducts = function(sortField) {
    if(sortField == $scope.search.sortByField){
        $scope.search.sortOrder = $scope.search.sortOrder == 'ASC' ? 'DESC' : 'ASC';
    }
    else {
        $scope.search.sortByField = sortField;
        $scope.search.sortOrder = 'ASC';
    }   
    $scope.loadProducts();
  };
  
  $scope.loadPicklistOptions = function(){
	console.log('$scope.appConfig.searchOnlyPage = '+ $scope.appConfig.searchOnlyPage);
	
	// fetch the pricebooks
	if($scope.appConfig.searchOnlyPage == true) {
		getPricebooksService(appConfig.apexController).then(function(data) {
			console.log('Pricebooks are', data);
			$scope.selectOptions.pricebooks = data;
		});
	}
	  
    // load filter picklist options
    getSelectOptionsService(appConfig.apexController, 'Product2', 'Type__c', ' ').then(function(data) {
      var dealData =[];
      //US#788 UNBW Products Visible to Italy for add products 
      if($scope.appConfig.recordType ==='Opportunity' || ($scope.appConfig.recordType ==='Order' && !$scope.appConfig.isItaly)
       || ($scope.appConfig.recordType ==='Bundle__c' && $scope.appConfig.isPromotionalAssortment)){
           angular.forEach(data, function(item, i) {
               //Exclude UNBW from the Picklist displayed in the side bar container
               if(item.label != 'UNBW'){
                   dealData.push(item);
               }
           });
            $scope.selectOptions.productTypes = dealData;
      }else{
      $scope.selectOptions.productTypes = data;
      }
    });
    getSelectOptionsService(appConfig.apexController, 'Product2', 'Product_Market__c', '').then(function(data) {
      $scope.selectOptions.productMarkets = data;
    });
    getSelectOptionsService(appConfig.apexController, 'Product2', 'Product_Format__c', '').then(function(data) {
      $scope.selectOptions.productFormats = data;
    });
    getSelectOptionsService(appConfig.apexController, 'Product2', 'Product_Genre__c', '').then(function(data) {
      $scope.selectOptions.productGenres = data;
    });
    
    //Defect#4619 - code seperated for bundle to show pre selected status on page for physical assortment only
    if($scope.appConfig.recordType ==='Bundle__c'){
          getSelectOptionsServiceWithSobject(appConfig.apexController, 'Product2', 'SAP_Dist_chain_product_Status__c', '',appConfig.recordId).then(function(data) {
          $scope.selectOptions.distChainProdStatus = data;
          $scope.search.distChainProdStatus = [];
          angular.forEach($scope.selectOptions.distChainProdStatus, function (item, index) {
              if(item.selected == true){
                  var jsonObject = JSON.parse(JSON.stringify(item));
                  $scope.search.distChainProdStatus.push(jsonObject);
              }
          });
          console.log('$scope.search.distChainProdStatus::', $scope.search.distChainProdStatus);
          });
    }//Defect#4619 - end
    else{
        getSelectOptionsService(appConfig.apexController, 'Product2', 'SAP_Dist_chain_product_Status__c', '').then(function(data) {
          $scope.selectOptions.distChainProdStatus = data;
        });
    }
    getSelectOptionsService(appConfig.apexController, 'Product2', 'Release_Category__c', '').then(function(data) {
      $scope.selectOptions.releaseCategories = data;
    });
    getSelectOptionsService(appConfig.apexController, 'Product2', 'Product_Language_Code__c', '').then(function(data) {
      $scope.selectOptions.prodLanguages = data;
    });
    getSelectOptionsService(appConfig.apexController, 'Product2', 'Franchise_Type__c', '').then(function(data) {
      $scope.selectOptions.franchiseTypes = data;
    });
    getSelectOptionsService(appConfig.apexController, 'Product2', 'Product_Rating__c', '').then(function(data) {
      $scope.selectOptions.productRatings = data;
    });
    getSelectOptionsService(appConfig.apexController, 'Title__c', 'Content_Type__c', '').then(function(data) {
      $scope.selectOptions.contentTypes = data;
    });
    //US#232
    //Defect#4619 - show pre filter for product material status on page only for physical assortment.
    if($scope.appConfig.recordType ==='Bundle__c'){
         getSelectOptionsServiceWithSobject(appConfig.apexController, 'Product2', 'Plant_Specific_Material_Status__c', '',appConfig.recordId).then(function(data) {
          $scope.selectOptions.plantStatus = data;
          $scope.search.plantStatus = [];
          angular.forEach($scope.selectOptions.plantStatus, function (item, index) {
              if(item.selected == true){
                  var jsonObject = JSON.parse(JSON.stringify(item));
                  $scope.search.plantStatus.push(jsonObject);
              }
          });
          console.log('$scope.search.plantStatus::', $scope.search.plantStatus);
        });
        
    }//Defect#4619 - end
    else{
        //US#232
        getSelectOptionsService(appConfig.apexController, 'Product2', 'Plant_Specific_Material_Status__c', '').then(function(data) {
            $scope.selectOptions.plantStatus = data;
        }); 
    }
  };
  
  $scope.fetchProductImages = function(startIndex, endIndex) {
    for(var i=startIndex; i<=endIndex; i++) {
      if($scope.products && i < $scope.products.length) {
        (function(){
          var j = i;
          getImageService(appConfig.clientIpAddress, appConfig.wb2bImageServiceUrl, appConfig.wb2bImageServiceClientId, appConfig.wb2bImageServiceClientSecret, $scope.products[j],appConfig.isJVProfiles).then(function(imgUrl) {
              
			  if (imgUrl == "N/A") {
                $scope.products[j].imageUrl = $scope.appConfig.resourceAddProducts + "/images/no_image_available.png";
              }
              else {
                $scope.products[j].imageUrl = imgUrl;
              }
          });
        })();
      }
    }
  };
  
  //Start - US#1015:Product language column
  $scope.isDigital = false;
  //End - US#1015:Product language column
  
  $scope.loadProducts = function() {
    $scope.showDetail = false; 
    $scope.showSpinner = true;
    $scope.pageMsg = null;
      
      // Load the products using the apex controller and price book passed in the page params
    getProductsService(appConfig.apexController, appConfig.recordId, appConfig.priceBookId, $scope.search).then(function(data) {
    	//Start - US#1015:Product language column
    	$scope.isDigital = data.isDigital;
    	//End - US#1015:Product language column
    	$scope.products = data.products;
        $scope.maxPageCount = data.maxPageCount;
        $scope.productIds = data.setProductIds;
        
        //US#317 (Japan)
        if($scope.search.StreetDateFrom){
            $scope.DateObj = new Date($scope.search.StreetDateFrom);
            $scope.totalMinute = ($scope.DateObj.getMinutes() + $scope.DateObj.getTimezoneOffset());
            $scope.DateObj.setMinutes($scope.totalMinute);
            $scope.search.StreetDateFrom =  $scope.DateObj;
        }
        
        //US#317 (Japan)    
        if($scope.search.StreetDateTo){
            $scope.DateObj = new Date($scope.search.StreetDateTo);
            $scope.totalMinute = ($scope.DateObj.getMinutes() + $scope.DateObj.getTimezoneOffset());
            $scope.DateObj.setMinutes($scope.totalMinute);
            $scope.search.StreetDateTo = $scope.DateObj;
        }
        //console.log('$scope.searchFrom::::::'+$scope.search.StreetDateFrom);
        //console.log('$scope.searchTo::::::'+$scope.search.StreetDateTo);
        
        // Load images for the products from WB2B/MARS
        // Currently 1 call per image - to be replaced by a multi-image web service
        // load images for first 30 products 
        $scope.fetchProductImages(0, $scope.totalDisplayed -1);
        $scope.showSpinner = false;
        if(data.maxLimitExceeded){
           $scope.addPageMessage($Label.maxLimitReached, 'error');
        }
    },
    function(error) {
      $scope.addPageMessage(error.message, 'error');
      $scope.showSpinner = false;
    });
  };
  
  $scope.addPageMessage =  function(msg, sev) {
    $scope.pageMsg = msg;
    $scope.msgSeverity = sev;
  };
  
  $scope.addAllSelected = function() {
    for(i=0; i< $scope.products.length; i++) {
      var qty = $scope.products[i].quantity;
      var isSelected = $("#select-row-"+i).prop("checked");
      
      if(isSelected == true && (qty === undefined || qty == null || qty.length === 0 || qty == 0)) {
        
        $scope.products[i].quantity = 1;
      }
    }
  };

 $scope.navigateToURL = function(url) {
    var isLightningExperienceOrSf1 = ((typeof sforce != 'undefined') && sforce && (!!sforce.one));
    if (isLightningExperienceOrSf1)
        if($scope.appConfig.recordType ==='Opportunity' || ($scope.appConfig.recordType ==='Order'))  
            sforce.one.navigateToURL(url);
        else
            window.open('/lightning/r/Bundle__c/'+$scope.appConfig.recordId+'/view?fr=1','_parent'); 
      else
        location.href = url;
        //document.location is deprecated so removed from here
        //document.location.href = url;
  };
  
   $scope.navigateToURLByLink = function(url) {
    var isLightningExperienceOrSf1 = ((typeof sforce != 'undefined') && sforce && (!!sforce.one));
    if (isLightningExperienceOrSf1){
    console.log('in....');
           window.open('/lightning/r/'+$scope.appConfig.recordType+'/'+$scope.appConfig.recordId+'/view?fr=1','_parent'); 
      }else
        location.href = url;
        //document.location is deprecated so removed from here
        //document.location.href = url;
  };

    // Bind the save function to the SFDC controller to fetch the products
    $scope.loadPrevProducts = function() {
      $scope.showDetail = false;
        console.log('--page count prev before->'+$scope.search.pageCount);
        if ($scope.search.pageCount == undefined || $scope.search.pageCount == null) {
            $scope.search.pageCount = 1;
        } else {
            $scope.search.pageCount = $scope.search.pageCount - 1;
        }
        console.log('--page count prev after->'+$scope.search.pageCount);
        $scope.loadProducts();
    };

    // Bind the save function to the SFDC controller to fetch the products
    $scope.loadNextProducts = function() {
      $scope.showDetail = false;
        console.log('--page count nxt before->'+$scope.search.pageCount);
        console.log('--Max page count next before->'+$scope.maxPageCount);
        if ($scope.search.pageCount == undefined || $scope.search.pageCount == null) {
            $scope.search.pageCount = 1;
        } else {
            $scope.search.pageCount = $scope.search.pageCount + 1;
        }
        console.log('--page count next after->'+$scope.search.pageCount);
        console.log('--Max page count next after->'+$scope.maxPageCount);
        $scope.loadProducts();
    };

  // Bind the save function to the SFDC controller to commit the records
  $scope.saveData = function(quickSave) {
    $scope.pageMsg = null;
    $scope.showSpinner = true;
    saveProductsService(appConfig.apexController, appConfig.recordId, $scope.products)
      .then(function(data) {
          if(quickSave) {
            $scope.addPageMessage($Label.addSuccessMsg+' '+appConfig.breadcrumbRecordName+'.', 'success');
            $scope.showSpinner = false;
          }
          else {
            $scope.navigateToURL(appConfig.onSaveSuccessUrl);
          }
        },
        function(data){
          $scope.addPageMessage(data.message, 'error');
          $scope.showSpinner = false;
        }
      );
    };
    
    
    $scope.loadPicklistOptions();
})


/**************************************************
 * DIRECTIVES 
 **************************************************/

.directive("crmAddProductsHeader",function(appConfig){
  return {
    restrict : "EAC",
    replace : true,
    templateUrl : 'add-products-header.html',
    link : function(scope, elem, attr){
      scope.appConfig = appConfig;
    },
    controller: function($scope){
      
    }
  }
})

.directive("crmAddProductsGridView",function(appConfig){
  return {
    restrict : "EAC",
    replace : true,
    templateUrl : 'add-products-grid-view.html',
    link : function(scope, elem, attr){
      scope.appConfig = appConfig;
    },
    controller: function($scope){
    }
  }
})


.directive("crmAddProductsListView",function(appConfig){
  return {
    restrict : "EAC",
    replace : true,
    templateUrl : 'add-products-list-view.html',
    link : function(scope, elem, attr){
      scope.appConfig = appConfig;
    },
    controller: function($scope){
    }
  }
})

.directive("crmAddProductsSidebar",function(appConfig){
  return {
    restrict : "EAC",
    replace : false,
    templateUrl : 'add-products-sidebar.html',
    scope : {
      selectOptions : "=",
      search : "=",
      onRefine : "&",
      onReset : "&",
      sidebarOn : "="
    },
    link : {
      pre: function(scope, elem, attr){
          scope.appConfig = appConfig;
      }
    },
    controller: function($scope){
      
    }
  }
});