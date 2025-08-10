/**
* @description Test class for counter sales controller
**/
@isTest(seeAllData=false)
private with sharing class CounterSalesControllerTest {
    
    /**
    * @description : set up test data
    **/
    @testSetup
    static void setUpTestData(){
        // Create accounts
        List<Account> accountsList = TestDataCreator.createAccounts(1);
        insert accountsList;

        // Create contacts 
        List<Contact> contactsList =  TestDataCreator.createContacts(1,accountsList);
        insert contactsList;

        // Create GL Accounts
        List<AcctSeed__GL_Account__c> glAccountsList = TestDataCreator.createGLAccounts();
        insert glAccountsList;

        // Create Billing Formats
        List<AcctSeed__Billing_Format__c> billingFormatsList = TestDataCreator.createBillingFormats();
        insert billingFormatsList;

        // Create Tax Settings
        List<AcctSeed__Tax_Settings__c> taxSettingsList = TestDataCreator.createTaxSettings(1);
        insert taxSettingsList;

        // Create Ledger
        List<AcctSeed__Ledger__c> ledgersList = TestDataCreator.createLedgers(1, glAccountsList[0], billingFormatsList);
        ledgersList[0].AcctSeed__Tax_Settings__c = taxSettingsList[0].Id;
        insert ledgersList;

        // Create accounting periods
        List<AcctSeed__Accounting_Period__c> accountingPeriodsList = TestDataCreator.createAccountingPeriods(12,System.today());
        accountingPeriodsList.addAll(TestDataCreator.createAccountingPeriods(3,Date.newInstance(2020,09,01)));
        insert accountingPeriodsList;

        // Create Account Settings 
        AcctSeed__Accounting_Settings__c accountSettings = TestDataCreator.createAccountSettings(billingFormatsList, ledgersList, glAccountsList);
        insert accountSettings;

        // Create Products
        List<Product2> productsList = TestDataCreator.createProducts(new List<AcctSeed__GL_Account__c>{ glAccountsList[17], glAccountsList[16], glAccountsList[15] });
        insert productsList;

        // create custom pricebook
        List<Pricebook2> priceBooksList = TestDataCreator.createPriceBooks();
        insert priceBooksList;

        // Create Price Book Entries
        List<PriceBookEntry> priceBookEntriesList = TestDataCreator.createPriceBookEntries(1, new Map<Id, Product2>(productsList).keySet(), priceBooksList[0].Id);
        insert priceBookEntriesList;
    }

    /**
    *   @description : Test getCounterSalesInformation
    **/
    @isTest
    static void test_getCounterSalesInformation(){
        List<Account> accountsList = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Map<String, Object> objectsMap = CounterSalesController.getCounterSalesInformation(accountsList[0].Id);
        List<Product2> productFeesList = (List<Product2>)objectsMap.get('productFeesList');
        List<PriceBookEntry> priceBookEntriesList = (List<PriceBookEntry>)objectsMap.get('priceBookEntriesList');
        Test.stopTest();
        Assert.areEqual(1,productFeesList.size());
        Assert.areEqual(2,priceBookEntriesList.size());
    }

    /**
    *   @description : Test createSalesOrderAndBillingForParts
    **/
    @isTest
    static void test_createSalesOrderAndBillingForParts(){
        List<Account> accountsList = [SELECT Id FROM Account LIMIT 1];
        List<Product2> productsList = [SELECT Id FROM Product2];
        Assert.areEqual(0,[SELECT COUNT() FROM AcctSeed__Billing__c]);
        Assert.areEqual(0,[SELECT COUNT() FROM AcctSeed__Billing_Line__c]);
        Assert.areEqual(0,[SELECT COUNT() FROM AcctSeedERP__Sales_Order__c]);
        Assert.areEqual(0,[SELECT COUNT() FROM AcctSeedERP__Sales_Order_Line__c]);
        Test.startTest();
        CounterSalesController.createSalesOrderAndBillingForParts(
            accountsList[0].Id,
            JSON.serialize(new AcctSeedERP__Sales_Order__c(CustomerName__c = 'Test')),
            JSON.serialize(new List<AcctSeedERP__Sales_Order_Line__c>{
                new AcctSeedERP__Sales_Order_Line__c(AcctSeedERP__Product__c = productsList[0].Id, AcctSeedERP__Quantity_Ordered__c = 1, AcctSeedERP__Unit_Price__c = 20),
                new AcctSeedERP__Sales_Order_Line__c(AcctSeedERP__Product__c = productsList[1].Id, AcctSeedERP__Quantity_Ordered__c = 1, AcctSeedERP__Unit_Price__c = 20),
                new AcctSeedERP__Sales_Order_Line__c(AcctSeedERP__Product__c = productsList[2].Id, AcctSeedERP__Quantity_Ordered__c = 1, AcctSeedERP__Unit_Price__c = 20)
            }),
            true
        );
        Test.stopTest();
        Assert.areEqual(1,[SELECT COUNT() FROM AcctSeed__Billing__c]);
        Assert.areEqual(3,[SELECT COUNT() FROM AcctSeed__Billing_Line__c]);
        Assert.areEqual(1,[SELECT COUNT() FROM AcctSeedERP__Sales_Order__c]);
        Assert.areEqual(3,[SELECT COUNT() FROM AcctSeedERP__Sales_Order_Line__c]);
    }

    /**
    *   @description : Test createSalesOrderAndServiceItem
    **/
    @isTest
    static void test_createSalesOrderAndServiceItem(){
        List<Account> accountsList = [SELECT Id FROM Account LIMIT 1];
        List<Product2> productsList = [SELECT Id FROM Product2];
        Assert.areEqual(0,[SELECT COUNT() FROM AcctSeedERP__Sales_Order__c]);
        Assert.areEqual(0,[SELECT COUNT() FROM ServiceItem__c]);
        Assert.areEqual(0,[SELECT COUNT() FROM ServiceItemLine__c]);
        Test.startTest();
        CounterSalesController.createSalesOrderAndServiceItem(
            accountsList[0].Id,
            JSON.serialize(new AcctSeedERP__Sales_Order__c(CustomerName__c = 'Test')),
            JSON.serialize(new ServiceItem__c(Notes__c = 'Test')),
            JSON.serialize(new List<ServiceItemLine__c>{
                new ServiceItemLine__c(Product__c = productsList[0].Id, Quantity__c = 1, UnitPrice__c = 20)
            })
        );
        Assert.areEqual(1,[SELECT COUNT() FROM AcctSeedERP__Sales_Order__c]);
        Assert.areEqual(1,[SELECT COUNT() FROM ServiceItem__c]);
        Assert.areEqual(1,[SELECT COUNT() FROM ServiceItemLine__c]);
        List<ServiceItem__c> serviceItemsList = [SELECT Id FROM ServiceItem__c LIMIT 1];
        Map<String, Object> objectsMap = CounterSalesController.getServiceAndItemProducts(serviceItemsList[0].Id);
        List<PriceBookEntry> priceBookEntriesList = (List<PriceBookEntry>)objectsMap.get('priceBookEntriesList');
        Assert.areEqual(2,priceBookEntriesList.size());
        CounterSalesController.createServiceItemLines(
            serviceItemsList[0].Id,
            JSON.serialize(new List<ServiceItemLine__c>{
                new ServiceItemLine__c(Product__c = productsList[1].Id, Quantity__c = 1, UnitPrice__c = 20),
                new ServiceItemLine__c(Product__c = productsList[2].Id, Quantity__c = 1, UnitPrice__c = 20)
            })
        );
        Test.stopTest();
        Assert.areEqual(3,[SELECT COUNT() FROM ServiceItemLine__c]);
    }
}