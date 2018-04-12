public with sharing class EmployeeTriggerService {
   
    public static DevQaFieldsService.Info filterEmployee(Employee__c emplOldRecord, Employee__c emplNewRecord){
        Integer Qa = 0;
        Integer Dev = 0;
        
        if(emplOldRecord.isActive__c == False && emplNewRecord.isActive__c == True){
            if(emplNewRecord.IT_Department__c == 'QA'){
                Qa++; 
            }else if(emplNewRecord.IT_Department__c == 'DEV'){
                Dev++; 
            }
        }else if(emplOldRecord.isActive__c == True && emplNewRecord.isActive__c == False){
            if(emplOldRecord.IT_Department__c == 'QA'){
                Qa--; 
            }else if(emplOldRecord.IT_Department__c == 'DEV'){
                Dev--; 
            }
        }else if(emplOldRecord.isActive__c == True && emplNewRecord.isActive__c == True){
            
            if(emplNewRecord.IT_Department__c ==  'QA' && emplOldRecord.IT_Department__c !=  'QA'){
                Qa++; 
            }
            if(emplNewRecord.IT_Department__c ==  'DEV' && emplOldRecord.IT_Department__c !=  'DEV'){
                Dev++; 
            }
            if(emplOldRecord.IT_Department__c ==  'QA' && emplNewRecord.IT_Department__c !=  'QA' ){
                Qa--;
            }
            if(emplOldRecord.IT_Department__c ==  'DEV' && emplNewRecord.IT_Department__c !=  'DEV' ){
                Dev--; 
            }
        }
        
        return new DevQaFieldsService.Info(Qa,Dev);
    }
   
}