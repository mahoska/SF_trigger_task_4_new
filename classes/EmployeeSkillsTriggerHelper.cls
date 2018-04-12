public with sharing class EmployeeSkillsTriggerHelper {
    
	public static void OnAfterInsertUpdateCheckAssignedTime(List<EmployeeSkills__c> skills){
       for(EmployeeSkills__c item: skills){
            List<AggregateResult> res = [
                SELECT Employee__r.Id emId, SUM(Assigned_Time__c) assignedTime  
                FROM EmployeeSkills__c 
                WHERE Employee__r.Id =: item.Employee__c AND Id !=: item.Id
                GROUP BY Employee__r.Id
                LIMIT 1
            ];
            
            List<Employee__c> em = [SELECT Availability__c FROM Employee__c  WHERE Id =: item.Employee__c];
            
            if(
                (!res.isEmpty() && em[0].Availability__c < (Double)res[0].get('assignedTime') + item.Assigned_Time__c) ||
                (res.isEmpty() && em[0].Availability__c < item.Assigned_Time__c)
            ){
                item.addError('The number of hours(Assigned Times) exceeds hours(availability) of employee.');
            }
            
        }
    }
    
    //task_4(count dev's and qa's)
    public static void OnAfterInsertDeleteEmplSkChangeProjectFieldDevAndQA(List<EmployeeSkills__c> skills, Boolean isInsert){
        
        Set<Id> emplSetIds = new Set<Id>();
        
        for(EmployeeSkills__c sk: skills){
            emplSetIds.add(sk.Employee__c);
        }
        
        Map<ID, Employee__c> empls = 
            new Map<ID, Employee__c>([SELECT Id, IT_Department__c, isActive__c FROM Employee__c  WHERE Id IN :emplSetIds]);
        
        List<EmployeeSkills__c> skillsAfterFilter = new List<EmployeeSkills__c>();
        for(EmployeeSkills__c sk: skills){
            Employee__c empl = empls.get(sk.Employee__c);
            
            if(empl.isActive__c == True && (empl.IT_Department__c == 'QA' || empl.IT_Department__c == 'DEV')){
                skillsAfterFilter.add(sk);
            }
        }
        
        Set<Id> emplSetIdsAfterFilter = new Set<Id>();
        Set<Id> prjSetIdsAfterFilter = new Set<Id>();
        
        for(EmployeeSkills__c sk: skillsAfterFilter){
            emplSetIdsAfterFilter.add(sk.Employee__c);
            prjSetIdsAfterFilter.add(sk.Project__c);
        }
        
        List <EmployeeSkills__c> allSkills =  [SELECT Id, Project__c, Employee__c 
                                               FROM EmployeeSkills__c 
                                               WHERE Employee__c IN :emplSetIdsAfterFilter AND Project__c IN :prjSetIdsAfterFilter
                                              ];
        
        
        Map<Id, Set<EmployeeSkills__c>> skillsForProject =  new  Map<Id, Set<EmployeeSkills__c>>();
        
        for(EmployeeSkills__c sk : allSkills){
            Set<EmployeeSkills__c> setES = skillsForProject.get(sk.Project__c);
            if(setES != null){
                setES.add(sk);
            }else{
                skillsForProject.put(sk.Project__c,new Set<EmployeeSkills__c>{sk});
            }
        }
        
        Map<Id, DevQaFieldsService.Info> mapUpd = new Map<Id, DevQaFieldsService.Info>();
        for(EmployeeSkills__c sk: skillsAfterFilter){
            Id prId =  sk.Project__c;
            Employee__c em = empls.get(sk.Employee__c);
            Integer Qa = em.IT_Department__c == 'QA' ? 1 : 0 ;
            Integer Dev = em.IT_Department__c == 'DEV' ? 1 : 0; 
            DevQaFieldsService.Info emInfo = new DevQaFieldsService.Info(Qa,Dev);
            
            Set<EmployeeSkills__c> prSk = skillsForProject.get(prId);
            if(!isInsert && prSk == null) {
                DevQaFieldsService.addRecordToMap(mapUpd, prId, emInfo);
            }else{
                
                Integer countEmpl = 0;
                for(EmployeeSkills__c item : prSk) {
                    if(item.Employee__c == sk.Employee__c){
                        countEmpl++;
                    }
                }
                
                if((isInsert && countEmpl == 1)){
                    DevQaFieldsService.addRecordToMap(mapUpd, prId, emInfo);
                }
            }
        }
        
        List<Project__c> updProjectList;
        if(isInsert){
            updProjectList = DevQaFieldsService.getListProjectsToUbdate(mapUpd, true);
        }else{
            updProjectList = DevQaFieldsService.getListProjectsToUbdate(mapUpd, false);
        }
        
        update updProjectList;   

    }
}