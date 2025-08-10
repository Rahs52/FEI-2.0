/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_AcctSeedERP_Purchase_Order_LineTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_AcctSeedERP_Purchase_OrdeaGGTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new AcctSeedERP__Purchase_Order_Line__c());
    }
}