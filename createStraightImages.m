function alignMHQ = createStraightImages(alignMHQ, handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%generate masks
alignMHQ = generateMaskImages(alignMHQ, handles);

%fit lines, interpolate, calculate normal vectors
alignMHQ = fitLinesToImages(alignMHQ, handles);

%scale images and map values
for i = 1:alignMHQ.numStrands %loop for each strand
    strandName = alignMHQ.strandList{i};
    xIdx = round(alignMHQ.normalX.(strandName)*alignMHQ.imgScale);
    yIdx = round(alignMHQ.normalY.(strandName)*alignMHQ.imgScale);
    
    normXSize = size(xIdx);
    
    for j = 1:alignMHQ.numIons %loop for each ion
        ionName = alignMHQ.ionList{j};
        scaledImg = imresize(alignMHQ.maskImages.(strandName).(ionName),alignMHQ.imgScale); %resize image before mapping
        [scaledImgY, scaledImgX] = size(scaledImg);
        
        for k = 1:normXSize(1) %two loops, one for each image dimension, get point-by-point
            for l = 1:normXSize(2)
                if xIdx(k,l) < 1 || isnan(xIdx(k,l))|| isnan(yIdx(k,l))|| yIdx(k,l) < 1 || xIdx(k,l) > scaledImgX || yIdx(k,l) > scaledImgY %assign value of NaN if value or Idx is out of range
                    alignMHQ.straightImg.(strandName).(ionName)(l,k) = NaN;
                else
                    alignMHQ.straightImg.(strandName).(ionName)(l,k) = scaledImg(yIdx(k,l),xIdx(k,l)); %assign value from image
                end   
            end
        end   
    end
end

end

