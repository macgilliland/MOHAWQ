function ionCalcMHQ = updateIonCalcHeatmap(ionCalcMHQ, handles)
%updateMainHeatmap generates a heatmap based on the ion selected
%   Input
%       ionCalcMHQ          Ion calculator data structure
%       handles             Ion calculator GUI handles
%   Output
%       ionCalcMHQ          Ion calculator data structure
%       Accessed using getappdata,setappdata
%
%   Data from ionCalcMHQ structure is plotted as a heatmap to let the user
%   preview the new ion map before saving
%
%  Copyright 2019, University of North Carolina at Chapel Hill
%  Written by: Mac Gilliland

MHQ = getappdata(ionCalcMHQ.MHQhandles.output, 'MHQ');

ionImage = ionCalcMHQ.resultMatrix;
ionCalcMHQ.localSliderMax = get(handles.ionCalcMaxSlider,'Value');
ionCalcMHQ.localSliderMin = get(handles.ionCalcMinSlider,'Value');

% Distance between pixels, convert um to mm, get from main structure
dx = MHQ.spotSpacing / 1000;
dy = MHQ.lineSpacing / 1000;

% Spatial location of each pixel (same as from main program)
xData = (0 : dx : dx * max(MHQ.nCol-1,1))   + dx/2; 
yData = (0 : dy : dy * max(MHQ.nRow-1,1)).' + dy/2;

axes(handles.previewHeatmap);

imagesc(xData, yData, ionImage);
colorbar('eastoutside');

if ionCalcMHQ.localSliderMin ~= ionCalcMHQ.localSliderMax
    handles.previewHeatmap.CLim = [ionCalcMHQ.localSliderMin ionCalcMHQ.localSliderMax];
end
handles.previewHeatmap.DataAspectRatio = [1 1 1];

end

