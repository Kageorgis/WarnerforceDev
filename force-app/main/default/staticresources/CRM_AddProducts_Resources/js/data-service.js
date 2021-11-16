//************************************************************/
//                       DATA SERVICES
//************************************************************/
angular.module("sfdcDataService", [])

.factory("getProductsService", ['$q', '$rootScope', function($q, $rootScope) {
    return function(apexController, opportunityId, priceBookId, search) {
        var deferred = $q.defer();
        if(search.StreetDateFrom){
            var StreetDateFrom = new Date(search.StreetDateFrom.setMinutes(search.StreetDateFrom.getMinutes() - search.StreetDateFrom.getTimezoneOffset()));
            search.StreetDateFrom = StreetDateFrom.toUTCString();
        }
        if(search.StreetDateTo){
            var StreetDateTo = new Date(search.StreetDateTo.setMinutes(search.StreetDateTo.getMinutes() - search.StreetDateTo.getTimezoneOffset()));
            search.StreetDateTo = StreetDateTo.toUTCString();
        }
        
        //console.log("Get Products Remoting Started @ "+ getDateTimeStr());
        
        // Load the products from the salesforce controller
        apexController.getProducts(opportunityId, priceBookId, search,
            function(result, event) {
                //console.log("Get Products Remoting completed @ "+ getDateTimeStr());
                $rootScope.$apply(function() {
                  if (event.status) {
                    deferred.resolve(result);
                  } else {
                    deferred.reject(event);
                  }
                })
            },{
                escape: false,
                timeout: 120000
           }
        );
        
        return deferred.promise;
    }
}])

.factory("getPricebooksService",['$q', '$rootScope', function($q, $rootScope){
    return function(apexController) {
        var deferred = $q.defer();
        
        apexController.getPricebooks(
            function(result, event) {
                $rootScope.$apply(function() {
                  if (event.status) {
                    deferred.resolve(result);
                  } else {
                    deferred.reject(event);
                  }
                })
            },{
                escape: false,
                timeout: 120000
           }
        );

        return deferred.promise;
    }
}])

.factory("getSelectOptionsService",['$q', '$rootScope', function($q, $rootScope){
    return function(apexController, objName, fieldName, firstVal) {
        var deferred = $q.defer();
        
        apexController.getFilterPicklistValues(objName, fieldName, firstVal,
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

//Defect#4619 - added factory method to apply prefilter for physical assortment only.
.factory("getSelectOptionsServiceWithSobject",['$q', '$rootScope', function($q, $rootScope){
	return function(apexController, objName, fieldName, firstVal,recordId) {
		var deferred = $q.defer();
		console.log('Inside new factory method');
		apexController.getFilterPicklistValuesWithSObject(objName, fieldName, firstVal,recordId,
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
//Defect#4619 - end

.factory("saveProductsService", ['$q', '$rootScope', function($q, $rootScope) {
    return function(apexController, recordId, products) {
        var deferred = $q.defer();

        var productsWithQty = $.grep(products, function(x){
            return !(x.quantity == null || x.quantity.length === 0);
        });

        // Rip the two fields that are needed
        var productsSave = $.map(productsWithQty, function(x) {
            return {
                quantity: x.quantity,
                pricebookEntryId: x.pricebookEntryId, 
                listPrice: x.listPrice,
                productId: x.productId
            }
        });

        // Save the products to the salesforce controller
        apexController.saveProducts(recordId, productsSave,
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
.factory("displayDealProdMoreInformationService", ['$q', '$rootScope', function($q, $rootScope) {
    return function(apexController, recordId, productIds) {
        var deferred = $q.defer();
        // get the products to the salesforce controller 
         apexController.displayDealProdMoreInformation(recordId, productIds, function(result, event) {
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
.factory("getImageService", ['$q', '$rootScope', function($q, $rootScope) {
    return function(clientIpAddress, imageServiceUrl, clientId, clientSecret, product,isJVProfile) {
        var deferred = $q.defer();

        /*var soapRequest = '<?xml version="1.0" encoding="UTF-8"?> \
                    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://imagedetail.webservices.whv.com/"> \
                      <SOAP-ENV:Body> \
                        <ns1:getAssetURL> \
                          <assetMetaData> \
                            <countryCode>'+product.countryCode+'</countryCode> \
                            <imageSize>S</imageSize> \
                            <ipAddress>'+clientIpAddress+'</ipAddress> \
                            <languageCode>'+product.languageCode+'</languageCode> \
                            <videoVersionNumber>'+product.videoVersion+'</videoVersionNumber> \
                          </assetMetaData> \
                        </ns1:getAssetURL> \
                      </SOAP-ENV:Body> \
                    </SOAP-ENV:Envelope>';
                    
        sforce.connection.remoteFunction({
               url : "https://api.test.wb2b.com/services/rest/v1/dAssetURL?countryCode="+product.countryCode+"&imageSize=S&ipAddress="+clientIpAddress+"&languageCode="+product.languageCode+"&videoVersionNumber="+product.videoVersion,
               timeout : 60000,
               requestHeaders: {'Content-Type':'application/json', 'client-id': 'SALES_FORCE', 'client-secret': 'Dra4u5t7&Re2atuC7av7pRuD_8TeCHuW'},
               //requestData: jsonRequest,
               method: "GET",
               onSuccess : function(response) {
               	console.log('=====response====',response);
                    var xmlDoc = $.parseXML( response );
                    var imgUrl = $( xmlDoc ).find( "dwndURL" ).text();
                    deferred.resolve(imgUrl);
               },
               onFailure : function(response) {
               		console.log('=====failure====',response);
                   deferred.reject(event);
               }
           });
           console.log('Image service Url', imageServiceUrl);*/
			
			//Added Check for CRM-JV Products Images
			var finalURL;
			if(isJVProfile=='true'){
			finalURL=imageServiceUrl +"upcCode="+product.universalProductCode+"&ipAddress="+clientIpAddress;
			}else {
			finalURL=imageServiceUrl +"videoVersionNumber="+product.videoVersion+"&ipAddress="+clientIpAddress+"&languageCode="+product.languageCode+"&countryCode="+product.countryCode+"&imageSize=S";
			}	
			
           sforce.connection.remoteFunction({
               url : finalURL,
			   timeout : 60000,
               requestHeaders: { "client-id": clientId, "client-secret": clientSecret},
               method: "GET",
               onSuccess : function(response) {
                    var imgUrl = response;
					deferred.resolve(imgUrl);
               },
               onFailure : function(response) {
                   var imgUrl;
				   if(response !== null){
                       try{
                     
						var responseJSON = JSON.parse(response);
                        
						if(responseJSON.Errors !== null && responseJSON.Errors.Status === 404)
                        {
                            imgUrl = "N/A";
                            deferred.resolve(imgUrl);
                                
                        }   
                       }
                       catch(e)
                       {
                            imgUrl = "N/A";
                            deferred.resolve(imgUrl);
                       }
                        
                    }
                   
               }
           });

        return deferred.promise;
    }
}]);
