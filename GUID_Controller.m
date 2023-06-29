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

        function controllerFunc = saveFigures(obj, graphDetails, GUIDToAppend, FigList, folderToSaveIn)
            
            disp("Fig List:")
            disp(FigList)
            % get all open figures, add GUID to file name 
            figureSaveTitle = sprintf('%s_%s.fig', strrep(graphDetails, ' ', '_'), GUIDToAppend);
            pngSaveTitle = sprintf('%s_%s.png', strrep(graphDetails, ' ', '_'), GUIDToAppend);
            
            
            % save all open figures
            for iFig = 1:length(FigList)
              FigHandle = FigList(iFig);
              FigName   = figureSaveTitle;
              pngName   = pngSaveTitle;
              fprintf("now saving: %s\n", FigName)
              saveas(FigHandle, fullfile(folderToSaveIn, FigName));
              fprintf("now saving: %s\n", pngName)
              saveas(FigHandle, fullfile(folderToSaveIn, pngName));
            end
        end
        
    end
end

