/**
*  @description Apex class to manage counter sales
**/
public with sharing class CounterSalesController {

    public static AcctSeed__Accounting_Settings__c defaultAccountingSetting;

    static{
        List<AcctSeed__Accounting_Settings__c> accountingSettingsList = [SELECT Id, AcctSeed__Default_Debit_GL_Account_Revenue__c, AcctSeed__Default_Ledger__c,
            AcctSeed__Default_Ledger__r.Name, AcctSeed__Prepaid_Expense_GL_Account__c
            FROM AcctSeed__Accounting_Settings__c LIMIT 1];
        if (!accountingSettingsList.isEmpty()) {
            defaultAccountingSetting = accountingSettingsList[0];
        }
    }
    
    /** 
    *  @description : Method to get counter sales information
    **/
    @AuraEnabled
    public static Map<String, Object> getCounterSalesInformation(Id accountId) {
        Map<String, Object> objectsMap = new Map<String, Object>();
        List<Product2> productFeesList = [SELECT Id, Name, (SELECT Id, UnitPrice FROM PriceBookEntries WHERE Pricebook2.Name = 'Hyannis Easton Pricebook 2025') FROM Product2 WHERE Family = 'Fees' ORDER BY Name];
        List<PriceBookEntry> priceBookEntriesList = [SELECT Id, Product2Id, Product2.Name, Product2.ProductCode, Product2.Description, UnitPrice, Pricebook2.Name 
            FROM PriceBookEntry WHERE Product2.Family != 'Fees' AND Pricebook2.Name = 'Hyannis Easton Pricebook 2025' ORDER BY Name];
        objectsMap.put('productFeesList', productFeesList);
        objectsMap.put('priceBookEntriesList', priceBookEntriesList);
        return objectsMap;
    }

    /** 
    *  @description : Method to get service and item products
    **/
    @AuraEnabled
    public static Map<String, Object> getServiceAndItemProducts(Id serviceItemId) {
        Map<String, Object> objectsMap = new Map<String, Object>();
        Set<Id> productIds = new Set<Id>();
        List<ServiceItemLine__c> serviceItemLinesList = [SELECT Id, Product__c FROM ServiceItemLine__c WHERE ServiceItem__c = :serviceItemId AND Product__c != null ORDER BY Name];
        for (ServiceItemLine__c serviceItemLine : serviceItemLinesList) {
            productIds.add(serviceItemLine.Product__c);
        }
        List<PriceBookEntry> priceBookEntriesList = [SELECT Id, Product2Id, Product2.Name, Product2.ProductCode, Product2.Description, UnitPrice, Pricebook2.Name, 
            Product2.Family FROM PriceBookEntry WHERE Product2.Family != 'Fees' AND Pricebook2.Name = 'Hyannis Easton Pricebook 2025' AND Product2Id NOT IN: productIds ORDER BY Name];
        objectsMap.put('priceBookEntriesList', priceBookEntriesList);
        return objectsMap;
    }

    /** 
    *  @description : Method to create sales order and billings
    **/
    @AuraEnabled
    public static Map<String, Object> createSalesOrderAndBillingForParts(Id accountId, String salesOrderJSON, String salesOrderLinesJSON, Boolean createBilling) {
        Map<String, Object> objectsMap = new Map<String, Object>();
        try {
            Set<Id> productIds = new Set<Id>();
            AcctSeedERP__Sales_Order__c salesOrder = (AcctSeedERP__Sales_Order__c)JSON.deserialize(salesOrderJSON,AcctSeedERP__Sales_Order__c.class);
            List<AcctSeedERP__Sales_Order_Line__c> salesOrderLinesList = (List<AcctSeedERP__Sales_Order_Line__c>)JSON.deserialize(salesOrderLinesJSON,List<AcctSeedERP__Sales_Order_Line__c>.class);

            // set sales order 
            salesOrder.AcctSeedERP__Customer__c = accountId;
            salesOrder.AcctSeedERP__Ledger__c = defaultAccountingSetting.AcctSeed__Default_Ledger__c;
            salesOrder.AcctSeedERP__Status__c = 'Open';
            salesOrder.CounterSalesStatus__c = 'Ready for Bill';
            insert salesOrder;

            // create sales order lines list
            for (AcctSeedERP__Sales_Order_Line__c salesOrderLine : salesOrderLinesList) {
                salesOrderLine.AcctSeedERP__Sales_Order__c = salesOrder.Id;
                productIds.add(salesOrderLine.AcctSeedERP__Product__c);
            }
            insert salesOrderLinesList;
            objectsMap.put('salesOrderId',salesOrder.Id);

            if (createBilling) { 
                Map<Id, Product2> productsMap = new Map<Id, Product2>([SELECT Id, Name, AcctSeed__Revenue_GL_Account__c, AcctSeed__GL_Account_Variable_1__c,
                    AcctSeed__GL_Account_Variable_2__c, AcctSeed__GL_Account_Variable_3__c, AcctSeed__GL_Account_Variable_4__c FROM Product2 WHERE Id IN :productIds]);
                List<AcctSeed__Billing_Line__c> billingLinesToInsert = new List<AcctSeed__Billing_Line__c>();

                // create billing
                AcctSeed__Billing__c billing = new AcctSeed__Billing__c(
                    AcctSeed__Customer__c = accountId,
                    AcctSeed__Ledger__c = defaultAccountingSetting.AcctSeed__Default_Ledger__c,
                    AcctSeed__Billing_Street__c = salesOrder.AcctSeedERP__Billing_Street__c,
                    AcctSeed__Billing_City__c = salesOrder.AcctSeedERP__Billing_City__c,
                    AcctSeed__Billing_PostalCode__c = salesOrder.AcctSeedERP__Billing_PostalCode__c,
                    AcctSeed__Billing_Country__c = salesOrder.AcctSeedERP__Billing_Country__c,
                    AcctSeed__Billing_State__c = salesOrder.AcctSeedERP__Billing_State__c,
                    AcctSeed__Date__c = System.today(),
                    AcctSeed__Billing_Comment__c = salesOrder.CounterSalesDetails__c,
                    AcctSeedERP__Sales_Order__c = salesOrder.Id
                );
                insert billing;

                // create billing lines
                for (AcctSeedERP__Sales_Order_Line__c salesOrderLine : salesOrderLinesList) {
                    AcctSeed__Billing_Line__c billingLine = new AcctSeed__Billing_Line__c(
                        AcctSeed__Billing__c = billing.Id,
                        AcctSeed__Product__c = salesOrderLine.AcctSeedERP__Product__c,
                        AcctSeed__Rate__c = salesOrderLine.AcctSeedERP__Unit_Price__c,
                        AcctSeed__Hours_Units__c = salesOrderLine.AcctSeedERP__Quantity_Ordered__c,
                        AcctSeedERP__Sales_Order_Line__c = salesOrderLine.Id
                    );
                    if (productsMap.containsKey(salesOrderLine.AcctSeedERP__Product__c)) {
                        billingLine.AcctSeed__GL_Account_Variable_1__c = productsMap.get(salesOrderLine.AcctSeedERP__Product__c).AcctSeed__GL_Account_Variable_1__c;
                        billingLine.AcctSeed__GL_Account_Variable_2__c = productsMap.get(salesOrderLine.AcctSeedERP__Product__c).AcctSeed__GL_Account_Variable_2__c;
                        billingLine.AcctSeed__GL_Account_Variable_3__c = productsMap.get(salesOrderLine.AcctSeedERP__Product__c).AcctSeed__GL_Account_Variable_3__c;
                        billingLine.AcctSeed__GL_Account_Variable_4__c = productsMap.get(salesOrderLine.AcctSeedERP__Product__c).AcctSeed__GL_Account_Variable_4__c;
                        billingLine.AcctSeed__Revenue_GL_Account__c = productsMap.get(salesOrderLine.AcctSeedERP__Product__c).AcctSeed__Revenue_GL_Account__c != null ? 
                            productsMap.get(salesOrderLine.AcctSeedERP__Product__c).AcctSeed__Revenue_GL_Account__c : (defaultAccountingSetting.AcctSeed__Default_Debit_GL_Account_Revenue__c != null ? defaultAccountingSetting.AcctSeed__Default_Debit_GL_Account_Revenue__c : null);
                    }
                    billingLinesToInsert.add(billingLine);
                }
                insert billingLinesToInsert;
            }
        }catch(Exception ex) {
            System.debug('Exception is '+ex.getMessage());
        }
        return objectsMap;
    }

    /** 
    *  @description : Method to create sales order and service items
    **/
    @AuraEnabled
    public static void createSalesOrderAndServiceItem(Id accountId, String salesOrderJSON, String serviceItemJSON, String serviceItemLinesJSON) {
        try {
            AcctSeedERP__Sales_Order__c salesOrder = (AcctSeedERP__Sales_Order__c)JSON.deserialize(salesOrderJSON,AcctSeedERP__Sales_Order__c.class);
            ServiceItem__c serviceItem = (ServiceItem__c)JSON.deserialize(serviceItemJSON,ServiceItem__c.class);
            List<ServiceItemLine__c> serviceItemLinesList = (List<ServiceItemLine__c>)JSON.deserialize(serviceItemLinesJSON,List<ServiceItemLine__c>.class);

            // set sales order 
            salesOrder.AcctSeedERP__Customer__c = accountId;
            salesOrder.AcctSeedERP__Ledger__c = defaultAccountingSetting.AcctSeed__Default_Ledger__c;
            salesOrder.AcctSeedERP__Status__c = 'Open';
            salesOrder.CounterSalesStatus__c = 'New';
            upsert salesOrder;

            // create service item 
            serviceItem.SalesOrder__c = salesOrder.Id;
            serviceItem.Status__c = 'New';
            insert serviceItem;


            // create service items lines list
            for (ServiceItemLine__c servieItemLine : serviceItemLinesList) {
                servieItemLine.ServiceItem__c = serviceItem.Id;
            }
            insert serviceItemLinesList;
        }catch(Exception ex) {
            System.debug('Exception is '+ex.getMessage());
        }
    }

    /** 
    *  @description : Method to create service items list
    **/
    @AuraEnabled
    public static void createServiceItemLines(Id serviceItemId, String serviceItemLinesJSON) {
        try {
            List<ServiceItemLine__c> serviceItemLinesList = (List<ServiceItemLine__c>)JSON.deserialize(serviceItemLinesJSON,List<ServiceItemLine__c>.class);

            // create service items lines list
            for (ServiceItemLine__c servieItemLine : serviceItemLinesList) {
                servieItemLine.ServiceItem__c = serviceItemId;
            }
            insert serviceItemLinesList;
        }catch(Exception ex) {
            System.debug('Exception is '+ex.getMessage());
        }
    }
}