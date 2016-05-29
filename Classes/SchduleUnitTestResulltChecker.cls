global class SchduleUnitTestResulltChecker implements Schedulable {
   global string sendSessionId;
   
   global SchduleUnitTestResulltChecker(String sessionId){
	  this.sendSessionId = sessionId;
	}
   global void execute(SchedulableContext sc) {
      UnitTestResultCheckerBatch b = new UnitTestResultCheckerBatch(); 
      b.sessionId = this.sendSessionId;
      database.executebatch(b);
   }
}