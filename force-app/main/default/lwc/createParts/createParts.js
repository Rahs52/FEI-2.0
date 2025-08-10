import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createSalesOrderAndBillingForParts from '@salesforce/apex/CounterSalesController.createSalesOrderAndBillingForParts';

export default class CreateParts extends LightningElement {
    // PUBLIC ATTRIBUTES
    @api counterSalesType; 
    @api productFeesList;
    @api priceBookEntriesList;
    @api accountId;

    // PRIVATE ATTRIBUTES 
    _pageNumber;
    _salesOrder;
    _productFeesList;
    _selectedProductFee;
    _productsList;
    _columnsList;
    _selectedRowIds;
    _selectedSalesOrderLinesList;

    /**
    * @description Constructor
    **/
    constructor() {
        super();
        this._pageNumber = 1;
        this._salesOrder = {};
        this._selectedProductFee = '';
        this._columnsList = new Array();
    }

    /**
    * @description Connected Callback
    **/
    connectedCallback() {
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
    * @description Method to handle fee change
    **/
    handleFeeChange(event) {
        this._selectedProductFee = event.target.value;
    }

    /**
    * @description Method to handle Next action
    **/
    handleNext() {
        if (this._pageNumber == 1) {
        } else if (this._pageNumber == 2) {
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
        } else if (this._pageNumber == 3) {
            this._selectedSalesOrderLinesList = new Array();
            this.priceBookEntriesList.forEach(priceBookEntry => {
                if (this._selectedRowIds.indexOf(priceBookEntry.Id) != -1) {
                    this._selectedSalesOrderLinesList.push(
                        {
                            'AcctSeedERP__Product__c'  : priceBookEntry.Product2Id,
                            'Name' : priceBookEntry.Product2.Name,
                            'AcctSeedERP__Unit_Price__c' : priceBookEntry.UnitPrice,
                            'AcctSeedERP__Quantity_Ordered__c' : 0.00,
                            'AcctSeedERP__Comment__c' : ''
                        }
                    );
                }
            });
        }
        this._pageNumber++;
    }

    /**
    * @description Method to get handle cancel
    **/
    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    /**
    * @description Method to handle on selected rows
    **/
    handleSelectedRows(event) {
        this._selectedRowIds = event.detail.selectedRowIds;
    }

    /**
    * @description Method to update quantity
    **/
    handleOnQuantityChange(event) {
        this._selectedSalesOrderLinesList.find((item, index) => index == event.currentTarget.dataset.index).AcctSeedERP__Quantity_Ordered__c = event.target.value;
    }

    /**
    * @description Method to update unit price
    **/
    handleOnUnitPriceChange(event) {
        this._selectedSalesOrderLinesList.find((item, index) => index == event.currentTarget.dataset.index).AcctSeedERP__Unit_Price__c = event.target.value;
    }

    /**
    * @description Method to update unit price
    **/
    handleOnCommentChange(event) {
        this._selectedSalesOrderLinesList.find((item, index) => index == event.currentTarget.dataset.index).AcctSeedERP__Comment__c = event.target.value;
    }

    /**
    * @description Method to handle finish
    **/
    handleFinish() {
        this.handleSave(false);
    }

    /**
    * @description Method to handle finish
    **/
    handleCreateBilling() {
        this.handleSave(true);
    }

    /**
    * @description Method to handle save
    **/
    handleSave(createBilling) {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            this.template.querySelector('lightning-spinner').classList.remove('slds-hide');
            this._selectedSalesOrderLinesList.forEach(salesOrderLine => {
                delete salesOrderLine.Name;
            });
            if (this._selectedProductFee) {
                let unitPrice = 0.00;
                let selectedProduct  = this.productFeesList.find(product => product.Id == this._selectedProductFee);
                if (selectedProduct && selectedProduct.PricebookEntries) {
                    unitPrice = selectedProduct.PricebookEntries[0].UnitPrice;
                }
                this._selectedSalesOrderLinesList.push({
                    'AcctSeedERP__Product__c'  : this._selectedProductFee,
                    'AcctSeedERP__Unit_Price__c' : unitPrice,
                    'AcctSeedERP__Quantity_Ordered__c' : 1.00,
                });
            }
            createSalesOrderAndBillingForParts({
                accountId : this.accountId,
                salesOrderJSON : JSON.stringify(this._salesOrder),
                salesOrderLinesJSON : JSON.stringify(this._selectedSalesOrderLinesList),
                createBilling : createBilling
            }).then(result => {
                // show success message
                this.dispatchEvent(
                    new ShowToastEvent({
                        "message" : 'Sales Order '+(createBilling ? 'and billing' : '')+' has been created sucessfully.',
                        "variant" : 'success'
                    }),
                );
                this.dispatchEvent(new CustomEvent('partscreate',{
                    detail: {
                        salesOrderId : result.salesOrderId,
                        selectedFeeProduct : this._selectedProductFee
                    }
                }));
                this.template.querySelector('lightning-spinner').classList.add('slds-hide');
            }).catch(error => {
                this.error = error;
                this.template.querySelector('lightning-spinner').classList.add('slds-hide');
            });
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
    * @description Method to show the fourth page
    **/
    get fourthPage() {
        return this._pageNumber == 4;
    } 
}