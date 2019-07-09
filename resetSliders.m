function MHQ = resetSliders(MHQ, handles)
%resetSliders sets the min and max values of the sliders for scale
%   %   Input
%       handles     MOHAWQ GUI handles
%   Output
%       MHQ         MOHAWQ data structure
%                   Accessed using getappdata,setappdata
%
%   The structure MHQ is created to hold all data for MOHAWQ GUI analysis
%
%   Copyright 2019, University of North Carolina at Chapel Hill
%   Written by: Mac Gilliland

%get max and min values from new ion
if isempty(MHQ.ionData)
    ionImage = [0 1];
else
listValue = get(handles.ionList, 'Value');
ionSelected = MHQ.ionLabelStr{listValue};
ionImage = MHQ.ionData.(ionSelected).img;
end

%set min and max for sliders
MHQ.maxScale = max(max(ionImage));
MHQ.minScale = min(min(ionImage));


%set values for sliders and slider boxes
set(handles.maxScaleSlider,'Max', MHQ.maxScale, 'Min', MHQ.minScale, 'Value', MHQ.maxScale);
set(handles.minScaleSlider,'Max', MHQ.maxScale, 'Min', MHQ.minScale, 'Value', MHQ.minScale);
set(handles.maxScaleSliderValue,'String',num2str(MHQ.maxScale, MHQ.abundanceScalePrecision));
set(handles.minScaleSliderValue,'String',num2str(MHQ.minScale, MHQ.abundanceScalePrecision));


end

