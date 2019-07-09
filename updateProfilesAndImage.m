function alignMHQ = updateProfilesAndImage(alignMHQ, handles)
%updateProfilesAndImage updates graphs and calculates averages of 1D 
%                       profiles in alignMHQ GUI
%   Input
%       alignMHQ    Data structure for MHQalign GUI
%       handles     MHQalign GUI handles
%   Output
%       alignMHQ    Data structure for MHQalign GUI
%                   Accessed using getappdata,setappdata
%
%   This program performs 3 actions:
%       1 - The straightened MS image for a given strand and ion is displayed
%       2 - The profiles for each strand and a selected ion are displayed
%       3a - The average of selected profiles are calculated
%       3b - The average and 95% CIs for selected profiles are displayed
%
%   Copyright 2019, University of North Carolina at Chapel Hill
%   Written by: Mac Gilliland

%get main MHQ structure
MHQ = getappdata(alignMHQ.MHQhandles.output,'MHQ');

%get strand and ion values
strandIdx = get(handles.alignROIList, 'Value');
strandName = alignMHQ.strandList{strandIdx};

ionIdx = get(handles.alignIonList, 'Value');
ionName = alignMHQ.ionList{ionIdx};

%%%---UPDATE STRAIGHT IMAGE---%%%
%%%---------------------------%%%
straightImg = alignMHQ.straightImg.(strandName).(ionName); %get image

[nRow, nCol] = size(straightImg);

%straight image axes
axes(handles.straightImgAxes);
cla;
% Distance between pixels, convert um to mm, same resolution as in main
% MOHAWQ program
dx = MHQ.spotSpacing / 1000;
dy = MHQ.lineSpacing / 1000;

xData = (0 : dx : dx * max(nCol-1, 1)) + dx/2;
yData = (0 : dy : dy * max(nRow-1, 1)) + dy/2;

%update image
imagesc(xData, yData, straightImg);
handles.straightImgAxes.DataAspectRatio = [1 1 1];



%%%---UPDATE PROFILE AXES---%%%
%%%-------------------------%%%
%create array of line colors
lineColors = lines(alignMHQ.numStrands);
isAlign = get(handles.showAligned, 'Value');
xMax = 0;
xMin = 0;

if isAlign %display aligned or raw data
    dataName = 'alignedProfileData';
else
    dataName = 'profileData';
end

%check x axis numbers to see if max and min change
for i = 1:alignMHQ.numStrands
    strandName = alignMHQ.strandList{i};
    xData = alignMHQ.profileData.(strandName).xData; %get orignial x data for each strand, doesn't change
    
    if isAlign
        xData = xData + alignMHQ.(dataName).(strandName).delay * dx; %add delay if aligned data, scale by x spacing
        %assign x data to structure, only update if changed
        alignMHQ.(dataName).(strandName).xData = xData; 
    end
    
    %reset min and max if needed
    if max(xData) > xMax, xMax = max(xData); end
    if min(xData) < xMin, xMin = min(xData); end    
end

%assign values to access in average function
alignMHQ.xMax = xMax;
alignMHQ.xMin = xMin;

%generate plots and set axes limits
for i = 1:alignMHQ.numStrands
    %get axis and strand name
    axesLabel = strcat('profileAxes_',num2str(i));
    strandName = alignMHQ.strandList{i};
    
    if i == strandIdx, lineWidth = 2; else, lineWidth = 1; end %bold selected strand
    
    plot(alignMHQ.(axesLabel),                              ... %assign axes
        alignMHQ.(dataName).(strandName).xData,             ...
        alignMHQ.(dataName).(strandName).(ionName).mean,    ...
        'Color', lineColors(i,:),                           ...
        'LineWidth', lineWidth);
    
    alignMHQ.(axesLabel).XLim = [alignMHQ.xMin alignMHQ.xMax]; %set axes limits to common limits
end


%%%---UPDATE AND CALCULATE AVERAGE---%%%
%%%----------------------------------%%%

%only calculate if align box is checked
if isAlign
    alignMHQ = averageStrands(alignMHQ,handles); %perform averaging
    alignMHQ.isSmoothed = get(handles.smoothAverageProfile, 'Value');
    %perform smoothing if desired
    if alignMHQ.isSmoothed
        alignMHQ.avgData.(ionName).mean = smoothdata(alignMHQ.avgData.(ionName).mean, 'movmean', alignMHQ.smoothingFactor, 'omitnan');
        alignMHQ.avgData.(ionName).lowCI = smoothdata(alignMHQ.avgData.(ionName).lowCI, 'movmean', alignMHQ.smoothingFactor, 'omitnan');
        alignMHQ.avgData.(ionName).highCI = smoothdata(alignMHQ.avgData.(ionName).highCI, 'movmean', alignMHQ.smoothingFactor, 'omitnan');
    end
    
    %add traces to mean and 95% CIs to plot
    p = plot(handles.averageProfileAxes, ...
            alignMHQ.avgData.xData, ...
            alignMHQ.avgData.(ionName).mean, ...
            alignMHQ.avgData.xData,...
            alignMHQ.avgData.(ionName).lowCI,...
            alignMHQ.avgData.xData,...
            alignMHQ.avgData.(ionName).highCI);
     
    %set trace and axis properties
    set(p(1), 'Color', [0.60 0.729 0.867], 'LineWidth', 2);
    set(p(2), 'LineStyle', '--', 'Color', [0.60 0.60 0.60]);
    set(p(3), 'LineStyle', '--', 'Color', [0.60 0.60 0.60]);
    alignMHQ.averageProfileAxes.XLim = [alignMHQ.xMin alignMHQ.xMax]; %set axes limits to common limits
end


end

