/**************
/*** Name: UnitTestResultCheckerBatch.cls
/*** Description: Select record from Unit Test Log & generate report for completed jobs
/*** Developer Name: Debanjan Sharma
/*** Last Modified On:
/*** Last Modification Details:
/*** Version:
/****************/
global class UnitTestResultCheckerBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	global Database.QueryLocator start(Database.BatchableContext bc){
    
        return Database.getQueryLocator([SELECT Id,Name,Email_Sent__c,SalesforceJobId__c,Status__c FROM Unit_Test_Log__c WHERE Status__c ='In Progress' and Email_Sent__c = false]);
    
    }
    
       // Execute method
 	global void execute(Database.BatchableContext bc,List<Unit_Test_Log__c> logList){
    	//Check if logList list is not empty
    	if(!logList.isEmpty()){
    		
    		Set<Id> asyncJobIdSet = new Set<Id>();
    		
    		for(Unit_Test_Log__c eachLog: logList){
    			asyncJobIdSet.add(eachLog.SalesforceJobId__c);
    		}
    		
    		//Map Job id & list of test classes
    		map<Id,List<ApexClass>> testClassParentIdMap = new map<Id,List<ApexClass>>();
    		
    		//Job Id & status Map
    		
    		map<Id,Boolean> inProgressJobStatusMap = new map<Id,Boolean>();
    		    		
    		//Get test classes related to parent job id
    		
    		List<ApexTestQueueItem> queueItemList = [SELECT ApexClass.Name,Status,ExtendedStatus,ParentJobId FROM ApexTestQueueItem WHERE ParentJobId in :asyncJobIdSet];
    		
    		 for (ApexTestQueueItem eachQueueItem : queueItemList){
    		 	
                 
                 // Creating map of job id & status
                 
                  if (eachQueueItem.Status != 'Completed' && eachQueueItem.Status != 'Failed' && eachQueueItem.Status != 'Aborted'){
                  	
                    inProgressJobStatusMap.put(eachQueueItem.ParentJobId,false);
                    
                 }
            }
            
            //Changing status of Completed Logs
            List<Unit_Test_Log__c> sendEmailReport = new List<Unit_Test_Log__c>();

            for(Unit_Test_Log__c eachLog: logList){
            	
            	if(!inProgressJobStatusMap.containsKey(eachLog.SalesforceJobId__c)){
            		eachLog.Status__c = 'Completed';
					sendEmailReport.add(eachLog);
            	}
    			
    		}
            
            try{
            	
            	update logList;
            	
            }catch(Exception e){
            	
            }
			sendEmail(sendEmailReport);
            
    		
    	}
    }
    
    // Finish Method 
    global void finish(Database.BatchableContext bc){}
	//Send Email
	global void sendEmail(List<Unit_Test_Log__c> uintTestList){
		
		List<EmailRecipients__c> emailIdList = EmailRecipients__c.getAll().Values();
		List<String> emailAddressList = new List<String>();

		if (!emailIdList.isEmpty()){
			
			for (EmailRecipients__c eachEmail : emailIdList){
				
				emailAddressList.add(eachEmail.Email_Id__c);
			}
		}

		List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
		List<EmailTemplate> emailTemplateList = [select id from EmailTemplate where name ='UnitTestReportTemplate'];
		if (!uintTestList.isEmpty() && !emailTemplateList.isEmpty()){
			
			for (Unit_Test_Log__c eachUnit: uintTestList){

				Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
				msg.setTemplateId(emailTemplateList.get(0).Id);
				msg.setToAddresses(emailAddressList);
				msg.setTargetObjectId(UserInfo.getUserId());
				msg.setWhatId(eachUnit.Id);
				msg.setSenderDisplayName('OIT Support');
				msg.setSaveAsActivity(false);
				emailMessageList.add(msg);

			}

		}

		if (!emailMessageList.isEmpty()){
			
			Messaging.sendEmail(emailMessageList);
		}
		
	
	}
}