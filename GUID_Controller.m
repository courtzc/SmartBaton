classdef GUID_Controller

%     How to call this:
%     myGuidController = GUID_Controller;
%     descriptiontouse = "this is a test"
%     GUIDToAppend = myGuidController.updateGuidDirectory(descriptiontouse).currGUID

    properties
        currGUID
    end
    
    methods
        function controllerFunc = updateGuidDirectory(obj, description)
            
            % read in GUID we're up to
            GUID = load("GUID_Counter.txt");
%             sprintf("desciprtion: %s", description)
            
            % returning to append to figure
            GUIDString = sprintf("%06d", GUID);
            controllerFunc.currGUID = GUIDString;

            % write GUID and description to excel file
            InfoToWrite = [GUIDString, description];
            writematrix(InfoToWrite,'GUID_Directory.xlsx','WriteMode','append')
            
            % update GUID_Counter for next time
            GUID = GUID + 1;
            fid=fopen('GUID_Counter.txt','w');
            fprintf(fid,'%06d',GUID);
            fclose(fid);
        end
        
    end
end

