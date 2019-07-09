function alignMHQ = averageStrands(alignMHQ, handles)
%averageStrands averages a set of 1D arrays
%   Input
%       alignMHQ    Data structure for MHQalign GUI
%       handles     MHQalign GUI handles
%   Output
%       alignMHQ    Data structure for MHQalign GUI
%                   Accessed using getappdata,setappdata
%
%   A set of 1D arrays corresponding to intensity values along the length
%   of hair strands (generated from MSI data) are appended to be the same
%   length and averaged. Based on the standard deviations associated with
%   each of 1D arrays, 95% confidence intervals are generated. The average
%   data and CIs are appended to the main alignMHQ data structure.
%
%   Copyright 2019, University of North Carolina at Chapel Hill
%   Written by: Mac Gilliland

%get main MOHAWQ data structure and spot spacing
MHQ = getappdata(alignMHQ.MHQhandles.output,'MHQ');
dx = MHQ.spotSpacing / 1000;

alignMHQ.avgSelectedStrands = get(handles.averageStrandList,'Value');
numSelect = numel(alignMHQ.avgSelectedStrands);
maxLdouble = (alignMHQ.xMax - alignMHQ.xMin)/dx; %calculate x range
maxLint = round(maxLdouble) + 1;
alignMHQ.avgData.xData = (0 : dx : (maxLdouble)*dx); %generate x data for average profiles

%generate t table
tTable = tinv(0.975, 1:100);

%loop through ions to get average
for i = 1:alignMHQ.numIons
    profileMatrix = zeros(numSelect, maxLint);
    stdevMatrix = zeros(numSelect, maxLint);
    nSum = 0;
    ionName = alignMHQ.ionList{i};
    
    for j = 1:numSelect %loop through strands
    strandName = alignMHQ.strandList{alignMHQ.avgSelectedStrands(j)};
    
    %generate NaN vectors to add to profiles to make lengths equal
    addNanStart = min(alignMHQ.alignedProfileData.(strandName).xData) - alignMHQ.xMin;
    addNanStart = round(addNanStart/dx);
    startNanVector = NaN(1,addNanStart);
       
    addNanEnd = alignMHQ.xMax - max(alignMHQ.alignedProfileData.(strandName).xData);
    addNanEnd = round(addNanEnd/dx);
    endNanVector = NaN(1,addNanEnd);
   
    activeProfile = alignMHQ.alignedProfileData.(strandName).(ionName).mean;
    activeStdev = alignMHQ.alignedProfileData.(strandName).(ionName).std;
    activeN = alignMHQ.alignedProfileData.(strandName).(ionName).nRow;
    
    
    newProfile = [startNanVector activeProfile endNanVector]; %append NaN vectors to either end
    profileMatrix(j,:) = newProfile; %replace zero values with new vector
    
    newStdev = [startNanVector activeStdev endNanVector]; %stdev same length as profile matrix
    stdevMatrix(j,:) = newStdev; %replace zero values with new vector
    nSum = nSum + activeN; %total number for t calculation
    end
             
    %average matrix that has been generated
    if numSelect == 1 %assign value directly if 1D
        alignMHQ.avgData.(ionName).mean = profileMatrix;
        
        CI = stdevMatrix/sqrt(nSum) .* tTable(nSum); %convert stdeviation to standard error; then multiply by t to get 95% CI
        alignMHQ.avgData.(ionName).lowCI = alignMHQ.avgData.(ionName).mean - CI;
        alignMHQ.avgData.(ionName).highCI = alignMHQ.avgData.(ionName).mean + CI;
    else
        alignMHQ.avgData.(ionName).mean = mean(profileMatrix,'omitnan');
        
        CI = sqrt(mean(stdevMatrix.^2,'omitnan'))/sqrt(nSum) .* tTable(nSum); %convert stdeviations to standard errors; then multiply by t to get 95% CI
        alignMHQ.avgData.(ionName).lowCI = alignMHQ.avgData.(ionName).mean - CI;
        alignMHQ.avgData.(ionName).highCI = alignMHQ.avgData.(ionName).mean + CI;
    end
end


end

