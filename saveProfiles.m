function alignMHQ = saveProfiles(alignMHQ, handles)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


isRawCheck = get(handles.rawProfileExport,'Value');
isAlignCheck = get(handles.alignAvgExport,'Value');

if ~isRawCheck && ~isAlignCheck
    msgbox('Please select profiles to export.', 'Select Profiles', 'help');
    return
end


%Select ions to export
[ionIdxSelect, isSelect] =  listdlg('PromptString',     {'Please select ion profiles'
                                                        'to be exported:'},                 ...
                                    'SelectionMode',    'multiple',                         ...
                                    'ListString',       alignMHQ.ionList                    ...
                                    );

if isempty(ionIdxSelect) || isSelect == 0, return; end %exit if nothing selected or user cancels
                     

fileDlg = 'Please select a file name and location for the output';
[outputFile, outputFolder, idx] = uiputfile('*.xlsx',fileDlg);

if idx == 0, return; end %exit if user cancels

[~, fileName, ~] = fileparts(outputFile);

ionIdx = get(handles.alignIonList, 'Value');
ionSelected = alignMHQ.ionList{ionIdx};
ionTitle = strrep(ionSelected,'_','.');

spreadsheetPath = fullfile(outputFolder, outputFile);
warning('off')

w = waitbar(0, 'Writing Data to Excel Sheets...');
%get alignMHQ info and add to its own sheet
infoCell = buildExportInfo(alignMHQ);
[cRow, cCol] = size(infoCell);
xlswrite(spreadsheetPath, infoCell, 'Export Info');


for i = 1:numel(ionIdxSelect)
    ionName = alignMHQ.ionList{ionIdxSelect(i)};
    sheetNameRaw = strcat(ionName, '+raw');
    sheetNameAlign = strcat(ionName, '+align');

    for j = 1:alignMHQ.numStrands
        strandName = alignMHQ.strandList{j};
        header = {'xData', strandName}; %header for excel
        %write profiles to excel sheets
        if isRawCheck
            %concatenate and convert data to cells to append column headers for export
            dataCells = num2cell([alignMHQ.profileData.(strandName).xData'                      ...
                                  alignMHQ.profileData.(strandName).(ionName).mean']);
            rowIdx = numel(alignMHQ.profileData.(strandName).(ionName).mean)+1; %length of data
            range = [xlsAddr(2, j*2 - 1) ':' xlsAddr(rowIdx,j*2)];
            
            xlswrite(spreadsheetPath, [header; dataCells], sheetNameRaw, range); %write xdata and profile to spreadsheet
        end
        
        if isAlignCheck
            %repeat above for aligned data
            dataCells = num2cell([alignMHQ.alignedProfileData.(strandName).xData'               ...
                                  alignMHQ.alignedProfileData.(strandName).(ionName).mean']);
                              
            rowIdx = numel(alignMHQ.alignedProfileData.(strandName).(ionName).mean)+1;
            range = [xlsAddr(2, j*2 - 1) ':' xlsAddr(rowIdx,j*2)];
            
            xlswrite(spreadsheetPath,[header; dataCells], sheetNameAlign, range);
        end        
        
    end
    
    if isAlignCheck
        %append average data to aligned sheet
        header = {'Avg xData', strcat('Avg-', ionName), 'low CI', 'hi CI'};
        rowIdx = numel(alignMHQ.avgData.(ionName).mean+1);
        colIdx = alignMHQ.numStrands*2 + 1;
        range = [xlsAddr(2, colIdx) ':' xlsAddr(rowIdx,colIdx + 3)];
        dataCells = num2cell([alignMHQ.avgData.xData'                  ...
                              alignMHQ.avgData.(ionName).mean'         ...
                              alignMHQ.avgData.(ionName).lowCI'        ...
                              alignMHQ.avgData.(ionName).highCI']);
                   
        xlswrite(spreadsheetPath, [header; dataCells], sheetNameAlign, range);
    end
    
waitbar(i/numel(ionIdxSelect),w); %update waitbar
end
close(w);


%generate and save average figure
f = figure('visible','off');
p = plot(alignMHQ.avgData.xData, ...
        alignMHQ.avgData.(ionSelected).mean, ...
        alignMHQ.avgData.xData, ...
        alignMHQ.avgData.(ionSelected).lowCI,...
        alignMHQ.avgData.xData, ...
        alignMHQ.avgData.(ionSelected).highCI);

    %set trace and axis properties
    set(p(1), 'Color', [0.60 0.729 0.867], 'LineWidth', 2);
    set(p(2), 'LineStyle', '--', 'Color', [0.60 0.60 0.60]);
    set(p(3), 'LineStyle', '--', 'Color', [0.60 0.60 0.60]);
    
    ax = gca;
    ax.XLim = [alignMHQ.xMin alignMHQ.xMax]; %set axes limits to common limits  

    title({'Average Profile'
            ionTitle});
    xlabel('Distance (mm)');           
    

saveas(f, fullfile(outputFolder, strcat('Average Profile-',ionSelected)),'png');
close(f);


%export individual strands as images
lineColors = lines(alignMHQ.numStrands);
w = waitbar(0, 'Saving Images...');
for i = 1:alignMHQ.numStrands
    %get axis and strand name
    f = figure('visible','off');
    strandName = alignMHQ.strandList{i};
   
    plot(alignMHQ.alignedProfileData.(strandName).xData,                    ...
        alignMHQ.alignedProfileData.(strandName).(ionName).mean,            ...
        'Color', lineColors(i,:),                                           ...
        'LineWidth', 1);
    ax = gca;
    ax.XLim = [alignMHQ.xMin alignMHQ.xMax]; %set axes limits to common limits
    strandName(strandName == '_') = ' ';
    title({strandName
           ionTitle});
    xlabel('Distance (mm)'); 
    
    saveas(f, fullfile(outputFolder, strandName),'png');
    close(f);
    
    waitbar(i/alignMHQ.numStrands,w);
end
close(w);




end

