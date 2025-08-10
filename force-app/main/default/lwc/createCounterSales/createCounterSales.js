import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { loadStyle } from "lightning/platformResourceLoader";
import CounterSalesResource from "@salesforce/resourceUrl/CounterSales";
import getCounterSalesInformation from '@salesforce/apex/CounterSalesController.getCounterSalesInformation';

export default class CreateCounterSales extends LightningElement {
    // PUBLIC ATTRIBUTES
    @api recordId; 

    // PRIVATE ATTRIBUTES 
    _pageNumber;
    _selectedCounterSalesType;
    _createPartsPageNumber;
    _partsSelected;
    _serviceSelected;
    _productFeesList;
    _priceBookEntriesList;
    _salesOrderId;
    _selectedProductFee;

    /**
    * @description Constructor
    **/
    constructor() {
        super();
        this._selectedCounterSalesType = '';
        this._salesOrderId = '';
        this._createPartsPageNumber = 1;
        this._partsSelected = false;
        this._serviceSelected = false;
        this._productFeesList = new Array();
        this._priceBookEntriesList = new Array();
    }

    /**
    * @description Connnected Callback method
    **/
    connectedCallback() {
        // Promise.all([
        //     loadStyle(this, CounterSalesResource)
        // ]);
    }

    /**
    * @description Wire method to get the record id
    **/
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && this.recordId === undefined) {
            this.recordId = currentPageReference.state.recordId;
            this.getCounterSalesInformation();
        } 
    }

    /**
    * @description Method to fetch counter sales information
    **/
    getCounterSalesInformation() {
        getCounterSalesInformation({
            'accountId' : this.recordId
        }).then(result => {
            if (result) {
                if (result.hasOwnProperty('productFeesList')) {
                    this._productFeesList = result.productFeesList;
                }
                if (result.hasOwnProperty('priceBookEntriesList')) {
                    this._priceBookEntriesList = result.priceBookEntriesList;
                }
                this._pageNumber = 1;
            }
            this._hasLoaded = true;
            this.template.querySelector('lightning-spinner').classList.add('slds-hide');
        }).catch(error => {
            this.error = error;
            this.template.querySelector('lightning-spinner').classList.add('slds-hide');
        });
    }

    /**
    * @description Method to handle on parts create
    **/
    handlePartsCreate(event) {
        if (this._serviceSelected) {
            this._salesOrderId = event.detail.salesOrderId;
            this._selectedProductFee = event.detail.selectedFeeProduct;
            this._pageNumber++;
        } else {
            this.handleCancel();
        }
    }

    /**
    * @description Method to handle on service create
    **/
    handleServiceCreate() {
        this.handleCancel();
    }

    /**
    * @description Method to get handle cancel
    **/
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    /**
    * @description Method to handle counter type sales change
    **/
    handleCounterSalesTypeChange(event) {
        this._selectedCounterSalesType = event.detail.value;
        this._partsSelected = this._selectedCounterSalesType == 'Parts Only' || this._selectedCounterSalesType == 'Service & Parts';
        this._serviceSelected = this._selectedCounterSalesType == 'Service Only' || this._selectedCounterSalesType == 'Service & Parts';
    }

    /**
    * @description Method to handle Next action
    **/
    handleNext() {
        if (this._pageNumber == 1) {
            this._pageNumber++;
        } else if (this._pageNumber == 2) {
            
        }
    }

    /**
    * @description Method to show the first page
    **/
    get firstPage() {
        return this._pageNumber == 1;
    } 

    /**
    * @description Method to show the second page
    **/
    get secondPage() {
        return this._pageNumber == 2;
    } 

    /**
    * @description Method to show the third page
    **/
    get thirdPage() {
        return this._pageNumber == 3;
    } 

    /**
    * @description Method to show parts
    **/
    get showParts() {
        return this._pageNumber == 2 && this._partsSelected;
    } 

    /**
    * @description Method to show service
    **/
    get showService() {
        return (this._pageNumber == 3 && this._partsSelected === true) || (this._pageNumber == 2 && this._partsSelected === false);
    } 
}