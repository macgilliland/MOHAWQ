function alignMHQ = generateMaskImages(alignMHQ, handles)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%get main MHQ structure
MHQ = getappdata(alignMHQ.MHQhandles.output,'MHQ');

%loop for strands
for i = 1:alignMHQ.numStrands
    strandName = alignMHQ.strandList{i}; %name for structure assignment
    ROIimg = MHQ.ROIList.(MHQ.ROIListStrings{i}).img; %get mask image (same for each strand)
    
    for j = 1:alignMHQ.numIons %loop for each ion
        ionName = alignMHQ.ionList{j}; %get ion name for labeling
        ionImg = MHQ.ionData.(ionName).img;
        
        %generate masks by multiplying binary image by orignal image
        alignMHQ.maskImages.(strandName).(ionName) = ROIimg .* ionImg;
    end
end


end

