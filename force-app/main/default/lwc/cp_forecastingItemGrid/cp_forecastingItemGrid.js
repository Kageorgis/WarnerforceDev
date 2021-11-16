/* 
==========================================================================================================
* @author: Kalash Rastogi
* @date: 10/07/2021
* @description: Javascript handler class for LWC.
==========================================================================================================
*/
import { api, LightningElement, track, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getProfile from '@salesforce/apex/CP_ForecastingItemController.getProfile'
import getForecastingItem from '@salesforce/apex/CP_ForecastingItemController.getForecastingItemsForPOC'
import createForecastingItem from '@salesforce/apex/CP_ForecastingItemController.createForecastingItemForPOC'
import deleteForecastingItem from '@salesforce/apex/CP_ForecastingItemController.deleteForecastingItemsForPOC'
import updateForecastingItem from '@salesforce/apex/CP_ForecastingItemController.updateForecastingItemForPOC'
import mergeSelectedRows from '@salesforce/apex/CP_ForecastingItemController.mergeSelectedRows'
import validateForecastItems from '@salesforce/apex/CP_ForecastingItemController.validateForecastItems'
//import getValidContracts from '@salesforce/apex/CP_ForecastingItemController.getValidContracts'
import submitForecast from '@salesforce/apex/CP_ForecastingItemController.submitForecast'
import FORECASTING_ITEM_OBJECT from '@salesforce/schema/CP_Forecast_Item__c';
import REVENUE_TYPE from '@salesforce/schema/CP_Forecast_Item__c.Revenue_Type__c'
import PRODUCT_TYPE from '@salesforce/schema/CP_Forecast_Item__c.CP_Product_Type__c'
import PROPERTY from '@salesforce/schema/CP_Forecast_Item__c.Property__c'
import CURRENCY from '@salesforce/schema/CP_Forecast_Item__c.Forecast_Currency__c'
import CONTRACT from '@salesforce/schema/CP_Forecast_Item__c.CP_Contract__c'
import Q1 from '@salesforce/schema/CP_Forecast_Item__c.Q1__c'
import Q2 from '@salesforce/schema/CP_Forecast_Item__c.Q2__c'
import Q3 from '@salesforce/schema/CP_Forecast_Item__c.Q3__c'
import Q4 from '@salesforce/schema/CP_Forecast_Item__c.Q4__c'
import RETAILER from '@salesforce/schema/CP_Forecast_Item__c.Retailer__c'
import ROYALTY_RATE from '@salesforce/schema/CP_Forecast_Item__c.Royalty_Rate__c'
import TERRITORY from '@salesforce/schema/CP_Forecast_Item__c.CP_Territory__c'
import FORECAST from '@salesforce/schema/CP_Forecast_Item__c.Forecast__c'
import { loadScript } from 'lightning/platformResourceLoader';
import PARSER from '@salesforce/resourceUrl/CP_CSV_Parser';
//Custom Labels
import maxRows from '@salesforce/label/c.CP_ForecastGridRows';

export default class Cp_forecastingItemGrid extends NavigationMixin(LightningElement) {


    forecastingItemObject = FORECASTING_ITEM_OBJECT
    forecastingItemFields = [
        { fieldAPIName: CONTRACT, Id: '0' },
        { fieldAPIName: CURRENCY, Id: '1' },
        { fieldAPIName: PROPERTY, Id: '2' },
        { fieldAPIName: PRODUCT_TYPE, Id: '3' },
        { fieldAPIName: TERRITORY, Id: '4' },
        { fieldAPIName: RETAILER, Id: '5' },
        { fieldAPIName: REVENUE_TYPE, Id: '6' },
        { fieldAPIName: ROYALTY_RATE, Id: '7' },
        { fieldAPIName: Q1, Id: '8' },
        { fieldAPIName: Q2, Id: '9' },
        { fieldAPIName: Q3, Id: '10' },
        { fieldAPIName: Q4, Id: '11' }
    ]
    @track itemList = [
        {
            id: 0
        }
    ];
    keyIndex = 0
    editedValues = []
    forecastObject = FORECAST
    @api recordId;
    userId = Id;
    @track relatedForecastingItemData = []
    @track errorCount = 0
    @track errorReported = false
    @track loadingSpinner = false
    @track spinnerInModal = false
    @track modalOpen = false
    @track fileUploaded = false
    @track fileData = []
    @track rowShow = false
    @track underValidation = true
    @track submitted = false;
    @track showOptionalNote = false;
    @track deleteButton = false;
    @track cycleClosed = false;
    @track AmountyType = false;
    @track internalUser = false;
    @track pendingApproval = false;
    @track CustomTableloaded = false;
    @track suppressBottomBar = true;
    @track inlineEditing = false;
    @track errorUploadingFiles = false;
    @track quarterValuesChanged = false;
    @track sortBy;
    @track sortDirection;
    @track tableData = [];
    @track tableDataPortal = [];
    @track draftValues = []
    fileName = ''
    lastSavedData = [];
    relatedForecastingItemData = [];
    testTableData = [];
    dummyData = [];
    columnsCustom = [];
    columnsErrorCustom = []
    columnsCustomPortal = [];
    columnsErrorCustomPortal = []
    error;
    fileNotSupported = false;
    @track page = 1;
    @track items = [];
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = maxRows;
    @track totalRecordCount = 0;
    @track totalPage = 0;
    @track pageValue = 1;
    @track pageNumbersOptions = []
    @track nextDisable = false;
    @track prevDisable = false;


    @track columnsStdPortal = [
        { label: '', fieldName: 'RowNumber', initialWidth: 25, editable: false, wrapText: true, sortable: false, type: "number", hideDefaultActions: true },
        { label: 'Contract', fieldName: 'Contract', initialWidth: 94, editable: false, wrapText: true, sortable: true },
        { label: 'Forecast Currency', fieldName: 'ForecastCurrency', initialWidth: 149, editable: false, wrapText: true, sortable: true },
        { label: 'Property Description', fieldName: 'PropertyDescription', initialWidth: 169, editable: false, wrapText: true, sortable: true },
        { label: 'Product Type Description', fieldName: 'ProductTypeDescription', initialWidth: 195, editable: false, wrapText: true, sortable: true },
        { label: 'Territory', fieldName: 'Territory', initialWidth: 94, editable: false, wrapText: true, sortable: true },
        { label: 'Retailer Description', fieldName: 'RetailerDescription', initialWidth: 162, editable: false, wrapText: true, sortable: true },
        { label: 'Revenue Type', fieldName: 'RevenueType', initialWidth: 125, editable: false, wrapText: true, sortable: true },
        { label: 'Royalty Rate %', fieldName: 'RoyaltyRate', initialWidth: 132, editable: false, wrapText: true, sortable: true },
        { label: 'Q1', fieldName: 'Q1', initialWidth: 70, editable: false, wrapText: true, type: "number", sortable: true },
        { label: 'Q2', fieldName: 'Q2', initialWidth: 70, editable: false, wrapText: true, type: "number", sortable: true },
        { label: 'Q3', fieldName: 'Q3', initialWidth: 70, editable: false, wrapText: true, type: "number", sortable: true },
        { label: 'Q4', fieldName: 'Q4', initialWidth: 70, editable: false, wrapText: true, type: "number", sortable: true },
        { label: 'Total Amount', fieldName: 'TotalAmount', initialWidth: 125, editable: false, wrapText: true, type: "number", sortable: true , cellAttributes: { alignment: 'left' }}
    ]

    @track columnsStd = [
        { label: '', fieldName: 'RowNumber', initialWidth: 25, editable: false, wrapText: true, sortable: false, type: "number", hideDefaultActions: true },
        { label: 'Contract', fieldName: 'Contract', initialWidth: 94, editable: false, wrapText: true, sortable: true },
        { label: 'Forecast Currency', fieldName: 'ForecastCurrency', initialWidth: 149, editable: false, wrapText: true, sortable: true },
        { label: 'Property Description', fieldName: 'PropertyDescription', initialWidth: 169, editable: false, wrapText: true, sortable: true },
        { label: 'Product Type Description', fieldName: 'ProductTypeDescription', initialWidth: 195, editable: false, wrapText: true, sortable: true },
        { label: 'Territory', fieldName: 'Territory', initialWidth: 94, editable: false, wrapText: true, sortable: true },
        { label: 'Retailer Description', fieldName: 'RetailerDescription', initialWidth: 162, editable: false, wrapText: true, sortable: true },
        { label: 'Revenue Type', fieldName: 'RevenueType', initialWidth: 125, editable: false, wrapText: true, sortable: true },
        { label: 'Royalty Rate %', fieldName: 'RoyaltyRate', initialWidth: 132, editable: false, wrapText: true, sortable: true },
        { label: 'Q1', fieldName: 'Q1', initialWidth: 70, editable: false, wrapText: true, type: "number", sortable: true },
        { label: 'Q2', fieldName: 'Q2', initialWidth: 70, editable: false, wrapText: true, type: "number", sortable: true },
        { label: 'Q3', fieldName: 'Q3', initialWidth: 70, editable: false, wrapText: true, type: "number", sortable: true },
        { label: 'Q4', fieldName: 'Q4', initialWidth: 70, editable: false, wrapText: true, type: "number", sortable: true },
        { label: 'Q1 Adj', fieldName: 'Q1Adj', initialWidth: 70, editable: false, wrapText: true, type: "number", sortable: true },
        { label: 'Q2 Adj', fieldName: 'Q2Adj', initialWidth: 70, editable: false, wrapText: true, type: "number", sortable: true },
        { label: 'Q3 Adj', fieldName: 'Q3Adj', initialWidth: 70, editable: false, wrapText: true, type: "number", sortable: true },
        { label: 'Q4 Adj', fieldName: 'Q4Adj', initialWidth: 70, editable: false, wrapText: true, type: "number", sortable: true },
        { label: 'Total Amount', fieldName: 'TotalAmount', initialWidth: 125, editable: false, wrapText: true, type: "number", sortable: true, cellAttributes: { alignment: 'left' } }
    ]

    @track columnsSubmitStdPortal = [
        { label: '', fieldName: 'RowNumber', initialWidth: 25, editable: false, wrapText: true, sortable: false, type: "number", hideDefaultActions: true },
        { label: 'Contract', fieldName: 'Contract', initialWidth: 94, editable: false, sortable: true },
        { label: 'Forecast Currency', fieldName: 'ForecastCurrency', initialWidth: 149, editable: false, sortable: true },
        { label: 'Property Description', fieldName: 'PropertyDescription', initialWidth: 169, editable: false, sortable: true },
        { label: 'Product Type Description', fieldName: 'ProductTypeDescription', initialWidth: 195, editable: false, sortable: true },
        { label: 'Territory', fieldName: 'Territory', initialWidth: 94, editable: false, sortable: true },
        { label: 'Retailer Description', fieldName: 'RetailerDescription', initialWidth: 162, editable: false, sortable: true },
        { label: 'Revenue Type', fieldName: 'RevenueType', initialWidth: 125, editable: false, sortable: true },
        { label: 'Royalty Rate %', fieldName: 'RoyaltyRate', initialWidth: 132, editable: false, sortable: true },
        { label: 'Q1', fieldName: 'Q1', initialWidth: 70, editable: false, type: "number", sortable: true },
        { label: 'Q2', fieldName: 'Q2', initialWidth: 70, editable: false, type: "number", sortable: true },
        { label: 'Q3', fieldName: 'Q3', initialWidth: 70, editable: false, type: "number", sortable: true },
        { label: 'Q4', fieldName: 'Q4', initialWidth: 70, editable: false, type: "number", sortable: true },
        { label: 'Total Amount', fieldName: 'TotalAmount', initialWidth: 125, editable: false, type: "number", sortable: true, cellAttributes: { alignment: 'left' } }
    ]

    @track columnsSubmitStd = [
        { label: '', fieldName: 'RowNumber', initialWidth: 25, editable: false, wrapText: true, sortable: false, type: "number", hideDefaultActions: true },
        { label: 'Contract', fieldName: 'Contract', initialWidth: 94, editable: false, sortable: true },
        { label: 'Forecast Currency', fieldName: 'ForecastCurrency', initialWidth: 149, editable: false, sortable: true },
        { label: 'Property Description', fieldName: 'PropertyDescription', initialWidth: 169, editable: false, sortable: true },
        { label: 'Product Type Description', fieldName: 'ProductTypeDescription', initialWidth: 195, editable: false, sortable: true },
        { label: 'Territory', fieldName: 'Territory', initialWidth: 94, editable: false, sortable: true },
        { label: 'Retailer Description', fieldName: 'RetailerDescription', initialWidth: 162, editable: false, sortable: true },
        { label: 'Revenue Type', fieldName: 'RevenueType', initialWidth: 125, editable: false, sortable: true },
        { label: 'Royalty Rate %', fieldName: 'RoyaltyRate', initialWidth: 132, editable: false, sortable: true },
        { label: 'Q1', fieldName: 'Q1', initialWidth: 70, editable: false, type: "number", sortable: true },
        { label: 'Q2', fieldName: 'Q2', initialWidth: 70, editable: false, type: "number", sortable: true },
        { label: 'Q3', fieldName: 'Q3', initialWidth: 70, editable: false, type: "number", sortable: true },
        { label: 'Q4', fieldName: 'Q4', initialWidth: 70, editable: false, type: "number", sortable: true },
        { label: 'Q1 Adj', fieldName: 'Q1Adj', initialWidth: 70, editable: false, type: "number", sortable: true },
        { label: 'Q2 Adj', fieldName: 'Q2Adj', initialWidth: 70, editable: false, type: "number", sortable: true },
        { label: 'Q3 Adj', fieldName: 'Q3Adj', initialWidth: 70, editable: false, type: "number", sortable: true },
        { label: 'Q4 Adj', fieldName: 'Q4Adj', initialWidth: 70, editable: false, type: "number", sortable: true },
        { label: 'Total Amount', fieldName: 'TotalAmount', initialWidth: 125, editable: false, type: "number", sortable: true, cellAttributes: { alignment: 'left' } }
    ]

    @track columnsErrorCustomPortal;

    @track columnsErrorCustom;
    columnsRendered = false;
    scriptLoadedFrromRenderedCallBack = false
    profileInformationLoadedRenderedCallback = false
    validContractsLoaded = false

    

    @wire(getRecord, { recordId: '$recordId', fields: ['CP_Forecast__c.Forecast_Cycle_Status__c'] })
    forecastRecord;

    connectedCallback() {
        if (!this.scriptLoadedFrromRenderedCallBack) {
            loadScript(this, PARSER)
                .then(() => {
                    this.scriptLoadedFrromRenderedCallBack = true;
                    console.log('parser script loaded...')
                })
                .catch(error => console.error(error));
        }
        if (!this.profileInformationLoadedRenderedCallback) {
            var profileName = '';
            getProfile().then((result) => {
                profileName = result
                console.log(result)
                if (profileName.includes('Category Manager') || profileName.includes('System Administrator') || profileName.includes('Global Ops')) {
                    console.log('FROM PROFILES')
                    this.internalUser = true
                }
                this.profileInformationLoadedRenderedCallback = true;
            }).catch((err) => {
                console.log(err)
            })
        }
        if (!this.columnsRendered) {
            this.columnsErrorCustomPortal = [
                { label: '', fieldName: 'RowNumber', initialWidth: 25, editable: false, wrapText: true, sortable: false, type: "number", hideDefaultActions: true },
                {
                    label: 'Error Check', fieldName: 'Errors', initialWidth: 162, editable: false, cellAttributes: {
                        class: { fieldName: 'errorColor' }
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Contract', fieldName: 'Contract', type: 'contract_picklist', initialWidth: 94, typeAttributes: {
                        value: { fieldName: 'Contract' }
                        , context: { fieldName: 'Id' }, recordid: this.recordId,
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Forecast Currency', fieldName: 'ForecastCurrency', type: 'currency_picklist', initialWidth: 149, typeAttributes: {
                        value: { fieldName: 'ForecastCurrency' }
                        , context: { fieldName: 'Id' }
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Property Description', fieldName: 'PropertyDescription', type: 'property_picklist', initialWidth: 169, typeAttributes: {
                        value: { fieldName: 'PropertyDescription' }
                        , context: { fieldName: 'Id' }
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Product Type Description', fieldName: 'ProductTypeDescription', type: 'product_picklist', initialWidth: 195, typeAttributes: {
                        value: { fieldName: 'ProductTypeDescription' }
                        , context: { fieldName: 'Id' }
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Territory', fieldName: 'Territory', type: 'territory_picklist', initialWidth: 94, typeAttributes: {
                        value: { fieldName: 'Territory' }
                        , context: { fieldName: 'Id' }
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Retailer Description', fieldName: 'RetailerDescription', type: 'retailer_picklist', initialWidth: 162, typeAttributes: {
                        value: { fieldName: 'RetailerDescription' }
                        , context: { fieldName: 'Id' }
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Revenue Type', fieldName: 'RevenueType', type: 'revenue_type_picklist', initialWidth: 125, typeAttributes: {
                        value: { fieldName: 'RevenueType' }
                        , context: { fieldName: 'Id' }
                    }, wrapText: true, sortable: true
                },

                { label: 'Royalty Rate %', fieldName: 'RoyaltyRate', initialWidth: 132, editable: true, wrapText: true, sortable: true },
                { label: 'Q1', fieldName: 'Q1', initialWidth: 100, editable: true, wrapText: true, type: "number", sortable: true },
                { label: 'Q2', fieldName: 'Q2', initialWidth: 100, editable: true, wrapText: true, type: "number", sortable: true },
                { label: 'Q3', fieldName: 'Q3', initialWidth: 100, editable: true, wrapText: true, type: "number", sortable: true },
                { label: 'Q4', fieldName: 'Q4', initialWidth: 100, editable: true, wrapText: true, type: "number", sortable: true },
                { label: 'Total Amount', fieldName: 'TotalAmount', initialWidth: 125, editable: false, wrapText: true, type: "number", sortable: true , cellAttributes: { alignment: 'left' }}
            ]
            this.columnsErrorCustom = [
                { label: '', fieldName: 'RowNumber', initialWidth: 25, editable: false, wrapText: true, sortable: false, type: "number", hideDefaultActions: true },
                {
                    label: 'Error Check', fieldName: 'Errors', initialWidth: 150, editable: false, cellAttributes: {
                        class: { fieldName: 'errorColor' }
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Contract', fieldName: 'Contract', type: 'contract_picklist', initialWidth: 94, typeAttributes: {
                        value: { fieldName: 'Contract' }
                        , context: { fieldName: 'Id' }, recordid: this.recordId,
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Forecast Currency', fieldName: 'ForecastCurrency', type: 'currency_picklist', initialWidth: 149, typeAttributes: {
                        value: { fieldName: 'ForecastCurrency' }
                        , context: { fieldName: 'Id' }
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Property Description', fieldName: 'PropertyDescription', type: 'property_picklist', initialWidth: 169, typeAttributes: {
                        value: { fieldName: 'PropertyDescription' }
                        , context: { fieldName: 'Id' }
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Product Type Description', fieldName: 'ProductTypeDescription', type: 'product_picklist', initialWidth: 195, typeAttributes: {
                        value: { fieldName: 'ProductTypeDescription' }
                        , context: { fieldName: 'Id' }
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Territory', fieldName: 'Territory', type: 'territory_picklist', initialWidth: 100, typeAttributes: {
                        value: { fieldName: 'Territory' }
                        , context: { fieldName: 'Id' }
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Retailer Description', fieldName: 'RetailerDescription', type: 'retailer_picklist', initialWidth: 162, typeAttributes: {
                        value: { fieldName: 'RetailerDescription' }
                        , context: { fieldName: 'Id' }
                    }, wrapText: true, sortable: true
                },
                {
                    label: 'Revenue Type', fieldName: 'RevenueType', type: 'revenue_type_picklist', initialWidth: 125, typeAttributes: {
                        value: { fieldName: 'RevenueType' }
                        , context: { fieldName: 'Id' }
                    }, wrapText: true, sortable: true
                },

                { label: 'Royalty Rate %', fieldName: 'RoyaltyRate', initialWidth: 132, editable: true, wrapText: true, sortable: true },
                { label: 'Q1', fieldName: 'Q1', initialWidth: 100, editable: true, wrapText: true, type: "number", sortable: true },
                { label: 'Q2', fieldName: 'Q2', initialWidth: 100, editable: true, wrapText: true, type: "number", sortable: true, sortable: true },
                { label: 'Q3', fieldName: 'Q3', initialWidth: 100, editable: true, wrapText: true, type: "number", sortable: true },
                { label: 'Q4', fieldName: 'Q4', initialWidth: 100, editable: true, wrapText: true, type: "number", sortable: true },
                { label: 'Q1 Adj', fieldName: 'Q1Adj', initialWidth: 100, editable: true, wrapText: true, type: "number", sortable: true },
                { label: 'Q2 Adj', fieldName: 'Q2Adj', initialWidth: 100, editable: true, wrapText: true, type: "number", sortable: true },
                { label: 'Q3 Adj', fieldName: 'Q3Adj', initialWidth: 100, editable: true, wrapText: true, type: "number", sortable: true },
                { label: 'Q4 Adj', fieldName: 'Q4Adj', initialWidth: 100, editable: true, wrapText: true, type: "number", sortable: true },
                { label: 'Total Amount', fieldName: 'TotalAmount', initialWidth: 125, editable: false, wrapText: true, type: "number", sortable: true, cellAttributes: { alignment: 'left' } }
            ]
            console.log('inside conneted callback')
            getForecastingItem({ recordId: this.recordId }).then((result) => {
                console.log('inside conneted callback > get Forecasting Items')
                this.relatedForecastingItemData = result;
                console.log(result)
                if(this.forecastRecord.data){
                    if(this.forecastRecord.data.fields){
                        if(this.forecastRecord.data.fields.Forecast_Cycle_Status__c){
                            if (this.forecastRecord.data.fields.Forecast_Cycle_Status__c.value) {
                                var forecast_cycle_status = (this.forecastRecord.data.fields.Forecast_Cycle_Status__c.value);
                                if (forecast_cycle_status == "Closed") {
                                    this.cycleClosed = true;
                                }
                            }
                        }
                    }
                }
                this.cleanDataFromRelations();
                console.log('outside conneted callback > get Forecasting Items')
            }).catch(error => {
                console.log(error);
            })
            console.log('outside conneted callback')
        }

    }

    cleanDataFromRelations() {
        //console.log(this.forecastRecord.data.fields.Forecast_Status__c.value)
        var forecast_status = ''
        //if(this.forecastRecord.data.fields.Forecast_Status__c.value)
        //   forecast_status = (this.forecastRecord.data.fields.Forecast_Status__c.value)
        var index = 0;
        this.page = 1;
        this.items = [];
        this.startingRecord = 1;
        this.endingRecord = 0;
        this.pageSize = maxRows;
        this.totalRecordCount = 0;
        this.totalPage = 0;
        console.log('inside clean data from relations')
        var recordIdVsDuplicatedToId = new Set();
        this.tableData = [];
        this.errorCount = 0;
        // console.log(JSON.parse(JSON.stringify(this.relatedForecastingItemData)));
        this.relatedForecastingItemData.forEach((fItem) => {
            var cleanRecord = {};
            cleanRecord["RowNumber"] = ++index;
            cleanRecord["Territory"] = fItem["CP_Territory__r"] ? (fItem["CP_Territory__r"].Name ? (fItem["CP_Territory__r"].Name) : "") : ""
            cleanRecord["PropertyDescription"] = fItem["Property__r"] ? (fItem["Property__r"].Name ? fItem["Property__r"].Name : "") : "";
            cleanRecord["RetailerDescription"] = fItem["Retailer__r"] ? (fItem["Retailer__r"].Name ? fItem["Retailer__r"].Name : "") : "";
            cleanRecord["ProductTypeDescription"] = fItem["CP_Product_Type__r"] ? (fItem["CP_Product_Type__r"].Name ? fItem["CP_Product_Type__r"].Name : "") : ""
            cleanRecord["ForecastCurrency"] = fItem["Forecast_Currency__r"] ? (fItem["Forecast_Currency__r"].Name ? fItem["Forecast_Currency__r"].Name : "") : "";
            cleanRecord["Contract"] = fItem["CP_Contract__r"] ? (fItem["CP_Contract__r"].Name ? fItem["CP_Contract__r"].Name : "") : "";
            cleanRecord["RoyaltyRate"] = fItem["Royalty_Rate__c"] ? (fItem["Royalty_Rate__c"] + '%') : "";
            cleanRecord["TotalAmount"] = fItem["Total_Amount__c"] ? fItem["Total_Amount__c"] : "";
            cleanRecord["RevenueType"] = fItem["Revenue_Type__c"] ? fItem["Revenue_Type__c"] : "";
            cleanRecord["Q1"] = fItem["Q1__c"] ? fItem["Q1__c"] : "";
            cleanRecord["Q2"] = fItem["Q2__c"] ? fItem["Q2__c"] : "";
            cleanRecord["Q3"] = fItem["Q3__c"] ? fItem["Q3__c"] : "";
            cleanRecord["Q4"] = fItem["Q4__c"] ? fItem["Q4__c"] : "";
            cleanRecord["Q1Adj"] = fItem["Q1_Adj__c"] ? fItem["Q1_Adj__c"] : "";
            cleanRecord["Q2Adj"] = fItem["Q2_Adj__c"] ? fItem["Q2_Adj__c"] : "";
            cleanRecord["Q3Adj"] = fItem["Q3_Adj__c"] ? fItem["Q3_Adj__c"] : "";
            cleanRecord["Q4Adj"] = fItem["Q4_Adj__c"] ? fItem["Q4_Adj__c"] : "";
            cleanRecord["Id"] = fItem["Id"] ? fItem["Id"] : "";
            cleanRecord["Name"] = fItem["Name"] ? fItem["Name"] : "";
            cleanRecord["Errors"] = fItem["Errors__c"] ? fItem["Errors__c"] : "No Errors";
            if (!fItem["Forecast__r"].Amount_Type__c) {
                this.AmountyType = true;
            }
            if (fItem["Forecast__r"] ? ((fItem["Forecast__r"].Forecast_Cycle__r) ? fItem["Forecast__r"].Forecast_Cycle__r.Status__c == "Closed" : false) : false) {
                this.cycleClosed = true;
                console.log('Cycle Closed');
            }
            forecast_status =  fItem["Forecast__r"] ? ((fItem["Forecast__r"].Forecast_Status__c) ? fItem["Forecast__r"].Forecast_Status__c:""):"";
            //console.log("line 434---"+forecast_status);   
            if (forecast_status == 'Pending Approval') {
                this.pendingApproval = true;
            }
            if (this.internalUser && (forecast_status == 'Submitted' || forecast_status == 'Rejected')) {
                this.submitted = true;
               // console.log('so you are an internal user and the status is Submitted/Rejected.')
            }
            if (!this.internalUser && (forecast_status == 'Pending Approval' || forecast_status == 'Submitted' || forecast_status == 'Rejected')) {
                this.submitted = true;
                //console.log('so you are portal user and the status is Pending Approval/Submitted/Rejected.')
            }
            if (cleanRecord["Errors"].includes('Duplicate')) {
              //  console.log(cleanRecord["Errors"])
             //   console.log(cleanRecord["Id"])
                recordIdVsDuplicatedToId[cleanRecord["Id"]] = cleanRecord["Errors"].slice(15);
                cleanRecord["Errors"] = "Duplicate"
            }
           // console.log('is contract valid:' + fItem["Valid_Contract__c"]);
            if (!fItem["Valid_Contract__c"]) {
                if (cleanRecord["Errors"] == 'No Errors')
                    cleanRecord["Errors"] = 'Invalid Contract';
                else
                    cleanRecord["Errors"] += '\nInvalid Contract';
            }
            else {
                if (cleanRecord["Errors"] == '') {
                    cleanRecord["Errors"] = 'No Errors';
                }
            }
            cleanRecord["errorColor"] = (cleanRecord["Errors"] != 'No Errors') ? 'slds-text-color_error' : 'slds-text-color_success';
            this.errorCount += parseInt((cleanRecord["Errors"] != 'No Errors') ? 1 : 0)
            const status = fItem["Forecast__r"] ? (fItem["Forecast__r"].Forecast_Status__c ? fItem["Forecast__r"].Forecast_Status__c : '') : '';
            this.tableData.push(cleanRecord);
        })
        console.log(this.tableData)
        this.lastSavedData = JSON.parse(JSON.stringify(this.tableData));
        this.loadingSpinner = false
        console.log('outside clean data from relations')
        this.items = this.tableData;
        this.totalRecordCount = this.tableData.length;
        this.totalPage = Math.ceil(this.totalRecordCount / this.pageSize);
        if (this.totalPage == 1) {
            this.nextDisable = true;
            this.prevDisable = true;
        }
        if (this.totalPage > 1) {
            this.prevDisable = true;
            this.nextDisable = false;
        }
        this.tableData = this.items.slice(0, this.pageSize);
        this.endingRecord = this.pageSize;
        console.log(this.totalPage)
        this.pageNumbersOptions = []
        for (var i = 0; i < this.totalPage; i++) {
            let elem = {}
            elem.label = i + 1;
            elem.value = i + 1;
            this.pageNumbersOptions.push(elem);
        }
    }
    overwriteExistingClicked(event) {
        console.log('Overwrite Existing')
        this.spinnerInModal = true
        var dataForApex = this.cleanFileData()
        var recordsToBeDeleted = this.getCurrentRecordIds()
        this.deleteAndReplaceRecords(recordsToBeDeleted, dataForApex)
    }
    getCurrentRecordIds() {
        var Ids = []
        this.items.forEach(item => {
            Ids.push(item["Id"])
        })
        return Ids
    }
    deleteAndReplaceRecords(Ids, data) {
        console.log('Overwriting records')
        deleteForecastingItem({
            recordIds: Ids,
            data: JSON.stringify(data),
            forecastId: this.recordId
        }).then((result) => {
            console.log('Records overwrited')
            this.page = 1;
            this.items = [];
            this.startingRecord = 1;
            this.endingRecord = 0;
            this.pageSize = maxRows;
            this.totalRecordCount = 0;
            this.totalPage = 0;
            this.relatedForecastingItemData = result;
            this.cleanDataFromRelations();
            this.spinnerInModal = false
            this.modalOpen = false
            this.fileUploaded = false
        }).catch(err => {
            console.log('Error:' + err)
            this.spinnerInModal = false
            this.modalOpen = false
            this.fileUploaded = false
            if (this.cycleClosed) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Can not perform operation for CLOSED cycle.',
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
            }
        })
    }
    importClicked(event) {
        console.log('import clicked')
        this.modalOpen = true
    }
    modalClose(event) {
        this.modalOpen = false;
        this.showOptionalNote = false;
        this.fileName = ''
        this.fileUploaded = false;
    }
    uploadedFileHandler(event) {
        this.fileNotSupported = false;
        this.fileUploaded = true;
        this.errorUploadingFiles = false;
        console.log('uploadedFileHandler')
        this.fileName = event.target.files[0].name;
        if (!this.fileName.includes('.csv')) {
            this.fileNotSupported = true;
            this.fileUploaded = false;
        }
        else {
            this.fileNotSupported = false;
            if (event.target.files.length > 0) {
                const file = event.target.files[0];
                Papa.parse(file, {
                    quoteChar: '"',
                    header: 'true',
                    skipEmptyLines: 'greedy',
                    complete: (results) => {
                        if (!this.fileNotSupported)
                            this.fileUploaded = true;
                        console.log(results)
                        console.log(results.data);
                        console.log(results.errors.length)
                        if (results.errors.length) {
                            this.errorUploadingFiles = true;
                        }
                        else {
                            this.fileData = results.data
                        }
                    },
                    error: (error) => {
                        console.error('Error' + error);
                    }
                })
            }
        }
    }
    addToExistingClicked(event) {
        console.log('Add to existing')
        this.spinnerInModal = true
        var dataForApex = this.cleanFileData()
        this.insertFileData(dataForApex)
    }
    cleanFileData() {
        console.log('cleaning file data...')
        var cleanedData = []
        this.fileData.forEach(item => {
            var record = {}
            if (Object.keys(item).length < 10) {
                console.log('Invalid Record: ' + item)
            }
            else {
                //console.log(item["Royalty Rate %"])
                //console.log(parseFloat(item["Royalty Rate %"]))
                record["Royalty_Rate__c"] = parseFloat(parseFloat(item["Royalty Rate %"]).toFixed(2));
                record["Revenue_Type__c"] = item["Revenue Type"]
                record["ForecastCurrency"] = item["Forecast Currency"]
                record["Q1__c"] = item["Q1"] ? (Number(item["Q1"].replaceAll(',', ''))) : 0
                record["Q2__c"] = item["Q2"] ? (Number(item["Q2"].replaceAll(',', ''))) : 0
                record["Q3__c"] = item["Q3"] ? (Number(item["Q3"].replaceAll(',', ''))) : 0
                record["Q4__c"] = item["Q4"] ? (Number(item["Q4"].replaceAll(',', ''))) : 0
                record["PropertyDescription"] = item["Property Description"]
                record["RetailerDescription"] = item["Retailer Description"]
                record["ProductTypeDescription"] = item["Product Type Description"]
                record["Contract"] = item["Contract"]
                // record["AmountType"] = item["Amount Type"]
                // record["BudgetCycle"] = item["Budget Cycle"]
                record["Territory"] = item["Territory"]
                // record["RoyaltyRateType"] = item["Royalty Rate Type"]
                record["Forecast__c"] = this.recordId
                cleanedData.push(record)
            }
        })
        console.log('file data cleaned')
        console.log(cleanedData)
        return cleanedData;
    }
    insertFileData(data) {
        console.log('inserting data...')
        //console.log(JSON.stringify(data));
        createForecastingItem({ data: JSON.stringify(data), forecastId: this.recordId }).then((result) => {
            console.log('Records Inserted');
            // console.log(JSON.parse(JSON.stringify(result)))
            this.relatedForecastingItemData = result;
            this.cleanDataFromRelations();
            // this.tableData = []
            this.spinnerInModal = false;
            this.modalOpen = false;
            this.fileUploaded = false
        }).catch((err) => {
            console.log('Error' + JSON.stringify(err));
            this.spinnerInModal = false;
            this.modalOpen = false;
            this.fileUploaded = false
            if (this.cycleClosed) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Can not perform operation for CLOSED cycle.',
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
            }
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Upload unsuccessful, please check the file and try again.',
                        variant: 'error',
                    })
                );
            }
        });
    }
    validateClicked(event) {
        console.log('validate clicked')
        this.loadingSpinner = true;
        console.log('Validating record records')
        validateForecastItems({
            forecastId: this.recordId
        }).then((result) => {
            console.log('Records validated')
            this.page = 1;
            this.items = [];
            this.startingRecord = 1;
            this.endingRecord = 0;
            this.pageSize = maxRows;
            this.totalRecordCount = 0;
            this.totalPage = 0;
            this.relatedForecastingItemData = result;
            this.cleanDataFromRelations();
            this.spinnerInModal = false
            this.modalOpen = false
            this.fileUploaded = false
            this.errorReported = true;
            this.loadingSpinner = false;
            this.underValidation = false;
        }).catch(err => {
            console.log('Validation failed Error:' + err)
            this.spinnerInModal = false
            this.modalOpen = false
            this.fileUploaded = false
        })
    }
    hideValidations(event) {
        this.errorReported = false;
        this.underValidation = true;
    }
    addRowClicked(event) {
        console.log('add row clicked')
        this.rowShow = true
    }
    addRow() {
        ++this.keyIndex;
        var newItem = [{ id: this.keyIndex }];
        this.itemList = this.itemList.concat(newItem);
    }
    removeRow(event) {
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }
    addData() {
        console.log('adding data...')
        var isVal = true;
        this.loadingSpinner = true
        this.rowShow = false
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal && element.reportValidity();
            // console.log(element);
        });
        if (isVal) {
            this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
                element.submit();
            });
        } else {
            console.log('Error saving data')
        }
        setTimeout(function () {
            getForecastingItem({ recordId: this.recordId }).then((result) => {
                this.relatedForecastingItemData = result
                this.cleanDataFromRelations()
                console.log('Data Added')
            }).catch(error => {
                console.log(error)
                if (this.cycleClosed) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Can not perform operation for CLOSED cycle.',
                            variant: 'error',
                            mode: 'dismissable'
                        })
                    );
                }
            })
        }.bind(this), 3000);
    }
    cancelAddRow() {
        this.rowShow = false;
        this.itemList = [
            {
                id: 0
            }
        ];
        this.keyIndex = 0
    }
    submitClicked(event) {
        console.log('submit clicked')
        this.loadingSpinner = true
        if (this.errorCount != 0) {
            this.loadingSpinner = false
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Can not submit, please remove all the errors before submitting.',
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
        }
        else {
            this.errorReported = false
            var profileName = '';
            getProfile().then((result) => {
                profileName = result
                console.log(result)
                const fields = {};
                fields['Id'] = this.recordId;
                if (profileName === 'CP Partner Community User') {
                    fields['Forecast_Status__c'] = 'Pending Approval'
                }
                else {
                    fields['Forecast_Status__c'] = 'Submitted'
                }
                const recordInput = { fields };
                updateRecord(recordInput)
                    .then(() => {
                        submitForecast({
                            forecastId: this.recordId
                        }).then((result) => {
                            console.log(result)
                            console.log(JSON.parse(JSON.stringify(result)))
                            this.relatedForecastingItemData = result;
                            this.cleanDataFromRelations()
                            this.showOptionalNote = true
                            this.submitted = true
                            if (profileName === 'CP Partner Community User') {
                                this.pendingApproval = true;
                            }
                            this.loadingSpinner = false
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Your Forecast has been successfully submitted.',
                                    variant: 'success'
                                })
                            );
                        }).catch(err => {
                            console.log(err);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Error Occured. Please try again.',
                                    variant: 'error',
                                    mode: 'dismissable'
                                })
                            );
                        })
                    })
                    .catch(error => {
                        console.log((JSON.parse(JSON.stringify(error))));
                        if (this.AmountyType) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Can not submit forecast without Amount Type.',
                                    variant: 'error',
                                    mode: 'dismissable'
                                })
                            );
                        }
                        if (this.cycleClosed) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Can not submit forecast for CLOSED cycle.',
                                    variant: 'error',
                                    mode: 'dismissable'
                                })
                            );
                        }
                        this.loadingSpinner = false
                    });
            }).catch(err => {
                console.log(err);
            })
            this.loadingSpinner = false;
        }
    }
    showDelete() {
        this.deleteButton = true;
    }
    deleteClicked(event) {
        this.loadingSpinner = true
        console.log('delete clicked')
        var idsToBeDeleted = new Set()
        if (this.underValidation)
            var checkedRows = this.template.querySelector('lightning-datatable');
        else
            var checkedRows = this.template.querySelector('c-cp_custom-data-table');
        var selectedRows = JSON.parse(JSON.stringify(checkedRows.selectedRows))
        console.log(selectedRows)
        selectedRows.forEach(element => {
            // console.log(element)
            idsToBeDeleted.add(element)
        })
        console.log(idsToBeDeleted)
        if (this.underValidation)
            this.template.querySelector('lightning-datatable').selectedRows = [];
        else
            this.template.querySelector('c-cp_custom-data-table').selectedRows = [];
        setTimeout(function () {
            deleteForecastingItem({
                recordIds: Array.from(idsToBeDeleted),
                data: 'onlyDelete',
                forecastId: this.recordId
            }).then((result) => {
                console.log(JSON.parse(JSON.stringify(result)))
                this.relatedForecastingItemData = result;
                this.cleanDataFromRelations()
                this.loadingSpinner = false
                this.deleteButton = false;
            }).catch(err => {
                console.log(err)
                this.loadingSpinner = false;
                if (this.cycleClosed) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Can not perform operation for CLOSED cycle.',
                            variant: 'error',
                            mode: 'dismissable'
                        })
                    );
                }
            })
        }.bind(this), 1000);
    }
    updateDataValues(updateItem) {
        console.log('in update data values')
        let copyData = [... this.tableData];
        console.log(copyData)
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });

        //write changes back to original data
        this.data = [...copyData];
        console.log(this.data)
    }

    updateDraftValues(updateItem) {
        console.log('in update draft values')
        this.inlineEditing = true;
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        console.log(copyDraftValues)
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });

        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
            console.log(this.draftValues)
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
            console.log(this.draftValues)
        }
    }

    //listener handler to get the context and data
    //updates datatable

    retailerPicklistChanged(event) {
        console.log('in retailer picklist changed')
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log(dataRecieved)
        console.log(dataRecieved.value)
        console.log(dataRecieved.Id)
        let updatedItem;
        updatedItem = { Id: dataRecieved.Id, RetailerDescription: dataRecieved.value };
        console.log(updatedItem)
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }
    contractPicklistChanged(event) {
        console.log('in contract picklist changed')
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log(dataRecieved)
        console.log(dataRecieved.value)
        console.log(dataRecieved.Id)
        console.log(this.validContracts)
        console.log(dataRecieved.value)
        let updatedItem;
        updatedItem = { Id: dataRecieved.Id, Contract: dataRecieved.value };
        console.log(updatedItem)
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }
    currencyPicklistChanged(event) {
        console.log('in currency picklist changed')
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log(dataRecieved)
        console.log(dataRecieved.value)
        console.log(dataRecieved.Id)
        let updatedItem;
        updatedItem = { Id: dataRecieved.Id, ForecastCurrency: dataRecieved.value };
        console.log(updatedItem)
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }
    productPicklistChanged(event) {
        console.log('in product picklist changed')
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log(dataRecieved)
        console.log(dataRecieved.value)
        console.log(dataRecieved.Id)
        let updatedItem;
        updatedItem = { Id: dataRecieved.Id, ProductTypeDescription: dataRecieved.value };
        console.log(updatedItem)
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }
    propertyPicklistChanged(event) {
        console.log('in property picklist changed')
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log(dataRecieved)
        console.log(dataRecieved.value)
        console.log(dataRecieved.Id)
        let updatedItem;
        updatedItem = { Id: dataRecieved.Id, PropertyDescription: dataRecieved.value };
        console.log(updatedItem)
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }
    territoryPicklistChanged(event) {
        console.log('in territory picklist changed')
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log(dataRecieved)
        console.log(dataRecieved.value)
        console.log(dataRecieved.Id)
        let updatedItem;
        updatedItem = { Id: dataRecieved.Id, Territory: dataRecieved.value };
        console.log(updatedItem)
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }
    revenueTypePicklistChanged(event) {
        console.log('in revenue type picklist changed')
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log(dataRecieved)
        console.log(dataRecieved.value)
        console.log(dataRecieved.Id)
        let updatedItem;
        updatedItem = { Id: dataRecieved.Id, RevenueType: dataRecieved.value };
        console.log(updatedItem)
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    handleSelection(event) {
        event.stopPropagation();
        console.log('in handle selection')
        let dataRecieved = event.detail.data;
        let updatedItem = { Id: dataRecieved.key, ParentId: dataRecieved.selectedId };
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        console.log('in handle cell change')
        console.log(event.detail.draftValues[0])
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    handleSave(event) {
        console.log('in handle save')
        console.log('Updated items', this.draftValues);
        //save last saved copy
        this.lastSavedData = JSON.parse(JSON.stringify(this.tableData));
        console.log(JSON.parse(JSON.stringify(this.draftValues)))
        console.log(this.tableData)

        this.saveChangesDatatable(JSON.parse(JSON.stringify(this.draftValues)))

        this.draftValues = [];
        this.inlineEditing = false;
    }

    handleCancel(event) {
        //remove draftValues & revert data changes
        console.log('in handle cancel')
        this.tableData = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
        this.inlineEditing = false;
    }
    saveChangesDatatable(editedValues) {
        if (this.cycleClosed) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Can not perform operation for CLOSED cycle.',
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
        }
        else {
            console.log('saving changes...')
            this.loadingSpinner = true
            var recordsToBeUpdated = []
            // this.editedValues = JSON.parse(JSON.stringify(event.detail.draftValues));
            console.log(editedValues)
            editedValues.forEach(item => {
                var record = {}
                // console.log(item)
                record["Id"] = item.Id
                console.log(item)
                if (item["Territory"] != undefined)
                    record["Territory"] = item["Territory"]
                if (item["RetailerDescription"] != undefined)
                    record["RetailerDescription"] = item["RetailerDescription"]
                if (item["ForecastCurrency"] != undefined)
                    record["ForecastCurrency"] = item["ForecastCurrency"]
                if (item["PropertyDescription"] != undefined)
                    record["PropertyDescription"] = item["PropertyDescription"]
                if (item["Contract"] != undefined)
                    record["Contract"] = item["Contract"]
                if (item["ProductTypeDescription"] != undefined)
                    record["ProductTypeDescription"] = item["ProductTypeDescription"]
                if (item["RevenueType"] != undefined)
                    record["Revenue_Type__c"] = item["RevenueType"]
                if (item["RoyaltyRate"] != undefined)
                    record["Royalty_Rate__c"] = parseFloat(item["RoyaltyRate"]) ? parseFloat(item["RoyaltyRate"]) : 0;
                if (item["Q1"] != undefined) {
                    this.quarterValuesChanged = true;
                    record["Q1__c"] = Number(item["Q1"])
                }
                if (item["Q2"] != undefined) {
                    this.quarterValuesChanged = true;
                    record["Q2__c"] = Number(item["Q2"])
                }
                if (item["Q3"] != undefined) {
                    this.quarterValuesChanged = true;
                    record["Q3__c"] = Number(item["Q3"])
                }
                if (item["Q4"] != undefined) {
                    this.quarterValuesChanged = true;
                    record["Q4__c"] = Number(item["Q4"])
                }
                if (item["Q1Adj"] != undefined) {
                    this.quarterValuesChanged = true;
                    record["Q1_Adj__c"] = Number(item["Q1Adj"])
                }
                if (item["Q2Adj"] != undefined) {
                    this.quarterValuesChanged = true;
                    record["Q2_Adj__c"] = Number(item["Q2Adj"])
                }
                if (item["Q3Adj"] != undefined) {
                    this.quarterValuesChanged = true;
                    record["Q3_Adj__c"] = Number(item["Q3Adj"])
                }
                if (item["Q4Adj"] != undefined) {
                    this.quarterValuesChanged = true;
                    record["Q4_Adj__c"] = Number(item["Q4Adj"])
                }
                //console.log(record)
                recordsToBeUpdated.push(record);
            })
            console.log(JSON.stringify(recordsToBeUpdated))
            setTimeout(function () {
                updateForecastingItem({
                    data: JSON.stringify(recordsToBeUpdated),
                    forecastId: this.recordId
                }).then((result) => {
                    console.log(JSON.parse(JSON.stringify(result)))
                    this.relatedForecastingItemData = result
                    this.cleanDataFromRelations();
                    this.loadingSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record updated',
                            variant: 'success'
                        })
                    );
                    console.log('Data updated')
                    if (this.quarterValuesChanged) {
                        window.location.reload();
                        this.quarterValuesChanged = false;
                    }
                }).catch(err => {
                    console.log(err);
                    this.loadingSpinner = false;
                })
            }.bind(this), 1000);
        }
    }
    maximizeDatatable() {
        /*
        https://wb--cptechup.lightning.force.com
        https://cptechup-wbpartner.cs195.force.com
        */
        if (window.location.origin.includes('lightning')) {
            this[NavigationMixin.Navigate]({
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__CP_MaximizedForecastingItemGrid",
                },
                state: {
                    c__recordId: this.recordId
                }
            });
        }
        if (!window.location.origin.includes('lightning')) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'maximized_grid_view__c'
                },
                state: {
                    recordId: this.recordId
                }
            })
        }
    }
    minimizeDatatable() {
        if (window.location.origin.includes('lightning')) {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'CP_Forecast__c',
                    actionName: 'view'

                },
            });
        }
        if (!window.location.origin.includes('lightning')) {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'CP_Forecast__c',
                    actionName: 'view'

                },
            });
        }
    }
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        Array.prototype.sortBy = function (p, dir) {
            if (dir == 'asc') {
                return this.slice(0).sort(function (a, b) {
                    return (a[p] > b[p]) ? 1 : (a[p] < b[p]) ? -1 : 0;
                });
            }
            else {
                return this.slice(0).sort(function (a, b) {
                    return (a[p] < b[p]) ? 1 : (a[p] > b[p]) ? -1 : 0;
                });
            }
        }
        console.log(direction)
        this.items = this.items.sortBy(fieldname, direction);
        //console.log('!!' + this.startingRecord);
        //console.log('!!' + this.endingRecord);
        /*
        10 records per page, 45 records
        this.page 1 record-0-9
        this.page 2 record-10-19
        this.page 3 record 20-29
        this.page 4 record-30-29
        this.page 5 record-40-44
        */
        // var start = (this.page - 1) * this.pageSize;
        // var end = this.page*this.pageSize
        this.tableData = this.items.slice(((this.page - 1) * this.pageSize), this.page * this.pageSize);
        console.log(this.tableData)
    }
    mergeClicked(event) {
        if (this.cycleClosed) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Can not perform operation for CLOSED cycle.',
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
        }
        else {
            console.log('merge clicked')
            this.loadingSpinner = true
            console.log('merge clicked')
            var idsToBeMerged = new Set()
            if (this.underValidation)
                var checkedRows = this.template.querySelector('lightning-datatable');
            else
                var checkedRows = this.template.querySelector('c-cp_custom-data-table');
            var selectedRows = JSON.parse(JSON.stringify(checkedRows.selectedRows))
            console.log(selectedRows)
            selectedRows.forEach(element => {
                // console.log(element)
                idsToBeMerged.add(element)
            })
            console.log(idsToBeMerged)
            if (this.underValidation)
                this.template.querySelector('lightning-datatable').selectedRows = [];
            else
                this.template.querySelector('c-cp_custom-data-table').selectedRows = [];
            if (idsToBeMerged.size == 1) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'One record can not be merged. Please try again',
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
                this.loadingSpinner = false
                return;
            }
            setTimeout(function () {
                mergeSelectedRows({
                    listOfRecordIds: Array.from(idsToBeMerged),
                    forecastId: this.recordId
                }).then((result) => {
                    console.log(result)
                    if (!result) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'The records you are tring to merge are not duplicate to each other (Make sure that the Currency sould also be same).',
                                variant: 'error',
                                mode: 'dismissable'
                            })
                        );
                        this.loadingSpinner = false
                    }
                    else {
                        console.log(JSON.parse(JSON.stringify(result)))
                        this.relatedForecastingItemData = result;
                        this.cleanDataFromRelations()
                        this.loadingSpinner = false
                        this.deleteButton = false;
                    }
                }).catch(err => {
                    console.log(err)
                    this.loadingSpinner = false;
                    if (this.cycleClosed) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Can not perform operation for CLOSED cycle.',
                                variant: 'error',
                                mode: 'dismissable'
                            })
                        );
                    }
                })
            }.bind(this), 1000);
        }
    }
    previousHandler() {
        this.nextDisable = false;
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
        if (this.page == 1) {
            this.prevDisable = true;
        }
    }
    nextHandler() {
        this.prevDisable = false;
        console.log('CURRENT PAGE #:' + this.page);
        console.log('TOTAL PAGES:' + this.totalPage);
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
        }
        if (this.page == this.totalPage) {
            this.nextDisable = true;
        }
    }
    displayRecordPerPage(page) {

        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecordCount)
            ? this.totalRecordCount : this.endingRecord;

        this.tableData = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    }
    pageChangeHandler(event) {
        var valueSelected = event.detail.value;
        console.log(valueSelected)
        this.page = parseInt(valueSelected);
        this.displayRecordPerPage(this.page);
        if (this.page == this.totalPage) {
            this.nextDisable = true;
            this.prevDisable = false;
        }
        else if (this.page == 1) {
            this.prevDisable = true;
            this.nextDisable = false;
        }
        else {
            this.nextDisable = false
            this.prevDisable = false;
        }
    }
}