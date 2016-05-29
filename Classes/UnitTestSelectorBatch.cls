/**************
/*** Name: UnitTestSelectorBatch.cls
/*** Description: Select test classes & start unit test execution.
/*** Developer Name: Debanjan Sharma
/*** Last Modified On:
/*** Last Modification Details:
/*** Version:
/****************/
global class UnitTestSelectorBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	global Database.QueryLocator start(Database.BatchableContext bc){
    
        return Database.getQueryLocator([SELECT Id,Name,NamespacePrefix FROM ApexClass WHERE Name LIKE '%Test' and NamespacePrefix='']);
    
    }
    
       // Execute method
 	global void execute(Database.BatchableContext bc,List<ApexClass> testClasses){
    	//Check if testClasses list is not empty
    	if(!testClasses.isEmpty()){
    		
    		Unit_Test_Log__c logUnitTest = new Unit_Test_Log__c();
    		
    		List<ApexTestQueueItem> testQueueItem = new List<ApexTestQueueItem>();
    		
    		//Iterate thorugh all test class & add in test queue item
    		for(ApexClass eachtestClass:testClasses){
    			
    			ApexTestQueueItem eachQueueItem = new ApexTestQueueItem();
    			eachQueueItem.ApexClassId = eachtestClass.Id;
    			testQueueItem.add(eachQueueItem);
    			
    		}
    		// Insert testQueueItem list to start unit test execution
    		try{
    			insert testQueueItem;
    			
    		}catch(Exception e){
    			
    		}
    		logUnitTest.Email_Sent__c = false;
    		logUnitTest.Status__c = 'In Progress';
    		
    		//Get AsyncJobId for test class execution
    		ApexTestQueueItem item = [SELECT ParentJobId FROM ApexTestQueueItem WHERE Id=:testQueueItem[0].Id LIMIT 1];
    		
    		logUnitTest.SalesforceJobId__c = item.ParentJobId;
    		
    		try{
    			insert logUnitTest;
    			
    		}catch(Exception e){
    			
    		}
    	}
    }
    
    // Finish Method 
    global void finish(Database.BatchableContext bc){}
}