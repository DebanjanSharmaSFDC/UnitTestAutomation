global class UnitTestReportPdfController {
	
	public Id jobId;
	public List<ApexTestResult> testResultList {get;set;}
	public Integer overAllCodeCoverage {get;set;}
	public List<ApexTestResult> positiveOutput {get;set;}
	public List<ApexTestResult> negativeOutput {get;set;}
	public List<DisplayClassDetails> classDetails {get;set;}
	public DateTime curTime {get;set;}
	
	public UnitTestReportPdfController(){
		//genearateTestResult();
	}
	public Id getJobId(){
		
		genearateTestResult();
		return jobId;
	}
	public void setJobId(Id salesforceId){
		this.jobId = salesforceId;
	}
	public void genearateTestResult(){
		try{
		  curTime = DateTime.now();
		  testResultList = [SELECT Outcome,
	                   MethodName,
	                   Message,
	                   StackTrace,
	                   AsyncApexJobId, 
	                   ApexClass.Name,
	                   ApexClass.Body,
	                   ApexClass.LengthWithoutComments,
	                   ApexClass.NamespacePrefix,
	                   ApexClass.Status,
	                   ApexLogId,
	                   ApexLog.DurationMilliseconds,
	                   ApexLog.Operation,
	                   ApexLog.Request,
	                   ApexLog.Status,
	                   ApexLog.Location,
	                   ApexLog.Application
	            FROM ApexTestResult 
	            WHERE AsyncApexJobId = :jobId];
           
            positiveOutput = new List<ApexTestResult>();
            negativeOutput = new List<ApexTestResult>();
            
            for(ApexTestResult testResult:testResultList){
            	
            	if(testResult.Outcome == 'Pass'){
            		
            		positiveOutput.add(testResult);
            		
            	}else{
            		
            		negativeOutput.add(testResult);
            		
            	}
            }
            HTTPRequest req = new HTTPRequest();
		    req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() 
			    + '/services/data/v29.0/tooling/query/?q='+EncodingUtil.urlEncode('SELECT PercentCovered FROM ApexOrgWideCoverage', 'UTF-8'));
			req.setMethod('GET');
			// OAuth header
			req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
		    req.setHeader('Content-Type', 'application/json');
		    Http h = new Http();
		    HttpResponse res = h.send(req);
		    System.debug(res.getBody());
		    
            OrgCoverageWrapper obj = OrgCoverageWrapper.parse(res.getBody());
            System.debug(obj.records[0].PercentCovered);
            overAllCodeCoverage = obj.records[0].PercentCovered;
            
            HTTPRequest reqForIndividualTestCoverage = new HTTPRequest();
		    reqForIndividualTestCoverage.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() 
			    + '/services/data/v29.0/tooling/query/?q='+EncodingUtil.urlEncode('SELECT ApexClassOrTrigger.Name,sum(NumLinesCovered)NumLinesCovered,sum(NumLinesUncovered)NumLinesUncovered FROM ApexCodeCoverage group BY ApexClassOrTrigger.Name', 'UTF-8'));
			reqForIndividualTestCoverage.setMethod('GET');
			// OAuth header
			reqForIndividualTestCoverage.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
		    reqForIndividualTestCoverage.setHeader('Content-Type', 'application/json');
		    Http h1 = new Http();
		    HttpResponse resOfIndividualClass = h1.send(reqForIndividualTestCoverage);
		    System.debug('resOfIndividualClass'+resOfIndividualClass);
		    
            ApexCodeCoverageWrapper objIndividualCoverage = ApexCodeCoverageWrapper.parse(resOfIndividualClass.getBody());
            List<ApexCodeCoverageWrapper.Records> listOfClasseslistOfClasses = new List<ApexCodeCoverageWrapper.Records>();
            listOfClasseslistOfClasses = objIndividualCoverage.records;
            System.debug(LoggingLevel.WARN,'listOfClasseslistOfClasses'+listOfClasseslistOfClasses);
            classDetails = new List<DisplayClassDetails>();
            for(ApexCodeCoverageWrapper.Records eachRecord: listOfClasseslistOfClasses){
            	
            	DisplayClassDetails clsDetail = new DisplayClassDetails();
            	clsDetail.className = eachRecord.Name;
            	clsDetail.codeCoverage = Integer.valueOf((eachRecord.NumLinesCovered/(eachRecord.NumLinesCovered+eachRecord.NumLinesUncovered))*100);
            	
            	if(clsDetail.codeCoverage < 75 ){
            		
            		clsDetail.severity = 'Critical';
            		
            	}else if(clsDetail.codeCoverage >= 75 && clsDetail.codeCoverage <= 85){
            		
            		clsDetail.severity = 'High';
            		
            	}else if(clsDetail.codeCoverage >= 95){
            		
            		clsDetail.severity = 'No Threat';
            		
            	}else{
            		clsDetail.severity = 'Low';
            	}
            	classDetails.add(clsDetail);
            }
            System.debug(LoggingLevel.WARN,'classDetails--->'+classDetails);
		}catch(Exception e){
			System.debug(LoggingLevel.WARN,'Exception--->'+e.getStackTraceString());
		} 
	}
	
	Public class DisplayClassDetails{
		public string className {get;set;}
		public integer codeCoverage {get;set;}
		public String severity {get;set;}
	}

}