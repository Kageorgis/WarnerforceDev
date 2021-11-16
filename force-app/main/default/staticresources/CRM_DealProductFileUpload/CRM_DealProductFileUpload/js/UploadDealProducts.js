angular.module("UploadDealProducts",['ngHandsontable'])
.controller("UploadDealProductsController", ['$scope', function($scope) {
   $scope.isLightningExperienceOrSf1 = ((typeof sforce != 'undefined') && sforce && (!!sforce.one));
   $scope.msgText;
   $scope.msgSeverity; 
   $scope.showSpinner = false;
    // You can pass options by attributes..
   $scope.tableOptions = {
        colHeaders : false,
        allowInsertColumn : false,
        items : [],
        removedItems:[],
        itemsMinusRemoved:[],
        cleanedData:[],
        colHeadersLabels :{
                lineItemRecord:{
                        Product2 :{
                                    ProductCode: '{!$ObjectType.Product2.fields.ProductCode.Label}', 
                                    Universal_Picture_Code__c: '{!$ObjectType.Product2.fields.Universal_Picture_Code__c.Label}', 
                                    Name:'{!$ObjectType.Product2.fields.Name.Label}'
                                  },
                        Promoted_Price__c : '{!$ObjectType.OpportunityLineItem.fields.Promoted_Price__c.Label}',
                        Discount :  '{!$ObjectType.OpportunityLineItem.fields.Discount.Label} %',
                        Initial_Quantity__c: '{!$ObjectType.OpportunityLineItem.fields.Initial_Quantity__c.Label}',
                        Replen_Quantity__c : {!DigitalDeal}?'{!$ObjectType.OpportunityLineItem.fields.Quantity.Label}':'{!$ObjectType.OpportunityLineItem.fields.Replen_Quantity__c.Label}',
                        Quantity: '{!$ObjectType.OpportunityLineItem.fields.Quantity.Label}',
                },
                digital:{
                        videoVersion:'{!$Label.CRM_Upload_Field_VideoVersion}',
                        channel:'{!$Label.CRM_Upload_Field_Channel}',
                        format:'{!$Label.CRM_Upload_Field_Format}',
                        language:'{!$Label.CRM_Upload_Field_Language}',
                        retailerProductId:'Retailer Product ID'
                },
                validation:'{!$Label.CRM_Upload_Field_Validation}'
            }
   }
   
    $scope.GetLineItems = function(oppId,isDigital) {
       
       CRM_UploadDealProductsController.getOpportunityLineItems(oppId,
              function(result, event) {
                  if (event.status) {
                      $scope.tableOptions.items=result;
                      console.log($scope.tableOptions.items);
                  }
                  else {
                      $scope.msgText =event.message;
                      $scope.msgSeverity='error';
                  }
                  // add column headers in first row
                  $scope.tableOptions.items.splice(0, 0, $scope.tableOptions.colHeadersLabels);
                  $scope.$apply();
              }
       );
    };
    //['remove_row']
    $scope.mySettings = {
         contextMenu: {items: {
                      "remove_row": {
                        name:'{!$Label.CRM_Upload_Message_RemoveRow}',
                        disabled: function () {
                          //disable this option
                          if(this.getSelected()) {
                                var start_row = this.getSelected()[0];
                                var end_row = this.getSelected()[2];
                                if(start_row===0 || end_row===0) return true; // if header is selected
                                return false;
                          }
                        }
                      }
                    }},
         minSpareRows:1,
         stretchH: 'all',
         manualColumnResize: false,
         wordWrap: true,
         cells: function (row, col, prop) {
                    var cellProperties = {};
                    if(row==0) {cellProperties.readOnly=true;} // first row should not be editable but user should able to copy
                    cellProperties.renderer = $scope.myRenderer;
                    var item = $scope.tableOptions.items[row];
                    if(typeof item!='undefined')
                    if(row>0 && typeof item.existingId!='undefined' && (prop == 'lineItemRecord.Product2.ProductCode' ||
                        prop == 'lineItemRecord.Product2.Universal_Picture_Code__c' ||
                        prop == 'digital.videoVersion' ||
                        prop == 'digital.channel' ||
                        prop == 'digital.format' ||
                        prop == 'digital.language' || 
                        prop == 'digital.retailerProductId')){
                         //console.log(item.existingId+'=='+row+'==='+prop);    
                         cellProperties.readOnly=true;
                     }
                    return cellProperties;
                },
         beforeChange: function (changes, source)  { 
                            var ele = this;
                            $.each(changes, function (index, element) {
                                        // changes is a 2d array like [[row, prop, oldVal, newVal], ...]
                                        if(changes[index][3]=="") {
                                            changes[index][3]=null;
                                        }
                                        if(changes[index][2] != changes[index][3]) {
                                            ele.getCellMeta(element[0],ele.propToCol(element[1])).change=true;
                                        }
                                        
                            });
                        },
         beforeRemoveRow: function(index, amount){
                                            if (!confirm('{!$Label.CRM_Upload_Message_Remove_Row}')){
                                                return false;
                                            }
                                            for(i=index;i<index+amount;i++) {
                                                 $scope.tableOptions.items[i].isRowRemoved=true;
                                            }
                                            $scope.$apply();
                                            return false;
                          }                     
   };
    $scope.myRenderer=function(instance, td, row, col, prop, value, cellProperties) {
           // Mark changed items with a different class
         Handsontable.renderers.TextRenderer.apply(this, arguments); 
         var item = $scope.tableOptions.items[row];
         var cell = instance.getCell(row, col);
         
         if(item.isRowRemoved){
             td.style.backgroundColor = 'grey';
             td.style.color = 'white';
             item.isRowModified = false;
             item.previouslySelectedForRemoval=true;
         }
         else if (item.validation != '{!$Label.CRM_Upload_Message_Updated}' && item.validation != '{!$Label.CRM_Upload_Message_Created}' && item.validation != '' && item.validation != null) {
            td.style.backgroundColor = 'red';
            td.style.color = 'white';
            
            if(typeof item.previouslySelectedForRemoval != 'undefined' && !item.previouslySelectedForRemoval) {
                console.log(row+'='+item.previouslySelectedForRemoval);
                item.isRowModified = true;
            }
         }
         if(cellProperties.change && prop != 'validation') {
             $(cell).addClass('has-changed');
             item.isRowModified = true;
             item.isRowRemoved = false;
             item.previouslySelectedForRemoval=false;
         }
    };
    
        
    $scope.BackToDeal= function(url) {
       $scope.navigateToURL(url); 
    };
    
    
      $scope.navigateToURL = function(url) {
        var isLightningExperienceOrSf1 = ((typeof sforce != 'undefined') && sforce && (!!sforce.one));
    
        if ($scope.isLightningExperienceOrSf1)
            sforce.one.navigateToURL(url);
          else
            document.location.href = url;
      };

    $scope.isEmpty = function(objectjson){
         var dataExists = true;
         $.each(objectjson, function(i,d) {
            if(d!=null && d!='' && typeof d!= 'object') {
                dataExists = false;
            }
         });
         return dataExists;
    };
    
    $scope.SaveRecords= function(oppId,isDigital) {
        $scope.showSpinner = true;
        console.log('====='+$scope.tableOptions.items);
        // Flatten out the data, skip the first and last empty row
        //var inputData = _.flatten($scope.tableOptions.items.slice(0,-1));
        var inputData = $scope.tableOptions.items.slice(1,-1);
        $scope.msgText ='';
        $scope.msgSeverity='';
        var cleanedGridData = [];
        $.each( inputData, function( rowKey, object) {
            if (!isDigital && !($scope.isEmpty(object.lineItemRecord.Product2) && $scope.isEmpty(object.lineItemRecord) ))  {
                    cleanedGridData.push(object);
            } 
            if (isDigital && !($scope.isEmpty(object.digital) && $scope.isEmpty(object.lineItemRecord)))  {
                    cleanedGridData.push(object);
            } 
        });
       
        // Save data back
        CRM_UploadDealProductsController.setOpportunityLineItems(cleanedGridData,oppId,isDigital,function(result, event) {
            if (event.status){
                console.log(result);
                $scope.tableOptions.items = result;
                // add column headers in first row
                $scope.tableOptions.items.splice(0, 0, $scope.tableOptions.colHeadersLabels);
            
            } else {
                $scope.msgText =event.message;
                $scope.msgSeverity='error';
            }
            $scope.showSpinner = false;
            $scope.$apply();
        });
    };
    
}]);