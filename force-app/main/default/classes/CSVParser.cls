public class CSVParser {
    
    public static void parseCSV(String fileId){
        
        ContentVersion fileContent  = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :fileId
                                       AND IsLatest = true];
        
        String stringData = fileContent.VersionData.toString();
        List<String> lines = new List<String>();
        lines = stringData.split('\n');
        lines = removeInvalidLines(lines);
        checkBaseStation(lines);
        
        List<Sensor__c> existingSensors = [SELECT Id, Name FROM Sensor__c];
        List<Base_Station__c> allStations = [SELECT Id, Name FROM Base_Station__c]; 
        List<Sensor__c> newSensors = new List<Sensor__c>();
        
        List<String> sensorNames = new List<String>();                      // existing sensors id's (names)
        for(Sensor__c sensor: existingSensors){
            sensorNames.add(sensor.Name);
        } 
        
        for(String line: lines){
            List<String> fields = line.split(',');
            String sensorName = fields[0];
            
            if(!sensorNames.contains(sensorName)){                        // sensor not in database
                Sensor__c newSensor = new Sensor__c();
                newSensor.Name = fields[0];
                newSensor.Model__c = fields[2];
                newSensor.Status__c = fields[3];
                
                for(Base_Station__c station: allStations){
                    if(station.Name == fields[1]){
                        newSensor.Base_Station__c = station.Id;
                    }
                }
                
                newSensors.add(newSensor);
                
            }else{
                for(Sensor__c sensor : existingSensors){   
                    if(sensorName == sensor.Name){                           // existing sensors to update
                        sensor.Model__c = fields[2];
                        sensor.Status__c = fields[3];
                    }
                }
            }
        } 
        
        existingSensors.addAll(newSensors);
        
        if(!existingSensors.isEmpty()){
            upsert existingSensors;
        }
        
    }
    
    public static List<String> removeInvalidLines(List<String> lines){
        
        List<String> validStatuses = new List<String>();        
        Schema.DescribeFieldResult fieldResult = Sensor__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            validStatuses.add(pickListVal.getLabel());
        }   
        
        for (Integer i = lines.size() - 1; i >= 0 ; --i) {
            List<String> fields = lines[i].split(',');
            String sensorStatus = fields[3];
            for(Integer k = 0; k < fields.size(); k++){
                fields[k] = fields[k].trim();
                if(String.isBlank(fields[k])){
                    lines.remove(i); 
                    System.debug('Sensor from line ' + i + ' is invalid and will not be inserted.');
                    break;
                }
            }
            if(!validStatuses.contains(sensorStatus)){
                lines.remove(i); 
                System.debug('Sensor from line ' + i + ' has invalid status and will not be inserted.');
            }
        }
        return lines;
    }
    
    public static void checkBaseStation(List<String> lines){
        
        List<Base_Station__c> existingStations = [SELECT Id, Name FROM Base_Station__c]; 
        Set<Base_Station__c> stationsToInsert = new Set<Base_Station__c>();
        
        List<String> stationsNames = new List<String>();                   // existing station names
        for(Base_Station__c station: existingStations){
            stationsNames.add(station.Name);
        } 
        
        for (String line: lines){
            List<String> fields = line.split(',');
            String stationName = fields[1];
            if(!stationsNames.contains(stationName)){
                Base_Station__c newStation = new Base_Station__c(Name = stationName);
                stationsToInsert.add(newStation);
            }
        }
        List<Base_Station__c> toInsert = new List<Base_Station__c>(stationsToInsert);
        if(!toInsert.isEmpty()){
            insert toInsert;                                               // insert new stations  
        }
    }
}