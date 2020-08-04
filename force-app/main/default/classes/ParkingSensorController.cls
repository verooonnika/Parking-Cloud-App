public class ParkingSensorController {
    
    @AuraEnabled
    public static List<Sensor__c> getSensorList(){
        List<Sensor__c> sensors = [SELECT Id, Name, Base_Station__c, Base_Station__r.Name, Model__c, Status__c FROM Sensor__c];
        return sensors;
        
    }
    
    @AuraEnabled
    public static void parseFile(String fileId){
        CSVParser.parseCSV(fileId);
    }
    
}