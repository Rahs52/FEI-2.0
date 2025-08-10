/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_AcctSeedERP_Purchase_OrdeaGGTrigger on AcctSeedERP__Purchase_Order_Line__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(AcctSeedERP__Purchase_Order_Line__c.SObjectType);
}