({
    refreshTable : function(component) {
        component.set("v.columns", [
            {label: 'Sensor ID', fieldName: 'Name', type: 'text', editable: false, cellAttributes: { alignment: 'left' }, typeAttributes: {required: true }},
            {label: 'Base Station', fieldName: 'Base_Station__c', type: 'text', cellAttributes: { alignment: 'left' },  typeAttributes: {required: true }},
            {label: 'Model', fieldName: 'Model__c', type: 'text', editable: false, cellAttributes: { alignment: 'left' }, typeAttributes: {required: true }  },
            {label: 'Status', fieldName: 'Status__c', type: 'text', editable: false, cellAttributes: { alignment: 'left' }, typeAttributes: {required: true }},
        ]);
            
            var action = component.get("c.getSensorList");
            action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
            var rows = response.getReturnValue();
            for (var i = 0; i < rows.length; i++) {
            rows[i].Base_Station__c = rows[i].Base_Station__r.Name;
                      } 
                      component.set("v.Sensor", rows);
    }
});
$A.enqueueAction(action);
}
})