public class DevQaFieldsService {
    
    public static List<Project__c>  getListProjectsToUbdate(Map<Id, Info> infoMap, Boolean isAdd){
        List<Project__c> updProjectList = new List<Project__c>();
        
        //go through projects that require changes, 
        //read the original data and change them taking into account new data
        Set<Id> idList= infoMap.keySet();
        //get info Project before update
        Map<ID, Project__c> projectInfo = new Map<ID, Project__c>([SELECT Id, QA_s__c, Developers__c FROM Project__c WHERE Id IN : idList]);

        for(Id i: idList){
            Info infoProject = infoMap.get(i);
            Project__c p = projectInfo.get(i);
            if(isAdd){
                p.QA_s__c += infoProject.changeQa;
                p.Developers__c += infoProject.changeDev;
            }else{
                p.QA_s__c -= infoProject.changeQa;
                p.Developers__c -= infoProject.changeDev;
            }
            updProjectList.add(p);
        }
        return  updProjectList;   
    }
    
    public  static Map<Id, Info> addRecordToMap(Map<Id, Info> infoMap, Id idProject, Info infoEmpl){
        Info inf = infoMap.get(idProject);
        //if record with project isset - update it else create record for this project
        if(inf != null){
            inf.changeQa += infoEmpl.changeQa;
            inf.changeDev += infoEmpl.changeDev;
        }else{
            infoMap.put(idProject, infoEmpl);
        }
        return infoMap;
    }
    
    public class Info {     
        public Integer changeQa{
            get{
                return changeQa == null? 0 : changeQa;
            }
            set;
        }
        
        public Integer changeDev{
            get{
                return changeDev == null? 0 : changeDev;
            }
            set;
        }
        
        public Info(Integer q, Integer d){
            changeQa = q;
            changeDev = d;
        }
    }
}