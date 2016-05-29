global class SchduleUnitTestResulltChecker implements Schedulable {
   global void execute(SchedulableContext sc) {
      UnitTestResultCheckerBatch b = new UnitTestResultCheckerBatch(); 
      database.executebatch(b);
   }
}