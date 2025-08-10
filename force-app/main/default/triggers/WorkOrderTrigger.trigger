trigger WorkOrderTrigger on SVMXC__Service_Order__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //Trigger handler implementation to handle every event
    new WorkOrderTriggerHandler().run();
}