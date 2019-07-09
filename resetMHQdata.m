function MHQ = resetMHQdata(MHQ, handles)
%resetMHQdata resets and empties data in the MHQ data structure
%   Input
%       MHQ         MOHAWQ data structure
%       handles     MOHAWQ GUI handles
%   Output
%       MHQ         MOHAWQ data structure
%                   Accessed using getappdata,setappdata
%
%  Copyright 2019, University of North Carolina at Chapel Hill
%  Written by: Mac Gilliland

MHQ.ionData =[];
MHQ.nCol = 0;
MHQ.nRow = 0;
MHQ.spotSpacing = 100;
MHQ.lineSpacing = 100;
MHQ.maxScale = 0;
MHQ.minScale = 0;
MHQ.ionList = [];
MHQ.ROIList = [];
MHQ.ROIListStrings = {'ROI List'};
MHQ.ROICount = 0;
MHQ.filename = '';
MHQ.pathname = '';
MHQ.fullFile = '';
MHQ.rawImport = [];
MHQ.ionLabels = [];
MHQ.numIons = 0;
MHQ.ionLabelStr = {'Ion List'};
MHQ.xData = [];
MHQ.yData = [];
MHQ.abundanceScalePrecision = 5;
MHQ.ROIPolyOrder = 1;
MHQ.ROIFitLineWidth = 4;

set(handles.polyOrder,'Value', 1);
set(handles.roiWidth, 'String', num2str(MHQ.ROIFitLineWidth));
set(handles.spotSpacing,'String',num2str(MHQ.spotSpacing));
set(handles.lineSpacing,'String',num2str(MHQ.lineSpacing));
set(handles.ionList,'String',MHQ.ionLabelStr,'Value',1);
set(handles.ROIList,'String',MHQ.ROIListStrings,'Value',1);
set(handles.dataFileText,'String',MHQ.fileName);

end

