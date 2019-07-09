function ionCalcMHQ = resetIonCalcSliders(ionCalcMHQ, handles)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

%get max and min values from new ion
if isempty(ionCalcMHQ.resultMatrix)
    ionImage = [0 1];
else
    ionImage = ionCalcMHQ.resultMatrix;
end

%set min and max for sliders
ionCalcMHQ.absSliderMax = max(max(ionImage));
ionCalcMHQ.absSliderMin = min(min(ionImage));


%set values for sliders and slider boxes
set(handles.ionCalcMaxSlider,'Max', ionCalcMHQ.absSliderMax, 'Min', ionCalcMHQ.absSliderMin, 'Value', ionCalcMHQ.absSliderMax);
set(handles.ionCalcMinSlider,'Max', ionCalcMHQ.absSliderMax, 'Min', ionCalcMHQ.absSliderMin, 'Value', ionCalcMHQ.absSliderMin);
set(handles.maxScaleBox,'String',num2str(ionCalcMHQ.absSliderMax, ionCalcMHQ.abunPrecision));
set(handles.minScaleBox,'String',num2str(ionCalcMHQ.absSliderMin, ionCalcMHQ.abunPrecision));

end

