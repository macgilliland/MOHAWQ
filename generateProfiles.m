function alignMHQ = generateProfiles(alignMHQ,handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%get main MHQ structure
MHQ = getappdata(alignMHQ.MHQhandles.output,'MHQ');

dx = MHQ.spotSpacing / 1000;% Distance between pixels, convert um to mm, same resolution as in main MOHAWQ program

%loop through strands and ions to generate profiles
for i = 1:alignMHQ.numStrands
    strandName = alignMHQ.strandList{i};
    alignMHQ.alignedProfileData.(strandName).delay = 0;
    
    for j = 1:alignMHQ.numIons
        ionName = alignMHQ.ionList{j};
        
        %assign values to structure for raw profiles
        alignMHQ.profileData.(strandName).(ionName).mean = mean(alignMHQ.straightImg.(strandName).(ionName),'omitnan'); %mean of each column in image, omitnan averages all non-nan elements
        alignMHQ.profileData.(strandName).(ionName).max = max(alignMHQ.straightImg.(strandName).(ionName)); %max of each column in image
        alignMHQ.profileData.(strandName).(ionName).std = std(alignMHQ.straightImg.(strandName).(ionName)); %standard deviation of each column
        [alignMHQ.profileData.(strandName).(ionName).nRow, alignMHQ.profileData.(strandName).(ionName).nCol] = size(~isnan(alignMHQ.straightImg.(strandName).(ionName)));
        
        %assign initial values for aligned profiles the same as the raw profiles
        alignMHQ.alignedProfileData.(strandName).(ionName).mean = mean(alignMHQ.straightImg.(strandName).(ionName),'includenan'); %mean of each column in image
        alignMHQ.alignedProfileData.(strandName).(ionName).max = max(alignMHQ.straightImg.(strandName).(ionName)); %max of each column in image
        
        alignMHQ.alignedProfileData.(strandName).(ionName).std = std(alignMHQ.straightImg.(strandName).(ionName)); %standard deviation of each column
        [alignMHQ.alignedProfileData.(strandName).(ionName).nRow, alignMHQ.alignedProfileData.(strandName).(ionName).nCol] = size(~isnan(alignMHQ.straightImg.(strandName).(ionName))); 
    end
    
    xData = (0: dx : dx *max(alignMHQ.profileData.(strandName).(ionName).nCol - 1, 1)); %generate x data for each strand
    %assign x data to structure
    alignMHQ.profileData.(strandName).xData = xData;  
    alignMHQ.alignedProfileData.(strandName).xData = xData;
end

end

