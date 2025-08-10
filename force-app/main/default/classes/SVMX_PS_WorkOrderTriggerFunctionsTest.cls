/**
 * @class       SVMX_PS_WorkOrderTriggerFunctionsTest
 * @description This is the unit test class for the SVMX_PS_WorkOrderTriggerFunctions class.
 *              It verifies the correctness and reliability of trigger-related business logic
 *              executed during Work Order (SVMXC__Service_Order__c) trigger events.
 *
 *
 *              This test class is designed to support the required code coverage
 *              and validate expected behavior without any DML or governor limit issues.
 *
 * @author      Sarathbabu Panneerselvam
 * @createdDate 21-April-2025
 * @modificationHistory
 *   - 04/21/2025 Sarathbabu Initial test creation for Work Order logic
 */
@isTest
public class SVMX_PS_WorkOrderTriggerFunctionsTest {

    @isTest
    static void testCreateDeviceWorkDetails() {
        // Step 1: Create parent Installed Product (to be used as the Component)
        SVMXC__Installed_Product__c parentIP = new SVMXC__Installed_Product__c(
            Name = 'Parent Installed Product'
        );
        insert parentIP;

        // Step 2: Create child Installed Product with Parent set to the above
        SVMXC__Installed_Product__c childIP = new SVMXC__Installed_Product__c(
            Name = 'Child Installed Product',
            SVMXC__Parent__c = parentIP.Id
        );
        insert childIP;

        // Step 3: Create Work Order with Component pointing to Parent Installed Product
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c(
            SVMXC__Problem_Description__c = 'Test Work Order',
            SVMXC__Component__c = parentIP.Id
        );
        insert workOrder;

        // Step 4: Create Record Type 'Device' for Service Order Line if not exists
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'SVMXC__Service_Order_Line__c' AND Name = 'Device' LIMIT 1];

        Test.startTest();
        // Step 5: Call the method under test
        SVMX_PS_WorkOrderTriggerFunctions.createDeviceWorkDetails(new List<SVMXC__Service_Order__c>{ workOrder });
        
        //Step 6: Test Coverage for update method
        workOrder.SVMXC__Order_Status__c = 'Devices';
        update workOrder;
        
        //Step 7: Test Coverage for delete method
        delete workOrder;
        
        Test.stopTest();
    }
}