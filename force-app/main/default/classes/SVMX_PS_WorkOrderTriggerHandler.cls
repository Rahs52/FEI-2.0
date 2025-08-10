/**
 * @class       SVMX_PS_WorkOrderTriggerHandler
 * @description This class implements the SVMXix.TriggerInterface to handle
 *              trigger events for the Work Order (SVMXC__Service_Order__c) object.
 *              It defines empty method stubs for all trigger contexts, allowing
 *              logic to be handled in a separate trigger function class (e.g., SVMX_PS_WorkOrderTriggerFunctions).
 *
 *              This approach promotes clean separation of concerns and keeps the
 *              trigger logic maintainable and scalable.
 *
 * @author      Sarathbabu Panneerselvam
 * @createdDate 21-April-2025
 * @modificationHistory
 *   - 04/21/2025 Sarathbabu Initial implementation of Trigger Interface
 */
global class SVMX_PS_WorkOrderTriggerHandler implements SVMXix.TriggerInterface {

    /**
     * @method beforeUpdate
     * @description Handles logic before Work Order records are updated.
     */
    global void beforeUpdate(List<SObject> oldSoList, Map<Id, SObject> oldSoMap,
                             List<SObject> newSoList, Map<Id, SObject> newSoMap) {
        // Intentionally left blank for future use
    }

    /**
     * @method beforeInsert
     * @description Handles logic before Work Order records are inserted.
     */
    global void beforeInsert(List<SObject> newSoList, Map<Id, SObject> newSoMap) {
        // Intentionally left blank for future use
    }

    /**
     * @method beforeDelete
     * @description Handles logic before Work Order records are deleted.
     */
    global void beforeDelete(List<SObject> oldSoList, Map<Id, SObject> oldSoMap) {
        // Intentionally left blank for future use
    }

    /**
     * @method afterDelete
     * @description Handles logic after Work Order records are deleted.
     */
    global void afterDelete(List<SObject> oldSoList, Map<Id, SObject> oldSoMap) {
        // Intentionally left blank for future use
    }

    /**
     * @method afterInsert
     * @description Handles logic after Work Order records are inserted.
     */
    global void afterInsert(List<SObject> newSoList, Map<Id, SObject> newSoMap) {
        SVMX_PS_WorkOrderTriggerFunctions.createDeviceWorkDetails(newSoList);
    }

    /**
     * @method afterUpdate
     * @description Handles logic after Work Order records are updated.
     */
    global void afterUpdate(List<SObject> oldSoList, Map<Id, SObject> oldSoMap,
                            List<SObject> newSoList, Map<Id, SObject> newSoMap) {
        // Intentionally left blank for future use
    }
}