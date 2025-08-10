/**
* @description Trigger handler for work order
**/
public without sharing class WorkOrderTriggerHandler extends TriggerHandler{
    
    /**
	* @description Function to handle the after update trigger event
	**/
	public override void afterUpdate() {
        WorkOrderHelper.createBillings((List<SVMXC__Service_Order__c>)Trigger.new, (Map<Id, SVMXC__Service_Order__c>)Trigger.oldMap);
	}
}