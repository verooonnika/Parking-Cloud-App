public class ParkingSensorController {
    
    @AuraEnabled
    public static List<Sensor__c> getSensorList(){
        if (!(Schema.sObjectType.Sensor__c.isAccessible() || Schema.sObjectType.Base_Station__c.isAccessible())) { 
            throw new AuraHandledException('No access');
        }
        
        String [] requiredFields = new String [] {'Name', 'Base_Station__c', 'Model__c', 'Status__c'};
            
            Map<String,Schema.SObjectField> sensorFields = Schema.SObjectType.Sensor__c.fields.getMap();
        
        for(String fieldName: requiredFields){ 
            if(!sensorFields.get(fieldName).getDescribe().isAccessible()){
                throw new AuraHandledException('No access');
            }
        }
        
        List<Sensor__c> sensors = [SELECT Id, Name, Base_Station__c, Base_Station__r.Name, Model__c, Status__c FROM Sensor__c];
        
        return sensors;
        
    }
    
    @AuraEnabled
    public static void parseFile(String fileId){
        
        CSVParser.parseCSV(fileId);
    }
    
    @AuraEnabled
    public static void checkCreateUpdateAccess(){
        
        if (!(Schema.sObjectType.Sensor__c.isCreateable() || Schema.sObjectType.Base_Station__c.isCreateable()
              || Schema.sObjectType.Sensor__c.isUpdateable() || Schema.sObjectType.Base_Station__c.isUpdateable())) { 
                  throw new AuraHandledException('No Access');
              }
        
        Map<String,Schema.SObjectField> sensorFields = Schema.SObjectType.Sensor__c.fields.getMap();
        Map<String,Schema.SObjectField> stationFields = Schema.SObjectType.Base_Station__c.fields.getMap();
        
        String [] requiredSensorFields = new String [] {'Name', 'Base_Station__c', 'Model__c', 'Status__c'};
            
            for(String fieldName: requiredSensorFields){
                if(!(sensorFields.get(fieldName).getDescribe().isCreateable() || sensorFields.get(fieldName).getDescribe().isUpdateable())){
                    throw new AuraHandledException('No Access');
                }
            }
        
        String [] requiredStationFields = new String [] {'Name'};
            
            for(String fieldName: requiredStationFields){ 
                if(!(stationFields.get(fieldName).getDescribe().isCreateable() || stationFields.get(fieldName).getDescribe().isUpdateable())){
                    throw new AuraHandledException('No Access');
                }
            }
    }
}