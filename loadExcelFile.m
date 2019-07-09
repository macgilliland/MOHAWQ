function MHQ = loadExcelFile(MHQ, handles)
%loadExcelFile adds MSI data from excel file (output from MSiReader)
%   Input
%       MHQ         MOHAWQ data structure
%       handles     MOHAWQ GUI handles
%   Output
%       MHQ         MOHAWQ data structure
%                   Accessed using getappdata,setappdata
%
%   Data from excel file is loaded and organized to form 2D image for later
%   manipulation. Handles 2 versions of excel files: one where data is in
%   a sheet labeled 'Abundance Matrix', and one where data is in a sheet labeled
%   'Intensity Matrix.'
%
%  Copyright 2019, University of North Carolina at Chapel Hill
%  Written by: Mac Gilliland

%Prompt user for data input
[MHQ.fileName, MHQ.pathName] = uigetfile({'*.xlsx';'*.xls'},'Select MSI data','MultiSelect','Off');
MHQ.fullFile = fullfile(MHQ.pathName, MHQ.fileName);

% Return if user clicked cancel button or the MHQ filename is empty
if isempty(MHQ.fileName)   || isempty(MHQ.pathName) || ...
   isequal(MHQ.fileName,0) || isequal(MHQ.pathName,0)
   set(handles.dataFileText,'String','');
   return;
end

%Two types of sheets depending on MSiReader version
MSIdataSheet = 'Abundance Matrix';
MSIdataSheet2 = 'Intensity Matrix';


try %newer version first
    raw_import_data = xlsread(MHQ.fullFile, MSIdataSheet); %Import ion data from second sheet
catch
    try %older version
        raw_import_data = xlsread(MHQ.fullFile, MSIdataSheet2);
    catch
        errordlg('MSI data not found in Excel Workbook');
        return %exit if sheet not found
    end
end

MHQ.rawImport = raw_import_data(4:end, 5:end); %read image data
MHQ.ionLabels = raw_import_data(1,5:end); %read ion label names from first row


try
    [~,~,info] = xlsread(MHQ.fullFile,'Info'); %import dimensions from excel file
    searchStrings = {'Spots per line', 'Number of lines', 'Spot spacing (um)', 'Line spacing (um)'};
    dimensions = zeros(1,numel(searchStrings));
    
    %find dimension parameters
    for i = 1:numel(searchStrings)
       idxs = strcmpi(searchStrings{i},info);
       rowNum = find(idxs == 1);
       dimensions(i) = info{rowNum,2}; %#ok<FNDSB> %second column in spreadsheet       
    end

catch %ask for user input if dimensions not found
    answer = questdlg('Dimensions not found. Would you like to enter dimensions manually?', ...
        'Dimensions not found', ...
        'Yes','No','No');
    switch answer
        case 'Yes' %user input for dimensions of image
            ROI = inputdlg({'Spots per line','Scan lines','Voxel size X (um)', 'Voxel size Y (um)'},'Define ROI',1,{'','','100','100'});
            dimensions = str2double(ROI);
            if (sum(isnan(dimensions)) > 0) %error if box input is blank or nonnumeric
               uiwait(msgbox('One or more dimensions not found'));
               return
            end
        case 'No'
            return %exit if user does not enter dimensions
    end
end
    
MHQ.nCol = dimensions(1);
MHQ.nRow = dimensions(2);
MHQ.spotSpacing = dimensions(3);
MHQ.lineSpacing = dimensions(4);

%update boxes in main GUI
set(handles.spotSpacing,'String',num2str(MHQ.spotSpacing));
set(handles.lineSpacing,'String',num2str(MHQ.lineSpacing));

%reshape array and create ion images
MHQ.numIons = length(MHQ.ionLabels);
label='mz';
importPrecision = 7; %number of decimal places to import

%generate ion images by reshaping raw MSI data
for i=1:MHQ.numIons
	ionstring = num2str(MHQ.ionLabels(i),importPrecision);
	ion = strcat(label,ionstring);
    ion = strrep(ion,'.','_'); %Replace '.' with '_' for field names in structure, which are organized by ion name
    MHQ.ionLabelStr{i} = ion;
    
    %Save images of raw MSI data
    MHQ.ionData.(ion).raw = MHQ.rawImport(:,i);
    
    MHQ.ionData.(ion).img = reshape(MHQ.ionData.(ion).raw,[MHQ.nCol , MHQ.nRow]);
    MHQ.ionData.(ion).img = transpose(MHQ.ionData.(ion).img);  
end

%update ion list in main GUI
set(handles.ionList,'String',MHQ.ionLabelStr,'Value', 1);

end

