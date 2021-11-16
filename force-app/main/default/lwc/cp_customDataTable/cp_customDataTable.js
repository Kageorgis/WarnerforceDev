import LightningDatatable from 'lightning/datatable';
import ContractPicklistTemplate from './contract-picklist-template.html';
import ProductPicklistTemplate from './product-picklist-template.html';
import PropertyPicklistTemplate from './property-picklist-template.html';
import CurrencyPicklistTemplate from './currency-picklist-template.html';
import RetailerPicklistTemplate from './retailer-picklist-template.html';
import TerritoryPicklistTemplate from './territory-picklist-template.html';
import RevenuePicklistTemplate from './revenue-picklist-template.html';
import { loadStyle } from 'lightning/platformResourceLoader';
import CustomDataTableResource from '@salesforce/resourceUrl/CP_CustomDataTable';

export default class Cp_customDataTablePOC extends LightningDatatable {
    static customTypes = {
        contract_picklist: {
            template: ContractPicklistTemplate,
            typeAttributes: ['value', 'context', 'recordid'],
        },
        product_picklist: {
            template: ProductPicklistTemplate,
            typeAttributes: ['value', 'context'],
        },
        property_picklist: {
            template: PropertyPicklistTemplate,
            typeAttributes: ['value', 'context'],
        },
        currency_picklist: {
            template: CurrencyPicklistTemplate,
            typeAttributes: ['value', 'context'],
        },
        retailer_picklist: {
            template: RetailerPicklistTemplate,
            typeAttributes: ['value', 'context'],
        },
        territory_picklist: {
            template: TerritoryPicklistTemplate,
            typeAttributes: ['value', 'context'],
        },
        revenue_type_picklist: {
            template: RevenuePicklistTemplate,
            typeAttributes: ['value', 'context'],
        },
    };

    constructor() {
        super();
        console.log('inside constructor of custom data table')
        Promise.all([
            loadStyle(this, CustomDataTableResource),
        ]).then(() => {})
    }
}