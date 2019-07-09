function MHQ = updateMainHeatmap(MHQ, handles)
%updateMainHeatmap generates a heatmap based on the ion selected
%   Input
%       MHQ         MOHAWQ data structure
%       handles     MOHAWQ GUI handles
%   Output
%       MHQ         MOHAWQ data structure
%                   Accessed using getappdata,setappdata

%   Data from MHQ structure is plotted as a heatmap in the main set of axes
%   for each ion selected. 
%
%  Copyright 2019, University of North Carolina at Chapel Hill
%  Written by: Mac Gilliland

listValue = get(handles.ionList, 'Value');
ionSelected = MHQ.ionLabelStr{listValue};


if isempty(MHQ.ionData)
    ionImage = []; %empty image if no ionData exists
else
    ionImage = MHQ.ionData.(ionSelected).img;
    MHQ.localMaxScale = get(handles.maxScaleSlider,'Value');
    MHQ.localMinScale = get(handles.minScaleSlider,'Value');
end

%set and clear heatmap
set(gcf,'CurrentAxes',handles.heatmap_axes);
cla;
% Distance between pixels, convert um to mm
dx = MHQ.spotSpacing / 1000;
dy = MHQ.lineSpacing / 1000;

% Spatial location of each pixel
MHQ.xData = (0 : dx : dx * max(MHQ.nCol-1,1))   + dx/2; 
MHQ.yData = (0 : dy : dy * max(MHQ.nRow-1,1)).' + dy/2; 

%draw image
imagesc(MHQ.xData, MHQ.yData, ionImage);
colorbar('eastoutside');

%image scale parameters
handles.heatmap_axes.CLim = [MHQ.localMinScale MHQ.localMaxScale];
%handles.heatmap_axes.DataAspectRatio = [1 1 1];

%draw ROI
hold on
ROI_idx = get(handles.ROIList,'Value');
ROILabel = MHQ.ROIListStrings{ROI_idx};

displayROI = get(handles.displayROI, 'Value');

if ~strcmp('ROI List',ROILabel) && displayROI
    %rescale ROI if image is rescaled
    xScaleFactor =  MHQ.spotSpacing / MHQ.ROIList.(ROILabel).ROIxScale;
    xROI = MHQ.ROIList.(ROILabel).ROIX * xScaleFactor;

    yScaleFactor =  MHQ.lineSpacing / MHQ.ROIList.(ROILabel).ROIyScale;
    yROI = MHQ.ROIList.(ROILabel).ROIY * yScaleFactor;
    
    %plot ROI
    plot(   xROI, yROI,                                 ...
            'Color',        [0.6350 0.0780 0.1840],     ...
            'LineWidth',    1.5,                        ...
            'Marker',       's',                        ...
            'MarkerSize',   5                           ...
            );
    
end
hold off
handles.heatmap_axes.DataAspectRatio = [1 1 1];


end

