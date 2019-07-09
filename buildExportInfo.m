function infoCell = buildExportInfo(alignMHQ)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if alignMHQ.isSmoothed == 1
    isSmoothStr = 'Yes';
else
    isSmoothStr = 'No';
end

%get main MHQ structure
MHQ = getappdata(alignMHQ.MHQhandles.output,'MHQ');
% Distance between pixels, convert um to mm, same resolution as in main
% MOHAWQ program
dx = MHQ.spotSpacing / 1000;
dy = MHQ.lineSpacing / 1000;

%build array with strand names and delays
numSelect = numel(alignMHQ.avgSelectedStrands);
outputArray = {'Strands Averaged'  'Delays'};
for i = 1:numSelect
    strandName = alignMHQ.strandList{alignMHQ.avgSelectedStrands(i)};
    delay = alignMHQ.alignedProfileData.(strandName).delay * dx;
    outputArray{i+1, 1} = strandName;
    outputArray{i+1, 2} = delay;
end

% Build cell array of info strings
tempCell = {'MOHAWQ - align export parameters'      datestr(now);                   ...
            '   '                                   '   ';                          ...
            'Image Spot Spacing'                    dx;                             ...
            'Image Line Spacing'                    dy;                             ...
            'Image Scaling Factor'                  alignMHQ.imgScale;              ...
            'Line Width'                            alignMHQ.lineWidth;             ...
            'Total Strands'                         alignMHQ.numStrands;            ...
            'Smoothing Applied?'                    isSmoothStr;                    ...
            'SmoothingFactor'                       alignMHQ.smoothingFactor;       ...
            '   '                                   '   '                           ...
            };
         
infoCell = vertcat(tempCell, outputArray); %add which strands were averaged and their delays

end

