global class ScheduleUnitTestSelector implements Schedulable {
   global void execute(SchedulableContext sc) {
      UnitTestSelectorBatch b = new UnitTestSelectorBatch(); 
      database.executebatch(b);
   }
}