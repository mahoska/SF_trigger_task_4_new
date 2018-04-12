public class EmployeeTriggerHandler {
 
    public static void manage() {
       
         if(Trigger.isBefore){
            
            if(Trigger.isInsert){
                EmployeeTriggerHelper.OnBeforeInsertUpdateCheckAvailability(Trigger.new);
            }else if(Trigger.isUpdate){
                EmployeeTriggerHelper.OnBeforeInsertUpdateCheckAvailability(Trigger.new);
            }else if(Trigger.isDelete){
                
            }
            
        }else if(Trigger.isAfter){
            
            if(Trigger.isInsert){
                EmployeeTriggerHelper.OnAfterInsertUpdateCheckUniqueEmployee(Trigger.new);
            }else if(Trigger.isUpdate){
                
                EmployeeTriggerHelper.OnAfterInsertUpdateCheckUniqueEmployee(Trigger.new);
            	
                //task_4 count dev's, qa's
                if(CheckRecursive.RunMe) { 
                    EmployeeTriggerHelper.OnAfterUpdateActiveDepartmentFields(Trigger.new, Trigger.old);
                    CheckRecursive.RunMe=false;
                }
                
            }else if(Trigger.isDelete){
                
            }
            
        }else if(Trigger.isundelete){
           
        }
    }

}