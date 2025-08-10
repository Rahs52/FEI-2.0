import { LightningElement,  api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createSalesOrderAndServiceItem from '@salesforce/apex/CounterSalesController.createSalesOrderAndServiceItem';

export default class CreateService extends LightningElement {

    // PUBLIC ATTRIBUTES
    @api accountId;
    @api productFeesList;
    @api counterSalesType; 
    @api pageNumber;
    @api salesOrderId;
    @api selectedProductFee;

    // PRIVATE ATTRIBUTES 
    _pageNumber;
    _salesOrder;
    _serviceItem;
    _productFeesList;
    _salesOrderLinesList;
    _selectedProductFee;

    /**
    * @description Constructor
    **/
    constructor() {
        super();
        this._pageNumber = 1;
        this._salesOrder = {};
        this._serviceItem = {};
    }

    /**
    * @description Connected Callback
    **/
    connectedCallback() {
        this._pageNumber = this.pageNumber ? this.pageNumber : 1;
        this._salesOrder = this.salesOrderId ? {'Id':this.salesOrderId} : {};
        this._selectedProductFee = this.selectedProductFee ? this.selectedProductFee : '';
        this.setProductFeesList();
    }

    /**
    * @description Method to set product fees list
    **/
    setProductFeesList() {
        this._productFeesList = new Array();
        if (this.productFeesList) {
            this._productFeesList.push({
                'label' : '-Choose--',
                'value' : '',
                'description' : ''
            });
            this.productFeesList.forEach(product => {
                this._productFeesList.push({
                    'label' : product.Name,
                    'value' : product.Id
                });
            });
        }
    }

    /**
    * @description Method to handle field change
    **/
    handleFieldChange(event) {
        this._salesOrder[event.target.dataset.field] = event.target.value;
    }

    /**
    * @description Method to handle service item field change
    **/
    handleServiceItemFieldChange(event) {
        this._serviceItem[event.target.dataset.field] = event.target.value;
    }

    /**
    * @description Method to handle fee change
    **/
    handleFeeChange(event) {
        this._selectedProductFee = event.target.value;
    }

    /**
    * @description Method to handle Next action
    **/
    handleNext() {
        this._pageNumber++;
    }

    /**
    * @description Method to get handle cancel
    **/
    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    /**
    * @description Method to handle save
    **/
    handleFinish() {
        this.template.querySelector('lightning-spinner').classList.remove('slds-hide');
        let serviceItemLinesList = new Array();
        if (this._selectedProductFee) {
            let unitPrice = 0.00;
            let selectedProduct  = this.productFeesList.find(product => product.Id == this._selectedProductFee);
            if (selectedProduct && selectedProduct.PricebookEntries) {
                unitPrice = selectedProduct.PricebookEntries[0].UnitPrice;
            }
            serviceItemLinesList.push({
                'Product__c'  : this._selectedProductFee,
                'UnitPrice__c' : unitPrice,
                'Quantity__c' : 1.00,
            });
        }
        console.log('Sales Order is '+this._salesOrder);
        createSalesOrderAndServiceItem({
            accountId : this.accountId,
            salesOrderJSON : JSON.stringify(this._salesOrder),
            serviceItemJSON : JSON.stringify(this._serviceItem),
            serviceItemLinesJSON : JSON.stringify(serviceItemLinesList)
        }).then(result => {
            // show success message
            this.dispatchEvent(
                new ShowToastEvent({
                    "message" : 'Sales Order and service item has been created sucessfully.',
                    "variant" : 'success'
                }),
            );
            this.dispatchEvent(new CustomEvent('servicecreate'));
            this.template.querySelector('lightning-spinner').classList.add('slds-hide');
        }).catch(error => {
            this.error = error;
            this.template.querySelector('lightning-spinner').classList.add('slds-hide');
        });
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
}