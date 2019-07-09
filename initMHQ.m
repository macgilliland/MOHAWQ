function MHQ = initMHQ(handles)
%initMHQ Initializes MHQ Data Structure
%   Input
%       handles     MOHAWQ GUI handles
%   Output
%       MHQ         MOHAWQ data structure
%                   Accessed using getappdata,setappdata
%
%   The structure MHQ is created to hold all data for MOHAWQ GUI analysis
%
%   Copyright 2019, University of North Carolina at Chapel Hill
%   Written by: Mac Gilliland

%Path for MOHAWQ
applpath = fileparts(which('MOHAWQ.m'));

%Load icons if necessary

% Set initial axes
set(gcf,'CurrentAxes',handles.heatmap_axes);

%Disable GUI objects while loading??

%Create MHQ Data Structure
MHQ = struct(                                           ...
    'GUIhandles',               handles,                ... %handles to GUI objects in main figure
    'Applpath',                 applpath,               ... %file path for m file
    'heatMapAxes',              handles.heatmap_axes,   ... %Axes for main heatmap
    'Userpath',                 pwd,                    ... %Initialize user path to the current working directory
    'nCol',                     0,                      ... %number of columns in loaded image
    'nRow',                     0,                      ... %number of rows in loaded image
    'spotSpacing',              100,                    ... %x spacing in image
    'lineSpacing',              100,                    ... %y spacing in image
    'maxScale',                 0,                      ... %maximum intensity
    'minScale',                 0,                      ... %minimum intensity
    'ionList',                  [],                     ... %list of ions to display ion maps
    'ROIList',                  [],                     ... %list of ROIs for profile generation
    'ROIListStrings',           {{'ROI List'}},           ... %list of strings corresponding to ROIs
    'ROICount',                 0,                      ... %count of total ROIs
    'fileName',                 '',                     ... %name of file for excel import
    'pathName',                 '',                     ... %path of excel file
    'fullFile',                 '',                     ... %combined name and path of excel file
    'rawImport',                [],                     ... %raw data from excel import
    'ionLabels',                [],                     ... %m/z labels for ion maps
    'ionLabelStr',              {{'Ion List'}},         ... %strings of ion labels
    'numIons',                  0,                      ... %number of ion labels
    'xData',                    [0 1],                  ... %x coordinates for each pixel
    'yData',                    [0 1],                  ... %y coordinates for each pixel
    'ionData',                  [],                     ... %data with ion images
    'abundanceScalePrecision',  5,                      ... %precision for abundance scale
    'localMinScale',            0,                      ... %local min for slider and color scale
    'localMaxScale',            1,                      ... %local max for slider and color scale
    'ROIPolyOrder',             1,                      ... %polynomial order for autofitting ROIs
    'ROIFitLineWidth',          4                       ... %width for autodetection of ROIs
);

MHQ.InstructionsText = ...
    {''
     '1 - Load excel file output from'
     '     MSiReader containing MSi data'
     ''
     '2 - Select ions of interest or'
     '     create new ion maps based on'
     '     current ion maps'
     ''
     '3 - Create ROIs and launch profie tool'
     '     to generate longitudinal profiles.'
     };
 
 %load lab logos - need better pictures
 %{
 try
     MHQ.CFARLogo = imread(strcat(applpath,'\Logos\Cfar_logo.png'));
     %MHQ.CPACLogo = imread(strcat(applpath,'\Logos\CPAC_logo.png'));
 catch
     return
 end
 
 imshow(MHQ.CFARLogo,'Parent',handles.CFAR_logo,'InitialMagnification','fit');
 %imshow(MHQ.CPACLogo,'Parent',handles.CPAC_logo);
 %}
 
 
end

