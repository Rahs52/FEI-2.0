/**
 * @class       SVMX_PS_WorkOrderTriggerFunctions
 * @description This utility class contains business logic methods used in triggers
 *              related to Work Order (SVMXC__Service_Order__c) object.
 *              It encapsulates reusable trigger operations such as auto-creating 
 *              related records and enforcing logic on Work Order creation or updates.
 * 
 * @author      Sarathbabu Panneerselvam
 * @createdDate 21-April-2025
 * @modificationHistory
 *   - 04/21/2025 Sarathbabu Initial Version
 *  
 */
public class SVMX_PS_WorkOrderTriggerFunctions {
    /**
     * @method     createDeviceWorkDetails
     * @description This method is invoked during Work Order creation to automatically
     *              create Work Details (SVMXC__Service_Order_Line__c) of 'Device' record type
     *              for each Installed Product (child of component).
     *
     * @param      newWorkOrders  List of Work Orders being inserted
     */
	public static void createDeviceWorkDetails(List<SVMXC__Service_Order__c> workOrders) {
        
        // Collect all Component IDs from the incoming Work Orders
        Set<Id> componentIds = new Set<Id>();

        for (SVMXC__Service_Order__c wo : workOrders) {
            if (wo.SVMXC__Component__c != null) {
                componentIds.add(wo.SVMXC__Component__c);
            }
        }
        
        // Exit early if no components are found
        if (componentIds.isEmpty()) return;

        // Query child Installed Products where SVMXC__Parent__c matches the Work Order component
        Map<Id, List<SVMXC__Installed_Product__c>> childIPMap = new Map<Id, List<SVMXC__Installed_Product__c>>();
        for (SVMXC__Installed_Product__c ip : [
            SELECT Id, SVMXC__Parent__c
            FROM SVMXC__Installed_Product__c
            WHERE SVMXC__Parent__c IN :componentIds
        ]) {
            if (!childIPMap.containsKey(ip.SVMXC__Parent__c)) {
                childIPMap.put(ip.SVMXC__Parent__c, new List<SVMXC__Installed_Product__c>());
            }
            childIPMap.get(ip.SVMXC__Parent__c).add(ip);
        }

        // Get Record Type ID for 'Device' Work Detail
        Id deviceRecordTypeId = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'SVMXC__Service_Order_Line__c' 
            AND Name = 'Device' 
            LIMIT 1
        ].Id;

        // Prepare list to collect Work Detail records
        List<SVMXC__Service_Order_Line__c> workDetailsToInsert = new List<SVMXC__Service_Order_Line__c>();

        // Loop over Work Orders and map their child Installed Products to Work Detail records
        for (SVMXC__Service_Order__c wo : workOrders) {
            List<SVMXC__Installed_Product__c> childIPs = childIPMap.get(wo.SVMXC__Component__c);

            if (childIPs != null) {
                for (SVMXC__Installed_Product__c ip : childIPs) {
                    SVMXC__Service_Order_Line__c wd = new SVMXC__Service_Order_Line__c();
                    wd.SVMXC__Service_Order__c = wo.Id;
                    wd.RecordTypeId = deviceRecordTypeId;
                    wd.Device__c = ip.Id;
                    wd.Inspection__c = getDefaultInspectionValue(); 

                    workDetailsToInsert.add(wd);
                }
            }
        }

        // Insert all new Work Detail records
        if (!workDetailsToInsert.isEmpty()) {
            insert workDetailsToInsert;
        }
    }
    
    /**
     * @description Returns the default picklist value for the Inspection__c field 
     *              on the SVMXC__Service_Order_Line__c object.
     * @return String - The default picklist value, or null if none is set.
     */
    public static String getDefaultInspectionValue() {
        // Describe the Inspection__c field
        Schema.DescribeFieldResult fieldDesc = SVMXC__Service_Order_Line__c.Inspection__c.getDescribe();
        
        // Get the picklist values
        List<Schema.PicklistEntry> picklistValues = fieldDesc.getPicklistValues();
        
        // Loop to find the default value
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.isDefaultValue()) {
                return entry.getValue();
            }
        }
        
        // If no default is found, return null
        return null;
    }
}