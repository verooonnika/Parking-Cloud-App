@isTest
public class ParkingSensorTest {
    @testSetup
    public static void createRecords() {
        
        Base_Station__c station = new Base_Station__c(Name = 'Base Station');
        insert station;
        
        Sensor__c sensor = new Sensor__c(Name = 'idUpdateSensor', Base_Station__c = station.Id, Model__c = 'toUpdate', Status__c = 'New');
        insert sensor;
        
        ContentVersion testFile = new ContentVersion(
            Title = 'Sensors',
            PathOnClient = 'Sensors.csv',
            VersionData = Blob.valueOf('idNewStation,New Station,Model1,New\n' +
                                       'idExistingStation,Base Station,Model2,New\n' + 
                                       'idEmptyField, ,Model3,New\n' + 
                                       'idUpdateSensor,Base Station,Model4,New\n' + 
                                       'idNotFromPicklist,Base Station,Model5,wrong'),
            IsMajorVersion = true
        );
        
        insert testFile;
        
    }
    
    @isTest
    public static void testParkingSensors(){
        List<ContentVersion> lst = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Sensors' AND IsLatest = true];
        String fileId = lst[0].ContentDocumentId;
        List<Sensor__c> sensorList = ParkingSensorController.getSensorList();
        System.assertEquals(1, sensorList.size());
        ParkingSensorController.parseFile(fileId);
        
        List<Base_Station__c> newStation = [SELECT Id, Name FROM Base_Station__c WHERE Name = 'New Station'];
        System.assertEquals(1, newStation.size());
        
        Integer sensors = [SELECT COUNT() FROM Sensor__c WHERE Name = 'idNotFromPicklist'];
        System.assertEquals(0, sensors);
        
        Sensor__c updatedSensor = [SELECT Name, Model__c FROM Sensor__c WHERE Name = 'idUpdateSensor' LIMIT 1];
        System.assertEquals('Model4', updatedSensor.Model__c);
    }
    
}