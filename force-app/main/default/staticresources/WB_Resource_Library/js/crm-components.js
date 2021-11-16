angular.module("crm-components", [])

.directive("crmMultiselectPicklist",function(appConfig, $timeout){
  
  return {
    restrict : "EAC",
    scope : {
      options : "=",
      selectedopts : "=", 
      multiple:'=',
      placeholder:"@"
    },
    
    controller : function($scope) {
        $scope.selectedItems = [];
        $scope.openPopup = false;
        $scope.selectedItem;
        
        $scope.onItemClick = function(item){
          
          if($scope.multiple == false) {
            angular.forEach($scope.options,function(option,index){
                if(item.value != option.value) {
                    option["selected"] = false;
                }
            });
          }
    
          if(typeof item["selected"] == "undefined")
            item["selected"] = true;
          else
            item["selected"] = !item["selected"];
    
          $scope.calculatelength();
        };
        
        $scope.calculatelength = function(){
          $scope.selectedItems = [];
          angular.forEach($scope.options,function(option,index){
             if(option.selected) {
                $scope.selectedItems.push(option);
                $scope.selectedItem = option;
             }
          });
    
          $scope.selectedopts = angular.copy($scope.selectedItems);
        };
    },
    
    templateUrl : 'multiselect-picklist.html',
    replace:true,
    
    link: function(scope, elem, attr) {
      scope.appConfig = appConfig;

      $(document).click(function(e){
        //alert();
        
        if( $(e.target).closest(elem).length == 0 ){
            $timeout(function(){
                scope.openPopup = false;
            });
        }
      });
    }
  };
  
})

  .directive('crmDatepicker', function(){
    return {
      restrict: "A",
      replace: false,
      scope: {
            dpOptions: '=',
            dpModel: '='
      },
      link: function(scope, element) {
              console.log(scope);
            scope.inputHasFocus = false;
            element.datepicker(scope.dpOptions).on('changeDate', function(e) {
              var defaultFormat, defaultLanguage, format, language;
              defaultFormat = $.fn.datepicker.defaults.format;
              format = scope.dpOptions.format || defaultFormat;
              defaultLanguage = $.fn.datepicker.defaults.language;
              language = scope.dpOptions.language || defaultLanguage;
                    
              return scope.$apply(function() {
                return scope.dpModel = e.date;
              });
            }).on('focus', function(e){
                  return scope.inputHasFocus = true;
            }).on('blur', function(e){
                  return scope.inputHasFocus = false;
            });
            
            return scope.$watch('dpModel', function(newValue) {
              if (!scope.inputHasFocus) {
                return element.datepicker('update', newValue);
              }
            });
         }
    };
})


.directive("crmLookup",function($timeout){
            return {
                restrict : "EAC",
                scope : {
                  objectName : "@", // API NAME OF THE OBJECT TO SEARCH
                  objectIcon : "@", // OBJECT ICON TO BE DISPLAYED FOR SELECTED AND RESULT RECORDS
                  sldsResourceLoc : "@", // LOCATION/URL OF THE SLDS-RESOURCE (TO USE SVG)
                  primaryNameField : "@", 
                  secondaryNameField : "@", 
                  recordId : "=", // ID OF THE SELECTED RECORD 
                  recordName : "=", // NAME OF THE SELECTED RECORD
                  lookupChange : "&",
                  currencyCode : "@",
                  decaycurveStatus: "@",
                  dealRecordTypeName: "=",
                  placeHolder : "@",
                  accountRecordTypeName: "@" // ACCOUNT REORD TYPE NAME
                },
                
                controller : function($scope) {
                    $scope.searchStr;
                    $scope.showList = false;
                    $scope.matchingRecords = [];
                    
                    $scope.fetchRecords = function(){
                        if($scope.searchStr && $scope.searchStr.trim().length > 1) {
                            var PRIMARY_NAME_FIELD = ($scope.primaryNameField ? $scope.primaryNameField : "NAME");
                            var SOQL_STR = "SELECT ID, " + PRIMARY_NAME_FIELD + ($scope.secondaryNameField ? ", "+$scope.secondaryNameField : "");
                            SOQL_STR += " FROM "+ $scope.objectName +" WHERE ";
                            if($scope.objectName == 'Account'){
                                SOQL_STR += "("+PRIMARY_NAME_FIELD + " LIKE '%"+ $scope.searchStr.trim() +"%' OR AccountNumber Like '%"+ $scope.searchStr.trim() +"%')";
                                if($scope.dealRecordTypeName && $scope.dealRecordTypeName.trim().length > 1){
                                    if($scope.dealRecordTypeName == 'Physical_Deal'){
                                        SOQL_STR += " AND (Video_Physical__c = true OR Games_Physical__c = true OR Music_Physical__c = true)";
                                        SOQL_STR += " AND Planning_Customer__c = true";
                                    }else if($scope.dealRecordTypeName == 'Digital_Deal'){
                                        SOQL_STR += " AND (Video_Digital__c = true OR Games_Digital__c = true OR Music_Digital__c = true)";
                                    }
                                }
                                if($scope.accountRecordTypeName && $scope.accountRecordTypeName.trim().length > 1){
                                    SOQL_STR += " AND RecordType.DeveloperName = '"+$scope.accountRecordTypeName+"'";
                                }
                            }else{
                                SOQL_STR += PRIMARY_NAME_FIELD + " LIKE '%"+ $scope.searchStr.trim() +"%'";
                                if($scope.objectName == 'Decay_Curve_Template__c'){
                                    if($scope.currencyCode && $scope.currencyCode.trim().length > 1){
                                        SOQL_STR += " AND CurrencyIsoCode = '"+$scope.currencyCode.trim()+"'";
                                    }
                                    if($scope.decaycurveStatus && $scope.decaycurveStatus.trim().length > 1){
                                        SOQL_STR += " AND Status__c = '"+$scope.decaycurveStatus.trim()+"'";
                                    }
                                }
                            }
                            SOQL_STR += " ORDER BY "+PRIMARY_NAME_FIELD;
                            SOQL_STR += " LIMIT 50"; 
                            
                            console.log(SOQL_STR);
                            
                            sforce.connection.query(SOQL_STR, 
                                function(result){
                                    var resultArr = [];
                                    var secondaryNameFieldArray = ($scope.secondaryNameField) ? $scope.secondaryNameField.split(",") : [];
                                    var records = result.getArray("records");
                                    for (var i=0; i<records.length; i++) {
                                        var recObj = {SObjectLabel: records[i].Name, SObjectId: records[i].Id, SObjectLabel2: null };
                                        for (var j=0; j<secondaryNameFieldArray.length; j++) {
                                            if(records[i][secondaryNameFieldArray[j]]){
                                                if(j===0){
                                                    recObj.SObjectLabel2 = records[i][secondaryNameFieldArray[j]];
                                                }else{
                                                    recObj.SObjectLabel2 += " , "+records[i][secondaryNameFieldArray[j]];
                                                }
                                            }
                                        }
                                        resultArr.push(recObj);
                                    }
                                    $scope.matchingRecords = resultArr;
                                    $scope.$apply();
                                },
                                function(error){
                                    console.log(error)
                                }
                            );
                        }
                    };
                    
                    $scope.setLookupRecord = function(rec){
                        $scope.recordId = rec.SObjectId;
                        $scope.recordName = rec.SObjectLabel;
                        $scope.showList = false;
                        
                        if($scope.lookupChange) {
                            $timeout(function(){$scope.lookupChange();});
                        }
                    };
                    
                    $scope.clearLookup = function(){
                        $scope.recordId = null;
                        $scope.recordName = null;
                        $scope.searchStr = null;
                        $scope.matchingRecords = [];
                        
                        if($scope.lookupChange) {
                            $timeout(function(){$scope.lookupChange();});
                        }
                    };
                },
                
                templateUrl : 'slds-lookup.html',
                replace: true,
                
                link: function(scope, elem, attr) {
                  $(document).click(function(e){
                    if( $(e.target).closest(elem).length == 0 ){
                        $timeout(function(){
                            scope.showList = false;
                            if(!scope.recordId) {
                                scope.searchStr = null;
                            }
                        });
                    }
                  });
                }
              };
        })


 .directive('stringToNumber', function() {
  return {
    require: 'ngModel',
    link: function(scope, element, attrs, ngModel) {
      ngModel.$parsers.push(function(value) {
        return '' + value;
      });
      ngModel.$formatters.push(function(value) {
        return parseFloat(value, 10);
      });
    }
  };
})

.directive('integerInput', function () {
    return {
        require: 'ngModel',
        link: function (scope, element, attr, ngModelCtrl) {
            function fromUser(text) {
                if (text) {
                    var transformedInput = text.replace(/[^0-9-]/g, '');
                    if (transformedInput !== text) {
                        ngModelCtrl.$setViewValue(transformedInput);
                        ngModelCtrl.$render();
                    }
                    return transformedInput;
                }
                return undefined;
            }
            ngModelCtrl.$parsers.push(fromUser);
        }
    };
})

.directive('formatNumber', [ function () {
  return {
    restrict: 'A',
    require: '?ngModel',
    compile: function(tElement, tAttrs)
    {
        return function (scope, element, attrs, ngModelCtrl, undefined)
        {
            if (ngModelCtrl != null) {
                ngModelCtrl.$parsers.unshift(function(value)
                {
                    if (value != 0 && value != undefined) {
                        console.log('-value-parser-if->',value);
                        var parser = Globalize.numberParser();
                        var transformedInput =  parser((value).replace(/\s/g, ""));

                        // Deal Products
                        if (scope.lineItem != null && scope.lineItem != undefined) {
                            if (isNaN(transformedInput)) {
                                scope.lineItem.inValidFormatMap[attrs.id] = true;
                            } else {
                                delete scope.lineItem.inValidFormatMap[attrs.id];
                            }
                        }
                        
                        // Order Products
                        else if (scope.$parent != null && scope.$parent != undefined && scope.$parent.lineItem != null && scope.$parent.lineItem != undefined) {
                            if (isNaN(transformedInput)) {
                                scope.$parent.lineItem.inValidFormatMap[attrs.id] = true;
                            } else {
                                delete scope.$parent.lineItem.inValidFormatMap[attrs.id];
                            }
                        } 
                        
                        // Credit Note Line Items
                        else if (scope.cnItemWrapper != null && scope.cnItemWrapper != undefined) {
                            if (isNaN(transformedInput)) {
                                scope.cnItemWrapper.inValidFormatMap[attrs.id] = true;
                            } else {
                                delete scope.cnItemWrapper.inValidFormatMap[attrs.id];
                            }
                        }
                        return transformedInput;
                    } else {
                        console.log('-value-parser else-->',value);
                        if (value == '') {
                            value = null;
                        }
                        // Deal Products
                        if (scope.lineItem != null && scope.lineItem != undefined) {
                            if (scope.lineItem.inValidFormatMap[attrs.id]) {
                                delete scope.lineItem.inValidFormatMap[attrs.id];
                            }
                        }
                        
                        // Order Products
                        else if (scope.$parent != null && scope.$parent != undefined && scope.$parent.lineItem != null && scope.$parent.lineItem != undefined) {
                            if (scope.$parent.lineItem.inValidFormatMap[attrs.id]) {
                                delete scope.$parent.lineItem.inValidFormatMap[attrs.id];
                            }
                        } 
                        
                        // Credit Note Line Items
                        else if (scope.cnItemWrapper != null && scope.cnItemWrapper != undefined) {
                            if (scope.cnItemWrapper.inValidFormatMap[attrs.id]) {
                                delete scope.cnItemWrapper.inValidFormatMap[attrs.id];
                            }
                        }
                        return value;
                    }
                }); // end $parser

                ngModelCtrl.$formatters.unshift(function(value)
                {
                    if (value != 0 && value != undefined) {
                        var decimalFormatter = Globalize.numberFormatter({ maximumFractionDigits: attrs.formatNumber});
                        var transformedInput =  decimalFormatter(parseFloat(value));
                        return transformedInput
                    } else {
                        return value;
                    }
                });
            }
        }
    } // end compile function
  };
}
])

/**************************************************
* DIRECTIVES : Us 909
**************************************************/
.directive("crmAddSearchProductsView",function(appConfig){
	return {
		restrict : "EAC",
		replace : true,
		templateUrl : 'add-search-products-view.html',
		link : function(scope, elem, attr){
		  scope.appConfig = appConfig;
		},
		controller: function($scope){}
	}
})

.filter('decodehtml', function($sce) {
    return function(text) {
        // JQUERY API must be included in the page
        return $("<div/>").html(text).text();
    };
});