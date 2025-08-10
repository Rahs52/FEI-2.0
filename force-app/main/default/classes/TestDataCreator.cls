/**
* @description : class is used to easily create data for tests 
**/
public with sharing class TestDataCreator {
    
    /**
    * @description Method to create account
    **/
    public static List<Account> createAccounts(Integer noOfAccounts){
        List<Account> accountsList = new List<Account>();
        for(Integer i = 0; i < noOfAccounts; i++){
            accountsList.add(new Account(
                Name = 'Test Account - ' +String.valueOf(i), 
                AcctSeed__Accounting_Type__c = 'Customer and Vendor',
                AcctSeed__Accounting_Active__c = true,
                BillingStreet = '72/1 Padmavathi Illam', 
                BillingCity = 'Erode', 
                BillingState = 'Tamil Nadu', 
                BillingPostalCode = '638116'
            ));
        }
        return accountsList;
    }

    /**
    * @description Method to create contact
    **/
    public static List<Contact> createContacts(Integer noOfContacts, List<Account> accountsList){
        List<Contact> contactsList = new List<Contact>();
        for(Account account : accountsList){
            for(Integer i = 0; i < noOfContacts; i++){
                contactsList.add(new Contact(LastName = 'Account - ' +String.valueOf(i), AccountId = account.Id));
            }
        }
        return contactsList;
    }

    /**
    * @description Method to create general ledger account
    **/
    public static List<AcctSeed__GL_Account__c> createGLAccounts(){
        List<AcctSeed__GL_Account__c> glAccountsList = new List<AcctSeed__GL_Account__c>();
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '1000-Cash', AcctSeed__Active__c = true, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Bank__c = true, AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Cash') );
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '1205-Unapplied A/R', AcctSeed__Active__c = true, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Bank__c = false, AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Cash' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '1200-Accounts Receivable', AcctSeed__Active__c = true, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Bank__c = false, AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Current Assets' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '1600-Work In Process', AcctSeed__Active__c = true, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Bank__c = false, AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Current Assets' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '2000-Accounts Payable', AcctSeed__Active__c = true, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Bank__c = false, AcctSeed__Sub_Type_1__c = 'Liabilities', AcctSeed__Sub_Type_2__c = 'Current Liabilities' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '2010-Vouchers Payable', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Sub_Type_1__c = 'Liabilities', AcctSeed__Sub_Type_2__c = 'Current Liabilities' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '3050-Retained Earnings', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Sub_Type_1__c = 'Owners Equity', AcctSeed__Sub_Type_2__c = 'Equity' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '3060-Current Year Earnings', AcctSeed__Active__c = true, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Bank__c = false, AcctSeed__Sub_Type_1__c = 'Owners Equity', AcctSeed__Sub_Type_2__c = 'Equity' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '4000-Product Revenue', AcctSeed__Active__c = true, AcctSeed__Type__c = 'Revenue', AcctSeed__Bank__c = false, AcctSeed__Sub_Type_1__c = 'Product Revenue', AcctSeed__Sub_Type_2__c = 'Product Family 1' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '5010-Inventory Cost Variance', AcctSeed__Active__c = true, AcctSeed__Type__c = 'Expense', AcctSeed__Bank__c = false, AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold', AcctSeed__Sub_Type_2__c = 'Materials' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '5040-Vendor Payment Discounts', AcctSeed__Active__c = true, AcctSeed__Type__c = 'Expense', AcctSeed__Bank__c = false, AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold', AcctSeed__Sub_Type_2__c = 'Materials' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = 'zLabor Clearing', AcctSeed__Active__c = true, AcctSeed__Type__c = 'Expense', AcctSeed__Bank__c = false ) );
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = 'zProject Labor', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Expense' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '4900-Customer Payment Discounts', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Revenue', AcctSeed__Sub_Type_1__c = 'Product Revenue', AcctSeed__Sub_Type_2__c = 'Product Family 1' ) );
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '1400-Prepaid Expenses', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Current Assets' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '4000-Sales Revenue', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Revenue', AcctSeed__Sub_Type_1__c = 'Operating Revenue', AcctSeed__Sub_Type_2__c = 'Sales Revenue' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '5000-Purchases', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Expense', AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold', AcctSeed__Sub_Type_2__c = 'Purchases' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '1300-Inventory', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Current Assets' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '5095-Purchase Discount', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Expense', AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold', AcctSeed__Sub_Type_2__c = 'Purchase Discounts' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '5300-Inventory Variance', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Expense', AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold', AcctSeed__Sub_Type_2__c = 'Cost of Goods Sold' ) ); 
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '4015-Customer Payment Discount', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Revenue', AcctSeed__Sub_Type_1__c = 'Operating Revenue', AcctSeed__Sub_Type_2__c = 'Sales Revenue' ) );
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '10050-Cash - Stripe TBR', AcctSeed__Active__c = true, AcctSeed__Bank__c = true, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Cash' ) );
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '10040-Cash - Stripe Insiders', AcctSeed__Active__c = true, AcctSeed__Bank__c = true, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Cash' ) );
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '5000-COST OF SALES-MANUFACTURING', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Expense', AcctSeed__Sub_Type_1__c = 'Cost of Sales', AcctSeed__Sub_Type_2__c = 'Supplies and Materials' ) );
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '1310-FINISHED GOODS INVENTORY', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Current Assets' ) );
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '1000- Hancock 6460 - FL', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Current Assets' ) );
        glAccountsList.add( new AcctSeed__GL_Account__c( Name = '3600-Owner Distribution', AcctSeed__Active__c = true, AcctSeed__Bank__c = false, AcctSeed__Type__c = 'Balance Sheet', AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Current Assets' ) );
        return glAccountsList;
    }

    /**
    * @description : Method to create products
    **/
    public static List<Product2> createProducts(List<AcctSeed__GL_Account__c> glAccountsList){
        List<Product2> productsList = new List<Product2>();
        productsList.add(new Product2(
            Name = 'Test Product Fees',
            Family = 'Fees',
            AcctSeed__Inventory_Product__c = true,
            AcctSeed__Expense_GL_Account__c = glAccountsList[0].Id,
            AcctSeed__Inventory_GL_Account__c = glAccountsList[1].Id,
            AcctSeed__Inventory_Type__c = 'Purchased',
            AcctSeed__Revenue_GL_Account__c = glAccountsList[2].Id,
            AcctSeed__Unit_Cost__c = 1000.00
        ));
        productsList.add(new Product2(
            Name = 'Test Product Service WB',
            Family = 'Service - WB',
            AcctSeed__Inventory_Product__c = true,
            AcctSeed__Expense_GL_Account__c = glAccountsList[0].Id,
            AcctSeed__Inventory_GL_Account__c = glAccountsList[1].Id,
            AcctSeed__Inventory_Type__c = 'Purchased',
            AcctSeed__Revenue_GL_Account__c = glAccountsList[2].Id,
            AcctSeed__Unit_Cost__c = 1000.00
        ));
        productsList.add(new Product2(
            Name = 'Test Product Service FA',
            Family = 'Service - FA',
            AcctSeed__Inventory_Product__c = true,
            AcctSeed__Expense_GL_Account__c = glAccountsList[0].Id,
            AcctSeed__Inventory_GL_Account__c = glAccountsList[1].Id,
            AcctSeed__Inventory_Type__c = 'Purchased',
            AcctSeed__Revenue_GL_Account__c = glAccountsList[2].Id,
            AcctSeed__Unit_Cost__c = 1000.00
        ));
        return productsList;
    }

    /**
    * @description : Method to create price book 
    **/
    public static List<Pricebook2> createPriceBooks(){
        List<Pricebook2> priceBooksList = new List<Pricebook2>();
        priceBooksList.add(new Pricebook2(
            Name = 'Hyannis Easton Pricebook 2025',
            IsActive=true
        ));
        return priceBooksList;
    }

    /**
    * @description : Method to create price book entries
    **/
    public static List<PriceBookEntry> createPriceBookEntries(Integer noOfPriceBookEntries,Set<Id> productIds, Id customPriceBookId){
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        for(Integer i=0;i<noOfPriceBookEntries;i++){
            for(Id productId : productIds){
                priceBookEntriesList.add(new PricebookEntry(
                    Pricebook2Id=Test.getStandardPricebookId(),
                    Product2Id=productId,
                    UnitPrice=1000.00,
                    IsActive=true
                ));
                priceBookEntriesList.add(new PricebookEntry(
                    Pricebook2Id=customPriceBookId,
                    Product2Id=productId,
                    UnitPrice=1000.00,
                    IsActive=true
                ));
            }
        }
        return priceBookEntriesList;
    }

    /**
    * @description Method to create billing formats
    **/ 
    public static List<AcctSeed__Billing_Format__c> createBillingFormats(){
        List<AcctSeed__Billing_Format__c> billingFormatsList = new List<AcctSeed__Billing_Format__c>();
        String emailTemplateName = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName;
        billingFormatsList.add(new AcctSeed__Billing_Format__c( Name = 'Default Billing Product', AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF', AcctSeed__Default_Email_Template__c = emailTemplateName, AcctSeed__Type__c = 'Billing', AcctSeed__Sort_Field__c = 'Name' ));
        billingFormatsList.add(new AcctSeed__Billing_Format__c( Name = 'Default Billing Service', AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF', AcctSeed__Default_Email_Template__c = emailTemplateName, AcctSeed__Type__c = 'Billing', AcctSeed__Sort_Field__c = 'Name' ));
        billingFormatsList.add(new AcctSeed__Billing_Format__c ( Name = 'Billing Outstanding Statement', AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF', AcctSeed__Default_Email_Template__c = emailTemplateName, AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com', AcctSeed__Type__c = 'Outstanding Statement' ));
        billingFormatsList.add(new AcctSeed__Billing_Format__c ( Name = 'Billing Activity Statement', AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF', AcctSeed__Default_Email_Template__c = emailTemplateName, AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com', AcctSeed__Type__c = 'Activity Statement' ));
        billingFormatsList.add(new AcctSeed__Billing_Format__c( Name = 'Default Purchase Order', AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF', AcctSeed__Default_Email_Template__c = emailTemplateName, AcctSeed__Type__c = 'Purchase Order', AcctSeed__Sort_Field__c = 'Name' ));
        billingFormatsList.add(new AcctSeed__Billing_Format__c( Name = 'Default Packing Slip', AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF', AcctSeed__Default_Email_Template__c = emailTemplateName, AcctSeed__Type__c = 'Packing Slip', AcctSeed__Sort_Field__c = 'Name' ));
        return billingFormatsList;
    }

    /**
    * @description Method to create ledgers
    **/ 
    public static List<AcctSeed__Ledger__c> createLedgers(Integer noOfLedgers, AcctSeed__GL_Account__c glAccount, List<AcctSeed__Billing_Format__c> billingFormatsList){
        List<AcctSeed__Ledger__c> ledgersList = new List<AcctSeed__Ledger__c>();
        for(Integer i=0;i<noOfLedgers;i++){
            ledgersList.add(new AcctSeed__Ledger__c(Name = 'Actual', AcctSeed__Type__c = 'Transactional', AcctSeed__Default_Bank_Account__c = glAccount.Id, 
                AcctSeed__Default_Billing_Format__c = billingFormatsList[0].Id, AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormatsList[2].Id, 
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormatsList[3].Id, AcctSeed__Default_Purchase_Order_Format__c = billingFormatsList[4].Id, 
                AcctSeed__Default_Packing_Slip_Format__c = billingFormatsList[5].Id));
        }
        return ledgersList;
    }

    /**
    * @description Method to create accounting period
    **/
    public static List<AcctSeed__Accounting_Period__c> createAccountingPeriods(Integer noOfAccountingPeriods, Date startDate){
        List<AcctSeed__Accounting_Period__c> accountingPeriodsList = new List<AcctSeed__Accounting_Period__c>();
        for(Integer i=0;i<noOfAccountingPeriods;i++){
            Date tempDate = startDate.addMonths(i);
            accountingPeriodsList.add(
                new AcctSeed__Accounting_Period__c(
                    Name = getAccountingPeriodName(tempDate.year(),tempDate.month()),
                    AcctSeed__Start_Date__c = Date.newinstance(tempDate.year(), tempDate.month(), 1),
                    AcctSeed__End_Date__c = Date.newinstance(tempDate.year(), tempDate.month(), Date.daysInMonth(tempDate.year(), tempDate.month())),
                    AcctSeed__Status__c = 'Open'
                )
            );
        }
        return accountingPeriodsList;
    }

    /**
    * @description Method to get map of accounting name 
    **/
    public static String getAccountingPeriodName(Integer year, Integer month) {
        return year + '-' + (month < 10 ? ('0' + month) : String.valueOf(month));
    }

    /**
    * @description Method to create account settings
    **/
    public static AcctSeed__Accounting_Settings__c createAccountSettings(List<AcctSeed__Billing_Format__c> billingFormatsList, 
        List<AcctSeed__Ledger__c> ledgersList, List<AcctSeed__GL_Account__c> glAccountsList){
        // update Account Settings with Bill Format
        AcctSeed__Accounting_Settings__c settings = new AcctSeed__Accounting_Settings__c(
                Name = 'Test Settings',
                AcctSeed__Default_Ledger__c = ledgersList[0].Id,
                AcctSeed__Legacy_Default_Ledger__c = ledgersList[0].Id,
                AcctSeed__Enable_Product_Costing__c = true,
                AcctSeed__Display_Billable_Flag_in_Time_Card_Entry__c = true,
                AcctSeed__Enable_Billing_Period_Sensitive_Aging__c = true,
                AcctSeed__Enable_AP_Period_Sensitive_Aging__c = true,
                AcctSeed__Work_in_Process_GL_Account__c = glAccountsList[3].Id,
                AcctSeed__Vouchers_Payable_GL_Account__c = glAccountsList[5].Id,
                AcctSeed__Inventory_Variance_GL_Account__c = glAccountsList[19].Id,
                AcctSeed__Payment_Discount_GL_Account__c = glAccountsList[18].Id,
                AcctSeed__Customer_Payment_Adjustment_GL_Account__c = glAccountsList[20].Id,
                AcctSeed__Prepaid_Expense_GL_Account__c = glAccountsList[14].Id,
                AcctSeed__Default_Billing_Format__c = billingFormatsList[0].Id,
                AcctSeed__Default_Project_Task_Labor_GL_Account__c = glAccountsList[21].Id 
        );
        return settings;
    }

    /**
    * @description Method to create tax settings
    **/
    public static List<AcctSeed__Tax_Settings__c> createTaxSettings(Integer noOfTaxSettings){
        List<AcctSeed__Tax_Settings__c> taxSettingsList = new List<AcctSeed__Tax_Settings__c>();
        for(Integer i = 0; i < noOfTaxSettings; i++){
            taxSettingsList.add(new AcctSeed__Tax_Settings__c(
                Name = 'Test Tax Setting - ' +String.valueOf(i),
                AcctSeed__Tax_Method__c = 'Accounting Seed Native Tax',
                AcctSeed__Tax_Settings_Method__c = 'Accounting Seed Native Tax'
            ));
        }
        return taxSettingsList;
    }
}