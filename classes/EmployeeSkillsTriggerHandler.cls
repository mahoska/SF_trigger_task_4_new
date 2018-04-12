public class EmployeeSkillsTriggerHandler {
    
	public EmployeeSkillsTriggerHandler() {
        this.manage();
    }
 
    public void manage() {
       
        if(Trigger.isBefore){
            
            if(Trigger.isInsert){
                
            }else if(Trigger.isUpdate){
                
            }else if(Trigger.isDelete){
                
            }
            
        }else if(Trigger.isAfter){
            
            if(Trigger.isInsert){
                
                EmployeeSkillsTriggerHelper.OnAfterInsertUpdateCheckAssignedTime(Trigger.New);
                //task_4(count dev's and qa's)
                //second param == true - if insert
                EmployeeSkillsTriggerHelper.OnAfterInsertDeleteEmplSkChangeProjectFieldDevAndQA(Trigger.New, true);
                
            }else if(Trigger.isUpdate){
                
 				EmployeeSkillsTriggerHelper.OnAfterInsertUpdateCheckAssignedTime(Trigger.New);
                
        	}else if(Trigger.isDelete){
                
                //task_4 count dev's, qa's
                //second param == false -  if delete
                EmployeeSkillsTriggerHelper.OnAfterInsertDeleteEmplSkChangeProjectFieldDevAndQA(Trigger.Old, false);
                
        	}
            
        }else if(Trigger.isundelete){
           
        }
    }
}