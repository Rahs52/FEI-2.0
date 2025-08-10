/**
* @description : Helper class for work orders
**/
public with sharing class WorkOrderHelper {
    
     /**
    * @description : Method to create billings
    **/
    public static void createBillings(List<SVMXC__Service_Order__c> workOrdersList, Map<Id, SVMXC__Service_Order__c> workOrdersMap) {
        Set<Id> workOrderIds = new Set<Id>();
        for (SVMXC__Service_Order__c workOrder : workOrdersList) {
            if (workOrder.SVMXC__Order_Status__c == 'Ready for Billing' && workOrder.SVMXC__Order_Status__c != workOrdersMap.get(workOrder.Id).SVMXC__Order_Status__c) {
                workOrderIds.add(workOrder.Id);
            }
        }
        if (!workOrderIds.isEmpty()) createBillings(workOrderIds);
    }


     /**
    * @description : Method to create billings
    **/
    public static void createBillings(Set<Id> workOrderIds) {
        List<Billing> billingsList = new List<Billing>();
        List<SVMXC__Service_Order__c> workOrdersList = [SELECT Id, SVMXC__Company__c, SVMXC__Company__r.ShippingStreet, SVMXC__Company__r.ShippingCity, 
            SVMXC__Company__r.ShippingState, SVMXC__Company__r.ShippingCountry, SVMXC__Company__r.ShippingPostalCode, SVMXC__Company__r.BillingStreet, 
            SVMXC__Company__r.BillingCity, SVMXC__Company__r.BillingState, SVMXC__Company__r.BillingCountry, SVMXC__Company__r.BillingPostalCode,
            SVMXC__Company__r.AcctSeed__GL_Account_Variable_1__c, SVMXC__Company__r.AcctSeed__GL_Account_Variable_2__c, 
            SVMXC__Company__r.AcctSeed__GL_Account_Variable_3__c, SVMXC__Company__r.AcctSeed__GL_Account_Variable_4__c, ItemizedLevel__c, Price_Book__c,
            (SELECT Id, SVMXC__Product__c, SVMXC__Product__r.AcctSeed__GL_Account_Variable_1__c, SVMXC__Product__r.AcctSeed__GL_Account_Variable_2__c, 
                SVMXC__Product__r.AcctSeed__GL_Account_Variable_3__c, SVMXC__Product__r.AcctSeed__GL_Account_Variable_4__c,SVMXC__Product__r.AcctSeed__Revenue_GL_Account__c,
                SVMXC__Actual_Quantity2__c, Device__r.SVMXC__Product__c, Device__r.SVMXC__Product__r.AcctSeed__GL_Account_Variable_1__c,
                Device__r.SVMXC__Product__r.AcctSeed__GL_Account_Variable_2__c, Device__r.SVMXC__Product__r.AcctSeed__GL_Account_Variable_3__c,
                Device__r.SVMXC__Product__r.AcctSeed__GL_Account_Variable_4__c, SVMXC__Line_Type__c, CannotFindPricebookEntry__c, ActiveRate__c,
                Device__r.SVMXC__Product__r.AcctSeed__Revenue_GL_Account__c, Calculated_Labor_Quantity__c, LaborType__c
                FROM SVMXC__Service_Order_Line__r)
            FROM SVMXC__Service_Order__c WHERE Id IN: workOrderIds];
        Map<Id,Map<Id, PriceBookEntry>> priceBookEntryByPriceBookIdMap = getPriceBookEntryByPriceBookIdMap(workOrdersList);

        // create billings
        for (SVMXC__Service_Order__c workOrder : workOrdersList) {
            billingsList.add(new Billing(
                workOrder,
                priceBookEntryByPriceBookIdMap.containsKey(workOrder.Price_Book__c) ? priceBookEntryByPriceBookIdMap.get(workOrder.Price_Book__c) : new Map<Id, PriceBookEntry>()
            ));
        }
        if (!billingsList.isEmpty()) {
            // create billings
            createBillings(billingsList);

            // create billing lines
            createBillingLines(billingsList);

            // update work order lines
            updateWorkOrderLines(billingsList);

            // post billings
            postBillings(billingsList);
        }
    }

    /**
    * @description : Method to create billings
    **/
    private static void createBillings(List<Billing> billingsList) {
        List<AcctSeed__Billing__c> billingsToInsert = new List<AcctSeed__Billing__c>();
        for (Billing billing : billingsList) {
            if (billing.createBilling) billingsToInsert.add(billing.billing);
        }
        if (!billingsToInsert.isEmpty()) insert billingsToInsert;
    }

    /**
    * @description : Method to create billing lines
    **/
    private static void createBillingLines(List<Billing> billingsList) {
        List<AcctSeed__Billing_Line__c> billingLinesToInsert = new List<AcctSeed__Billing_Line__c>();
        for (Billing billing : billingsList) {
            if (billing.createBilling) billingLinesToInsert.addAll(billing.setBillingIdOnBillingLines());
        }
        if (!billingLinesToInsert.isEmpty()) insert billingLinesToInsert;
    }

    /**
    * @description : Method to udpate work order lines list
    **/
    private static void updateWorkOrderLines(List<Billing> billingsList) {
        List<SVMXC__Service_Order_Line__c> workOrderLinesToUpdate = new List<SVMXC__Service_Order_Line__c>();
        for (Billing billing : billingsList) {
            if (!billing.createBilling) workOrderLinesToUpdate.addAll(billing.workOrderLinesList);
        }
        if (!workOrderLinesToUpdate.isEmpty()) update workOrderLinesToUpdate;
    }

    /**
    * @description : Method to get map of price book entry by products
    **/
    private static Map<Id,Map<Id, PriceBookEntry>> getPriceBookEntryByPriceBookIdMap(List<SVMXC__Service_Order__c> workOrdersList) {
        Map<Id,Map<Id, PriceBookEntry>> priceBookEntryByPriceBookIdMap = new Map<Id,Map<Id, PriceBookEntry>>();
        Set<Id> priceBookIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        for (SVMXC__Service_Order__c workOrder : workOrdersList) {
            if (workOrder.Price_Book__c != null) priceBookIds.add(workOrder.Price_Book__c);
            for (SVMXC__Service_Order_Line__c workOrderLine : workOrder.SVMXC__Service_Order_Line__r) {
                Id productId = workOrderLine.SVMXC__Product__c != null ? workOrderLine.SVMXC__Product__c : (workOrderLine.Device__r?.SVMXC__Product__c != null ? workOrderLine.Device__r?.SVMXC__Product__c : null);
                if (productId != null) productIds.add(productId);
            }
        }
        List<PriceBookEntry> priceBookEntriesList = [SELECT Id, PriceBook2Id, Product2Id, UnitPrice FROM PriceBookEntry WHERE PriceBook2Id IN: priceBookIds AND Product2Id IN: productIds];
        for (PriceBookEntry priceBookEntry : priceBookEntriesList) {
            if (priceBookEntryByPriceBookIdMap.containsKey(priceBookEntry.PriceBook2Id)) {
                priceBookEntryByPriceBookIdMap.get(priceBookEntry.PriceBook2Id).put(priceBookEntry.Product2Id, priceBookEntry);
            } else {
                priceBookEntryByPriceBookIdMap.put(priceBookEntry.PriceBook2Id, new Map<Id, PriceBookEntry>{priceBookEntry.Product2Id => priceBookEntry});
            }
        }
        return priceBookEntryByPriceBookIdMap;
    }

    /**
    * @description : Method to post billings
    **/
    private static void postBillings(List<Billing> billingsList) {
        List<AcctSeed__Billing__c> billingsToPost = new List<AcctSeed__Billing__c>();
        for (Billing billing : billingsList) {
            if (billing.createBilling && billing.billing.Id != null) billingsToPost.add(billing.billing);
        }
        if (!billingsToPost.isEmpty()) {
            AcctSeed.PostResult[] postResults = AcctSeed.BillingPostService.postBillings(billingsToPost);
            // Loop through post results
            for (AcctSeed.PostResult theResult : postResults) {
                if (theResult.isSuccess) {
                    System.debug('Successfully posted billing: ' + theResult.id);
                } 
                else {
                    System.debug('Error posting billing ' + theResult.id);
                    for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                        System.debug('Error status code ' + errorResult.statusCode);
                        System.debug('Error message ' + errorResult.message);
                    }
                }
            }
        } 
    }
}