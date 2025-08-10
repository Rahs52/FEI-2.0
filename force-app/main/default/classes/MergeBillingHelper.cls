/** 
*  @description : Apex class used to merge billilgs
**/
public with sharing class MergeBillingHelper {
    
    /** 
    *  @description : Method to merge billings for an account
    **/ 
    public void mergeBillings(Id accountId) {
        // List<AcctSeed__Billing__c> billingsList = [SELECT Id,  
        //     (SELECT Id, Name, AcctSeed__Billing__r.Name,  AcctSeed__Billing__r.AcctSeed__Date__c, AcctSeed__Revenue_GL_Account__c, AcctSeed__Project__c, AcctSeed__Project_Task__c, 
        //         AcctSeed__Product__c, AcctSeed__Total__c, Property__c FROM AcctSeed__Project_Billing_Lines__r) 
        //     FROM AcctSeed__Billing__c 
        //     WHERE AcctSeed__Customer__c =: accountId]
    }
}