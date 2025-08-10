import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getServiceAndItemProducts from '@salesforce/apex/CounterSalesController.getServiceAndItemProducts';
import createServiceItemLines from '@salesforce/apex/CounterSalesController.createServiceItemLines';

export default class CreateServiceItems extends LightningElement {
    // PUBLIC ATTRIBUTES
    @api recordId; 

    // PRIVATE ATTRIBUTES 
    _pageNumber;
    _priceBookEntriesList;
    _selectedProductType;
    _productTypesList;
    _columnsList;
    _selectedRowIds;
    _filteredProductsList;
    _serviceItemLinesList;

    /**
    * @description Constructor
    **/
    constructor() {
        super();
        this._priceBookEntriesList = new Array();
        this._serviceItemLinesList = new Array();
        this._selectedRowIds = new Array();
        this._productTypesList = [
            {
                'label' : '-Choose--',
                'value' : ''
            },
            {
                'label' : 'Items',
                'value' : 'Items'
            },
            {
                'label' : 'Service',
                'value' : 'Service'
            }
        ];
        this._columnsList = [
            {
                'label' : 'Product Name',
                'name' : 'Product2.Name',
                'type' : 'link',
                'idField' : 'Product2Id'
            },
            {
                'label' : 'Product Code',
                'name' : 'Product2.ProductCode',
                'type' : 'text'
            },
            {
                'label' : 'List Price',
                'name' : 'UnitPrice',
                'type' : 'currency'
            },
            {
                'label' : 'Product Description',
                'name' : 'Product2.Description',
                'type' : 'text'
            }
        ];
    }

    /**
    * @description Wire method to get the record id
    **/
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && this.recordId === undefined) {
            this.recordId = currentPageReference.state.recordId;
            this.getServiceAndItemProducts();
        } 
    }

    /**
    * @description Method to get service item and products
    **/
    getServiceAndItemProducts() {
        getServiceAndItemProducts({
            serviceItemId : this.recordId
        }).then(result => {
            if (result) {
                if (result.hasOwnProperty('priceBookEntriesList')) {
                    this._priceBookEntriesList = result.priceBookEntriesList;
                }
                this._pageNumber = 1;
            }
            this.template.querySelector('lightning-spinner').classList.add('slds-hide');
        }).catch(error => {
            this.error = error;
            this.template.querySelector('lightning-spinner').classList.add('slds-hide');
        })
    }

    /**
    * @description Method to set page number
    **/
    @api
    setPageNumber(pageNumber) {
        this._pageNumber = pageNumber;
    }

    /**
    * @description Method to handle fee change
    **/
    handleProductTypeChange(event) {
        this._selectedProductType = event.target.value;
        this._filteredProductsList = this._priceBookEntriesList.filter(priceBookEntry => priceBookEntry.Product2.Family.startsWith(this._selectedProductType));
    }

    /**
    * @description Method to handle on selected rows
    **/
    handleSelectedRows(event) {
        this._selectedRowIds = event.detail.selectedRowIds;
    }

    /**
    * @description Method to get handle cancel
    **/
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    /**
    * @description Method to handle save
    **/
    handleSave() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            this.template.querySelector('lightning-spinner').classList.remove('slds-hide');
            this._serviceItemLinesList.forEach(serviceItemLine => {
                delete serviceItemLine.Name;
            });
            createServiceItemLines({
                serviceItemId : this.recordId,
                serviceItemLinesJSON : JSON.stringify(this._serviceItemLinesList)
            }).then(result => {
                // show success message
                this.dispatchEvent(
                    new ShowToastEvent({
                        "message" : 'Service Item Lines has been created sucessfully.',
                        "variant" : 'success'
                    }),
                );
                this.dispatchEvent(new CloseActionScreenEvent());
                this.template.querySelector('lightning-spinner').classList.add('slds-hide');
            }).catch(error => {
                this.error = error;
                this.template.querySelector('lightning-spinner').classList.add('slds-hide');
            });
        }
    }

    /**
    * @description Method to handle Next action
    **/
    handleNext() {
        if (this._pageNumber == 1) {
            this._serviceItemLinesList = new Array();
            this._priceBookEntriesList.forEach(priceBookEntry => {
                if (this._selectedRowIds.indexOf(priceBookEntry.Id) != -1) {
                    this._serviceItemLinesList.push({
                        'Product__c' : priceBookEntry.Product2Id,
                        'Name' : priceBookEntry.Product2.Name,
                        'UnitPrice__c' : priceBookEntry.UnitPrice,
                        'Quantity__c' : 0.00,
                        'Notes__c' : ''
                    });
                }
            });
        }
        this._pageNumber++;
    }

    /**
    * @description Method to update quantity
    **/
    handleOnQuantityChange(event) {
        this._serviceItemLinesList.find((item, index) => index == event.currentTarget.dataset.index).Quantity__c	 = event.target.value;
    }

    /**
    * @description Method to update unit price
    **/
    handleOnUnitPriceChange(event) {
        this._serviceItemLinesList.find((item, index) => index == event.currentTarget.dataset.index).UnitPrice__c = event.target.value;
    }

    /**
    * @description Method to update unit price
    **/
    handleOnCommentChange(event) {
        this._serviceItemLinesList.find((item, index) => index == event.currentTarget.dataset.index).Notes__c = event.target.value;
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
}