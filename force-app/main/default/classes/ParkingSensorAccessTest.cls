@isTest
public class ParkingSensorAccessTest {
    @TestSetup
    static void makeData(){

        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User user = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
        EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US', ProfileId = profile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
         UserName = 'uniqueUser@testorg.com');

         insert user;

         Base_Station__c station = new Base_Station__c(Name = 'Base Station');
         insert station;

         List<Sensor__c> sensorsToInsert = new List<Sensor__c>();

         for(Integer i = 0; i < 5; i++){
             Sensor__c sensor = new Sensor__c(Name = 'Sensor ' + i, Base_Station__c = station.Id, Model__c = 'Model ' + i, Status__c = 'New');
             sensorsToInsert.add(sensor);
         }

         insert sensorsToInsert;

    }

    @isTest
    public static void SensorListNoAccess() {

        User user = [SELECT Id FROM User WHERE Username = 'uniqueUser@testorg.com'];
        List<Sensor__c> sensors = new List<Sensor__c>();

        System.runAs(user){
            try{
                sensors = ParkingSensorController.getSensorList();

            }
            catch(AuraHandledException e){
                System.assertEquals(e.getMessage(), 'No access');
            }
        }

    }

    @isTest
    public static void SensorListFieldNoAccess() {

        User user = [SELECT Id FROM User WHERE Username = 'uniqueUser@testorg.com'];

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Parking_Cloud_NoEdit_User'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
        
        List<Sensor__c> sensors = new List<Sensor__c>();

        System.runAs(user){
            try{
                sensors = ParkingSensorController.getSensorList();
                
            }
            catch(AuraHandledException e){
                System.assertEquals(e.getMessage(), 'No access');
            }
        }

    }

    @isTest
    public static void SensorListHasAccess(){

        User user = [SELECT Id FROM User WHERE Username = 'uniqueUser@testorg.com'];

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Parking_Cloud_User'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);

        List<Sensor__c> sensors = new List<Sensor__c>();

        System.runAs(user){
            sensors = ParkingSensorController.getSensorList();
            System.assertEquals(5, sensors.size());
        }
    }

    @isTest
    public static void createUpdateNoAccess(){

        User user = [SELECT Id FROM User WHERE Username = 'uniqueUser@testorg.com'];

        System.runAs(user){
            try{
                ParkingSensorController.checkCreateUpdateAccess();
            }
            catch(AuraHandledException e){
                System.assertEquals(e.getMessage(), 'No access');
            }
        }


    }

    @isTest
    public static void createUpdateAccess(){

        User user = [SELECT Id FROM User WHERE Username = 'uniqueUser@testorg.com'];
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Parking_Cloud_User'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);

        System.runAs(user){
            ParkingSensorController.checkCreateUpdateAccess();
        }

    }

    @isTest
    public static void noFieldAccess(){

        User user = [SELECT Id FROM User WHERE Username = 'uniqueUser@testorg.com'];

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Parking_Cloud_NoEdit_User'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);

        System.runAs(user){
            try{
                ParkingSensorController.checkCreateUpdateAccess();
            }
            catch(AuraHandledException e){
                System.assertEquals(e.getMessage(), 'No access');
            }
        }
    }

}