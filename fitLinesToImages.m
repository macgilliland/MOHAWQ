function alignMHQ = fitLinesToImages(alignMHQ, handles)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%get main MHQ structure
MHQ = getappdata(alignMHQ.MHQhandles.output,'MHQ');

%Select ion map to use for masks
[s,alignMHQ.userCancel] = listdlg('PromptString',     {'Please select an ion'
                                     'to use for fitting:'},                    ...
                'SelectionMode',    'single',                                   ...
                'ListString',       alignMHQ.ionList                            ...
                );

%quit if user cancels selection
if ~alignMHQ.userCancel
    return; 
end
            
maskingIon = alignMHQ.ionList{s};
yData = 1:1:MHQ.nRow;           

%generate line down middle of strand
%loop through strands, only images using selected ion
for i = 1:alignMHQ.numStrands
    strandName = alignMHQ.strandList{i}; %name for structure assignment
    activeImage = alignMHQ.maskImages.(strandName).(maskingIon);
    
    for j = 1:MHQ.nCol %loop along x axis
        weights = activeImage(:,j)'; %intensity data from each colum used as weights
        alignMHQ.fitLineY.(strandName)(j) = sum(yData.*weights)/sum(weights); %weighted average of each column     
    end
    
    alignMHQ.fitLineX.(strandName) = 1:1:MHQ.nCol; %generate x values - to be scaled later
    alignMHQ.fitLineY.(strandName) = smoothdata(alignMHQ.fitLineY.(strandName),'includenan'); %smooth for better fit down center of strand
end

%interpolate lines

[d, dx, dy, s] = deal(zeros(1, MHQ.nCol - 1)); %preallocate variables

for i = 1:alignMHQ.numStrands
    strandName = alignMHQ.strandList{i}; %name for structure assignment
    xData = alignMHQ.fitLineX.(strandName);
    yData = alignMHQ.fitLineY.(strandName);
    
    %calculate distance and slope between points
    for j = 1:(MHQ.nCol-1)
        dx(j) = xData(j+1) - xData(j);  %distance between x points
        dy(j) = yData(j+1) - yData(j);  %distance between y points
        d(j) = sqrt(dx(j)^2 + dy(j)^2); %scalar distance between points (hypotenuse)
        s(j) = dy(j)/dx(j);             %slope between points
    end
    
   [h, k, idx] = deal(1); %initialize hypotenuse, loop counter, and index counter
     
   while k < MHQ.nCol
        if k < MHQ.nCol - 1
            pointDiff = d(k+1) - h; %calculate distance to next point; don't calculate on last iteration
        end
    
        alignMHQ.interpX.(strandName)(idx) = xData(k) + h/sqrt(1+(s(k)^2)); %calculate x position using slope
        alignMHQ.interpY.(strandName)(idx) = yData(k) + s(k)*h/sqrt(1+(s(k)^2)); %calculate y position using slope
                
        if pointDiff <= 1
            h = 1 - pointDiff; %reassign hypotenuse
            k = k + 1;
        elseif isnan(pointDiff)
            k = k + 1;
        else
            h = h + 1; %don't increment k because interpolated point is between same two points
        end
        
        idx = idx + 1;
   end
end

%generate normal vectors

widthArray = (-alignMHQ.lineWidth/2):0.5:(alignMHQ.lineWidth/2);
widthArraySize = max(size(widthArray));

for i = 1:alignMHQ.numStrands
    strandName = alignMHQ.strandList{i}; %name for structure assignment
    xData = alignMHQ.interpX.(strandName); 
    yData = alignMHQ.interpY.(strandName);
    
    xSize = max(size(xData));
        
    for j = 1: (xSize - 1)
        dx = xData(j+1) - xData(j);
        dy = yData(j+1) - yData(j);
        iX = widthArray*(-dy) + xData(j); %normal vector x data
        iY = widthArray*dx + yData(j); %normal vector y data
        
        for k = 1:widthArraySize %assign normal vector data point by point
            alignMHQ.normalX.(strandName)(j,k) = iX(k);
            alignMHQ.normalY.(strandName)(j,k) = iY(k);
        end
    end
end
        
end