public with sharing class EmployeeTriggerHelper {
    
    public static void OnAfterInsertUpdateCheckUniqueEmployee(List<Employee__c> employees){
        List<String> firstNames = new List<String>();
        List<String> lastNames = new List<String>();
        List<Date> birthdays = new List<Date>();
         
         for (Employee__c insertItem : employees) {
             firstNames.add(insertItem.First_Name__c);
             lastNames.add(insertItem.Last_Name__c);
             birthdays.add(insertItem.Birthday__c);
         }
         
         List<Employee__c>  resDublicat = [
                      SELECT First_Name__c, Last_Name__c, Birthday__c
                      FROM Employee__c 
                      WHERE First_Name__c IN :firstNames AND
                      		Last_Name__c IN :lastNames AND 
                      		Birthday__c IN :birthdays  
         			];
         
         for (Employee__c insertItem : employees) {
             for(Employee__c errorItem : resDublicat){
                 if(
                     insertItem.First_Name__c == errorItem.First_Name__c && 
                     insertItem.Last_Name__c == errorItem.Last_Name__c && 
                     insertItem.Birthday__c == errorItem.Birthday__c &&
                     insertItem.Id != errorItem.Id
                 ){
                     insertItem.addError('adding a record is not possible. An employee with such data already exists');
                     break;
                 }
             }
         }
    }
    
    //task_4 count dev's, qa's
    public static void OnAfterUpdateActiveDepartmentFields(List<Employee__c> employeesNew, List<Employee__c> employeesOld){
            
        	Map<Id, DevQaFieldsService.Info> mapEmpl = new Map<Id, DevQaFieldsService.Info>();
            //consider changes
            for(Integer i = 0, size = employeesNew.size(); i<size; i++){
             
                //check whether the field  employee  has changed Active/Department - filter employee
                DevQaFieldsService.Info resFilterEmpl = EmployeeTriggerService.filterEmployee(employeesOld[i], employeesNew[i]);

                //if change - fill map changes for eployess
                if( resFilterEmpl.changeQa != 0 || resFilterEmpl.changeDev != 0){
                    DevQaFieldsService.addRecordToMap(mapEmpl, employeesOld[i].Id, resFilterEmpl);
                }       
            }
        
        Set<Id> emplIds = mapEmpl.keySet();
        List<AggregateResult> lsProjectsOfEmpls = [
            SELECT Employee__c, Project__c 
            FROM EmployeeSkills__c 
            WHERE  Employee__c  IN :emplIds 
            GROUP BY Project__c, Employee__c
        ];
        
        //create Map(key - id project and info - count dev's and qa's)
        Map<Id, DevQaFieldsService.Info> mapUpd = new Map<Id, DevQaFieldsService.Info>();
        for(AggregateResult item : lsProjectsOfEmpls){
			Id idEmpl = (Id) item.get('Employee__c');
            Id idProject = (Id) item.get('Project__c');
            DevQaFieldsService.Info infoForUpd = mapEmpl.get(idEmpl);
            DevQaFieldsService.addRecordToMap(mapUpd, idProject, infoForUpd);
        }

            //create list of projects for update
            List<Project__c> updProjectList = DevQaFieldsService.getListProjectsToUbdate(mapUpd, true);
            //update all the affected projects
            update updProjectList;
        }
    
    public static void OnBeforeInsertUpdateCheckAvailability(List<Employee__c> employeesNew){
         for (Employee__c empl : employeesNew) {
             if(empl.Part_Time__c == FALSE && empl.Availability__c != 8){
                 empl.Availability__c = 8;
             }
         }
    }
}