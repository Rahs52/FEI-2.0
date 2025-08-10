/**
* @description : Apex class to manage billing
**/
public with sharing class Billing {
    
    public SVMXC__Service_Order__c workOrder;
    public List<SVMXC__Service_Order_Line__c> workOrderLinesList;
    private Map<Id, PriceBookEntry> priceBookEntryMap;
    public AcctSeed__Billing__c billing;
    public List<AcctSeed__Billing_Line__c> billingLinesList;
    public Boolean createBilling;

    /**
    * @description : Constructor
    **/
    public Billing(SVMXC__Service_Order__c workOrder, Map<Id, PriceBookEntry> priceBookEntryMap) {
        this.workOrder = workOrder;
        this.workOrderLinesList = this.workOrder.SVMXC__Service_Order_Line__r;
        this.priceBookEntryMap = priceBookEntryMap;
        this.billingLinesList = new List<AcctSeed__Billing_Line__c>();
        this.createBilling = true;

        // create Billing 
        createBilling();

        // create billing lines
        createBillingLines();
    }

    /**
    * @description :  Method to create billing
    **/
    public void createBilling() {
        this.billing = new AcctSeed__Billing__c(
            AcctSeed__Customer__c = this.workOrder.SVMXC__Company__c,
            AcctSeed__Date__c = System.today(),
            AcctSeed__Status__c = 'Approved',
            WorkOrder__c = this.workOrder.Id,
            AcctSeed__Ledger__c = CounterSalesController.defaultAccountingSetting.AcctSeed__Default_Ledger__c,
            AcctSeed__Shipping_Street__c = this.workOrder.SVMXC__Company__r.ShippingStreet,
            AcctSeed__Shipping_City__c = this.workOrder.SVMXC__Company__r.ShippingCity,
            AcctSeed__Shipping_State__c = this.workOrder.SVMXC__Company__r.ShippingState,
            AcctSeed__Shipping_Country__c = this.workOrder.SVMXC__Company__r.ShippingCountry,
            AcctSeed__Shipping_PostalCode__c = this.workOrder.SVMXC__Company__r.ShippingPostalCode,
            AcctSeed__Billing_Street__c = this.workOrder.SVMXC__Company__r.BillingStreet,
            AcctSeed__Billing_City__c = this.workOrder.SVMXC__Company__r.BillingCity,
            AcctSeed__Billing_State__c = this.workOrder.SVMXC__Company__r.BillingState,
            AcctSeed__Billing_Country__c = this.workOrder.SVMXC__Company__r.BillingCountry,
            AcctSeed__Billing_PostalCode__c = this.workOrder.SVMXC__Company__r.BillingPostalCode
        );
    }

    /**
    * @description :  Method to create billing lines
    **/
    public void createBillingLines() {
        if (this.workOrder.ItemizedLevel__c == 'Itemized') {
            for (SVMXC__Service_Order_Line__c workOrderLine : this.workOrderLinesList) { 
                Id productId = workOrderLine.SVMXC__Product__c != null ? workOrderLine.SVMXC__Product__c : (workOrderLine.Device__r?.SVMXC__Product__c != null ? workOrderLine.Device__r?.SVMXC__Product__c : null);
                Id revenueGLAccountId = workOrderLine.SVMXC__Product__c != null && workOrderLine.SVMXC__Product__r.AcctSeed__Revenue_GL_Account__c != null ? workOrderLine.SVMXC__Product__r.AcctSeed__Revenue_GL_Account__c : (workOrderLine.Device__r?.SVMXC__Product__c != null && workOrderLine.Device__r?.SVMXC__Product__r.AcctSeed__Revenue_GL_Account__c != null ? workOrderLine.Device__r?.SVMXC__Product__r.AcctSeed__Revenue_GL_Account__c : null);
                Id glv1Id = workOrderLine.SVMXC__Product__c != null && workOrderLine.SVMXC__Product__r.AcctSeed__GL_Account_Variable_1__c != null ? workOrderLine.SVMXC__Product__r.AcctSeed__GL_Account_Variable_1__c : (workOrderLine.Device__r?.SVMXC__Product__c != null && workOrderLine.Device__r?.SVMXC__Product__r.AcctSeed__GL_Account_Variable_1__c != null ? workOrderLine.Device__r?.SVMXC__Product__r.AcctSeed__GL_Account_Variable_1__c : (this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_1__c != null ? this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_1__c : null));
                Id glv2Id = workOrderLine.SVMXC__Product__c != null && workOrderLine.SVMXC__Product__r.AcctSeed__GL_Account_Variable_2__c != null ? workOrderLine.SVMXC__Product__r.AcctSeed__GL_Account_Variable_2__c : (workOrderLine.Device__r?.SVMXC__Product__c != null && workOrderLine.Device__r?.SVMXC__Product__r.AcctSeed__GL_Account_Variable_2__c != null ? workOrderLine.Device__r?.SVMXC__Product__r.AcctSeed__GL_Account_Variable_2__c : (this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_1__c != null ? this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_2__c : null));
                Id glv3Id = workOrderLine.SVMXC__Product__c != null && workOrderLine.SVMXC__Product__r.AcctSeed__GL_Account_Variable_3__c != null ? workOrderLine.SVMXC__Product__r.AcctSeed__GL_Account_Variable_3__c : (workOrderLine.Device__r?.SVMXC__Product__c != null && workOrderLine.Device__r?.SVMXC__Product__r.AcctSeed__GL_Account_Variable_3__c != null ? workOrderLine.Device__r?.SVMXC__Product__r.AcctSeed__GL_Account_Variable_3__c : (this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_1__c != null ? this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_3__c : null));
                Id glv4Id = workOrderLine.SVMXC__Product__c != null && workOrderLine.SVMXC__Product__r.AcctSeed__GL_Account_Variable_4__c != null ? workOrderLine.SVMXC__Product__r.AcctSeed__GL_Account_Variable_4__c : (workOrderLine.Device__r?.SVMXC__Product__c != null && workOrderLine.Device__r?.SVMXC__Product__r.AcctSeed__GL_Account_Variable_4__c != null ? workOrderLine.Device__r?.SVMXC__Product__r.AcctSeed__GL_Account_Variable_4__c : (this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_1__c != null ? this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_4__c : null));
                if (workOrderLine.SVMXC__Line_Type__c != 'Labor') {
                    if (!this.priceBookEntryMap.containsKey(productId)) {
                        this.createBilling = false;
                        workOrderLine.CannotFindPricebookEntry__c = true;
                    } else {
                        AcctSeed__Billing_Line__c billingLine = new AcctSeed__Billing_Line__c(
                            AcctSeed__Product__c = productId,
                            AcctSeed__Rate__c = this.priceBookEntryMap.get(productId).UnitPrice,
                            AcctSeed__Hours_Units__c = workOrderLine.SVMXC__Actual_Quantity2__c > 0.00 ? workOrderLine.SVMXC__Actual_Quantity2__c : 1,
                            AcctSeed__Revenue_GL_Account__c = revenueGLAccountId != null ? revenueGLAccountId : (CounterSalesController.defaultAccountingSetting.AcctSeed__Default_Debit_GL_Account_Revenue__c != null ? CounterSalesController.defaultAccountingSetting.AcctSeed__Default_Debit_GL_Account_Revenue__c : null),
                            AcctSeed__GL_Account_Variable_1__c = glv1Id,
                            AcctSeed__GL_Account_Variable_2__c = glv2Id,
                            AcctSeed__GL_Account_Variable_3__c = glv3Id,
                            AcctSeed__GL_Account_Variable_4__c = glv4Id
                        );
                        this.billingLinesList.add(billingLine);
                    }
                } else {
                    if (!this.priceBookEntryMap.containsKey(productId)) {
                        this.createBilling = false;
                        workOrderLine.CannotFindPricebookEntry__c = true;
                    } else {
                        AcctSeed__Billing_Line__c billingLine = new AcctSeed__Billing_Line__c(
                            AcctSeed__Rate__c = workOrderLine.ActiveRate__c,
                            AcctSeed__Hours_Units__c = workOrderLine.Calculated_Labor_Quantity__c > 0.00 ? workOrderLine.Calculated_Labor_Quantity__c : 1,
                            AcctSeed__Revenue_GL_Account__c = revenueGLAccountId != null ? revenueGLAccountId : (CounterSalesController.defaultAccountingSetting.AcctSeed__Default_Debit_GL_Account_Revenue__c != null ? CounterSalesController.defaultAccountingSetting.AcctSeed__Default_Debit_GL_Account_Revenue__c : null),
                            AcctSeed__GL_Account_Variable_1__c = glv1Id,
                            AcctSeed__GL_Account_Variable_2__c = glv2Id,
                            AcctSeed__GL_Account_Variable_3__c = glv3Id,
                            AcctSeed__GL_Account_Variable_4__c = glv4Id,
                            AcctSeed__Comment__c = 'Labor '+workOrderLine.LaborType__c
                        );
                        this.billingLinesList.add(billingLine);
                    }
                }
            }
        } else if (this.workOrder.ItemizedLevel__c == 'Itemized by Category') {
            Decimal labourCost = 0.00;
            Decimal nonLabourCost = 0.00;
            for (SVMXC__Service_Order_Line__c workOrderLine : this.workOrderLinesList) { 
                Id productId = workOrderLine.SVMXC__Product__c != null ? workOrderLine.SVMXC__Product__c : (workOrderLine.Device__r?.SVMXC__Product__c != null ? workOrderLine.Device__r?.SVMXC__Product__c : null);
                if (workOrderLine.SVMXC__Line_Type__c != 'Labor') {
                    if (!this.priceBookEntryMap.containsKey(productId)) {
                        this.createBilling = false;
                        workOrderLine.CannotFindPricebookEntry__c = true;
                    } else {
                        nonLabourCost += this.priceBookEntryMap.get(productId).UnitPrice;
                    }
                } else {
                    if (!this.priceBookEntryMap.containsKey(productId)) {
                        this.createBilling = false;
                        workOrderLine.CannotFindPricebookEntry__c = true;
                    } else {
                        labourCost += workOrderLine.ActiveRate__c;
                    }
                }
            }
            AcctSeed__Billing_Line__c labourBillingLine = new AcctSeed__Billing_Line__c(
                AcctSeed__Rate__c = labourCost,
                AcctSeed__Hours_Units__c = 1,
                AcctSeed__Revenue_GL_Account__c = CounterSalesController.defaultAccountingSetting.AcctSeed__Default_Debit_GL_Account_Revenue__c != null ? CounterSalesController.defaultAccountingSetting.AcctSeed__Default_Debit_GL_Account_Revenue__c : null,
                AcctSeed__GL_Account_Variable_1__c = this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_1__c,
                AcctSeed__GL_Account_Variable_2__c = this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_2__c,
                AcctSeed__GL_Account_Variable_3__c = this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_3__c,
                AcctSeed__GL_Account_Variable_4__c = this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_4__c,
                AcctSeed__Comment__c = 'Labor'
            );
            AcctSeed__Billing_Line__c nonLabourBillingLine = new AcctSeed__Billing_Line__c(
                AcctSeed__Rate__c = nonLabourCost,
                AcctSeed__Hours_Units__c = 1,
                AcctSeed__Revenue_GL_Account__c = CounterSalesController.defaultAccountingSetting.AcctSeed__Default_Debit_GL_Account_Revenue__c != null ? CounterSalesController.defaultAccountingSetting.AcctSeed__Default_Debit_GL_Account_Revenue__c : null,
                AcctSeed__GL_Account_Variable_1__c = this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_1__c,
                AcctSeed__GL_Account_Variable_2__c = this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_2__c,
                AcctSeed__GL_Account_Variable_3__c = this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_3__c,
                AcctSeed__GL_Account_Variable_4__c = this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_4__c,
                AcctSeed__Comment__c = 'Services and Parts'
            );
            this.billingLinesList.add(labourBillingLine);
            this.billingLinesList.add(nonLabourBillingLine);
        } else if (this.workOrder.ItemizedLevel__c == 'Non Itemized') {
            Decimal totalCost = 0.00;
            for (SVMXC__Service_Order_Line__c workOrderLine : this.workOrderLinesList) { 
                Id productId = workOrderLine.SVMXC__Product__c != null ? workOrderLine.SVMXC__Product__c : (workOrderLine.Device__r?.SVMXC__Product__c != null ? workOrderLine.Device__r?.SVMXC__Product__c : null);
                if (workOrderLine.SVMXC__Line_Type__c != 'Labor') {
                    if (!this.priceBookEntryMap.containsKey(productId)) {
                        this.createBilling = false;
                        workOrderLine.CannotFindPricebookEntry__c = true;
                    } else {
                        totalCost += this.priceBookEntryMap.get(productId).UnitPrice;
                    }
                } else {
                    if (!this.priceBookEntryMap.containsKey(productId)) {
                        this.createBilling = false;
                        workOrderLine.CannotFindPricebookEntry__c = true;
                    } else {
                        totalCost += workOrderLine.ActiveRate__c;
                    }
                }
            }
            AcctSeed__Billing_Line__c billingLine = new AcctSeed__Billing_Line__c(
                AcctSeed__Rate__c = totalCost,
                AcctSeed__Hours_Units__c = 1,
                AcctSeed__Revenue_GL_Account__c = CounterSalesController.defaultAccountingSetting.AcctSeed__Default_Debit_GL_Account_Revenue__c != null ? CounterSalesController.defaultAccountingSetting.AcctSeed__Default_Debit_GL_Account_Revenue__c : null,
                AcctSeed__GL_Account_Variable_1__c = this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_1__c,
                AcctSeed__GL_Account_Variable_2__c = this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_2__c,
                AcctSeed__GL_Account_Variable_3__c = this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_3__c,
                AcctSeed__GL_Account_Variable_4__c = this.workOrder.SVMXC__Company__r.AcctSeed__GL_Account_Variable_4__c
            );
            this.billingLinesList.add(billingLine);
        }
    }

    /**
    * @description :  Method to set billing id on billing lines
    **/
    public List<AcctSeed__Billing_Line__c> setBillingIdOnBillingLines() {
        if (this.billing != null && this.billing.Id != null) {
            for (AcctSeed__Billing_Line__c billingLine : this.billingLinesList) {
                billingLine.AcctSeed__Billing__c = this.billing.Id;
            }
        }
        return this.billingLinesList;
    }

}