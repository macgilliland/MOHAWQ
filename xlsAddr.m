function address = xlsAddr(row,col)
%xlsAddr Takes row and column scalars and converts them to the cell address in Excel
%   Input
%       row         scalar value corresponding to row number
%       col         scalar value corresponding to column number
%   Output
%       address     string corresponding to a cell address in Excel
%  
%   The output will be a string with a letter or multiple letters corresponding 
%   to the column number and a number corresponding to the row number.
%   These values are used to identify specific cells in Microsoft Excel.

if isnumeric(col)
    if ~isscalar(col), error('Input column not scalar'), end
    letter = num2str('A' + [fix(col/26) rem(col,26)] - 1, '%c%c'); %construct letter portion
    letter(letter == '@') = []; %remove @ symbols
else
    error('Column must be numeric');
end

if isnumeric(row)
    if ~isscalar(row), error('Input row not scalar'), end
    number = num2str(row,'%d'); %construct row portion
else
    error('Row must be numeric')
end

address = [letter number]; %concatenate for output

end

