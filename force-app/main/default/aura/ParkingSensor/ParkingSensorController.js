({
    doInit : function(component, event, helper){
        helper.refreshTable(component);
    },
    
    handleUploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var uploadedFile = uploadedFiles[0];
        
        var action = component.get("c.parseFile");
        action.setParams({
            fileId: uploadedFile.documentId
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                helper.refreshTable(component);
            }
        }); 
        $A.enqueueAction(action);
    }
})