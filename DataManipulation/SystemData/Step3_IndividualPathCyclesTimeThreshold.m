function Step3_IndividualPathCyclesTimeThreshold

    % initialise GUID controller
    myGuidController = GUID_Controller;
    
    close all
    miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
        "Data\Session04_ManipulatedData\RelativeTime_SystemPos\*.mat";
        
    % collect the files
    theFiles = dir(miniPattern);
    
    % initialise 
    figureSaveTitles = cell(1,length(theFiles));
        
    
    for k = 1:length(theFiles)
    
    % get the file name + read in the file
        simpleFileName = theFiles(k).name;
%         filenameCheck = theFiles(i).name;
        expID = simpleFileName(15:17);
        fullFileName = fullfile(theFiles(k).folder, simpleFileName);
        
        fprintf(1, 'Now reading %s\n', simpleFileName);
        withFolders = "Data\Session04_ManipulatedData\RelativeTime_SystemPos\"+simpleFileName;
        PosData = load(withFolders).tXYZ_System;
    
       
       
    
        %% plot!
        figure
        sgTitleName = sprintf("Path Feature: Normal; Path Habit: Textbook; Threshold: Time; Dataset: %s", strrep(simpleFileName,'_',' '));
        sgtitle(sgTitleName)
        
        endOfCycle = false;
        
        colourAlt = {'#FF6633', '#B33300', '#00B3E6',  '#E6B333', '#80B300', '#3366E6', '#FF99E6', '#33FFCC', '#B366CC', '#4D8000', '#66664D', '#991AFF', '#E666FF', '#4DB3FF', '#1AB399', '#E666B3', '#33991A', '#CC9999', '#B3B31A', '#00E680',  '#4D8066', '#809980', '#E6FF80', '#1AFF33', '#999933', '#FF3380', '#CCCC00', '#66E64D', '#4D80CC', '#9900B3',  '#E64D66', '#4DB380', '#FF4D4D', '#99E6E6', '#6666FF'};
        index = 1;
        endOfDataset = false;
        i = 1; % number of cycles in a dataset
        l = 1; % number of saved cycles across datasets
        savedCycles = 1;
    
        % bar time thresholds in seconds, at 76bpm
        barTimeLimit = [3.1579, 6.3158, 9.4737, 12.6316, 15.7895, 18.9474, 22.1053, 25.2632, 28.4211, 31.5790, 34.7369, 37.8948,41.0527, 44.2106,47.3685,	50.5264,	53.6843,	56.8422,	60.0001,	63.158,	66.3159,	69.4738,	72.6317];
        
        while(~endOfDataset)
            
            % start new plot
            subplot(3,4,i)
            hold on;
            view (0,90)
            titleName = sprintf("Bar %d", i);
            title(titleName)
            cycleStartIndex = index;
            
           
            % plot this cycle of the path
            while (~endOfCycle && ~endOfDataset) 
                
                % plot this point set
                plot3(PosData(index:index+1,2), PosData(index:index+1,3), PosData(index:index+1,4), 'color', colourAlt{i})
                index = index + 1;
        
                % check if at the end of the cycle
                endOfCycle = checkEndOfCycle(PosData(index,:), barTimeLimit(i));
                endOfDataset = checkEndOfDataset(length(PosData), index+2);
        
            end
    
            % save if part of good dataset
            cycleEndIndex = index;
    
            if (i > 3 && i < 9)
                clear tXYZ;
    %             sprintf("cycleStartIndex: %d. cycleEndIndex: %d.",cycleStartIndex, cycleEndIndex)
                tXYZ = PosData(cycleStartIndex:cycleEndIndex, :);
                fileName = sprintf("Data\\Session04_ManipulatedData\\SavedCycles\\%sSavedCycle_%d.mat",simpleFileName(1:21), l);
                save(fileName, 'tXYZ');
                l = l+1;
            end
        
            % move on to the new cycle
            endOfCycle = false;
            i = i + 1;
            
        end
    
        % get graph details
        graphDetails = sprintf('System_SplitCycles_TimeBased_%s',  simpleFileName);
        
        % save in GUID directory, get GUID
        folderToSaveIn = 'Visualisations/Session04_IndividualCyclesTimeThreshold';   % Your destination folder
        descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, fullFileName, folderToSaveIn, datetime('now'));
        GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;
        
        % add GUID to title 
        figureSaveTitles{k} = sprintf('%s_%s.png', graphDetails, GUIDToAppend);
    
        % set title
        sgtitle(strrep(graphDetails, '_', ' '))
    
    end
    
    
    
    % get all open figures
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    
    % save all open figures
    for iFig = 1:length(FigList)
      FigHandle = FigList(iFig);
      FigName   = figureSaveTitles{iFig};
      fprintf("now saving: %s\n", FigName)
      saveas(FigHandle, fullfile(folderToSaveIn, FigName));
    end
    
    
    function [isEndOfCycle] = checkEndOfCycle(point, barTimeLimitCheck) 
    
        isEndOfCycle = false;
    
        if (point(1) >= barTimeLimitCheck)
            isEndOfCycle = true;
        end
    
    end
    
    function [isEndofDataset] = checkEndOfDataset(lengthDataSet, nextIndex) 
    
        isEndofDataset = false;
    
        if (nextIndex >= lengthDataSet)
            isEndofDataset = true;
        end
    
    end


end