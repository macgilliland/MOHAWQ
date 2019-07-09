function varargout = MHQionCalculator(varargin)
% MHQIONCALCULATOR MATLAB code for MHQionCalculator.fig
%      MHQIONCALCULATOR, by itself, creates a new MHQIONCALCULATOR or raises the existing
%      singleton*.
%
%      H = MHQIONCALCULATOR returns the handle to a new MHQIONCALCULATOR or the handle to
%      the existing singleton*.
%
%      MHQIONCALCULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MHQIONCALCULATOR.M with the given input arguments.
%
%      MHQIONCALCULATOR('Property','Value',...) creates a new MHQIONCALCULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MHQionCalculator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MHQionCalculator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MHQionCalculator

% Last Modified by GUIDE v2.5 20-May-2019 10:08:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MHQionCalculator_OpeningFcn, ...
                   'gui_OutputFcn',  @MHQionCalculator_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MHQionCalculator is made visible.
function MHQionCalculator_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MHQionCalculator (see VARARGIN)

% Choose default command line output for MHQionCalculator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Validate MHQionCalculator GUI options
% First three input arguments are hObject,eventdata,handles
% Fourth argument is the handles structure of the calling GUI (main MOHAWQ GUI)
argflag = 1;
if nargin < 4,                                 argflag = 0;  % no options argument
else
   MHQhandles = varargin{1};
   if     ~ishandle (MHQhandles.output),       argflag = 0;  % not a handle
   elseif ~isappdata(MHQhandles.output,'MHQ'), argflag = 0;  % no MHQ structure
   end
end

% Display error if not called from MOHAWQ with proper input arguments
if isequal(argflag,0)
   errordlg('No input arguments.','MHQionCalculator','modal');
   delete(hObject);
   return;
end

instructionsText = {    '1. Select ions to perform operations. The syntax is:'
                        '   top ion list (operation) bottom ion list.'
                        ''
                        '2. Use calculate and preview to look at the new image.'
                        ''
                        '3. Choose a name for the new "ion" image,'
                        '   save the image, and add it to lists in this'
                        '   program and the parent program.'};
                    
set(handles.instructionsText, 'String', instructionsText);

% Get the MHQ application data structure
MHQ = getappdata(MHQhandles.output,'MHQ');

%initialize data structure for this GUI
ionCalcMHQ = struct(                                                                    ... 
    'ionList1',         {MHQ.ionLabelStr},                                              ... %first list of ions
    'ionList2',         {MHQ.ionLabelStr},                                              ... %second list, same as first, could be different in future
    'operString',       {{'Add', 'Subtract by', 'Multiply by', 'Divide by'}},           ... %operations that can be performed (+, -, x, /)
    'newIonName',       'newIonName',                                                   ... %name of new ion to be added to ion lists
    'resultMatrix',     [],                                                             ... %new image
    'absSliderMax',     1,                                                              ... %upper limit on slider
    'absSliderMin',     0,                                                              ... %lower limit on slider
    'localSliderMax',   1,                                                              ... %max slider value
    'localSliderMin',   0,                                                              ... %min slider value
    'abunPrecision',    5                                                               ... %precision to display for sliders
    );

% Save the MHQhandles in the application data structure
ionCalcMHQ.MHQhandles = MHQhandles;

%update lists
set(handles.ionList1,'String',ionCalcMHQ.ionList1);
set(handles.ionList2,'String',ionCalcMHQ.ionList2);
set(handles.operation,'String',ionCalcMHQ.operString,'Value',numel(ionCalcMHQ.operString));

%update sliders
ionCalcMHQ = resetIonCalcSliders(ionCalcMHQ , handles);

%update empty heatmap
ionCalcMHQ = updateIonCalcHeatmap(ionCalcMHQ , handles);

setappdata(handles.output,'ionCalcMHQ',ionCalcMHQ)
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = MHQionCalculator_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in calculateIon.
function calculateIon_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
%retrieve ionCalcMHQ data structure
ionCalcMHQ = getappdata(handles.output,'ionCalcMHQ');
MHQ = getappdata(ionCalcMHQ.MHQhandles.output,'MHQ');

%retrive selected values from lists
ion1_idx = get(handles.ionList1,'Value');
ion2_idx = get(handles.ionList2,'Value');
oper_idx = get(handles.operation,'Value');

selectedIon1 = ionCalcMHQ.ionList1{ion1_idx};
selectedIon2 = ionCalcMHQ.ionList2{ion2_idx};
operator = ionCalcMHQ.operString{oper_idx};

%get ion maps
matrix1 = MHQ.ionData.(selectedIon1).img;
matrix2 = MHQ.ionData.(selectedIon2).img;

%perform element-wise mathematical operation
try
    switch operator
        case 'Add'
            resultMatrix = matrix1 + matrix2;
        case 'Subtract by'
            resultMatrix = matrix1 - matrix2;
        case 'Multiply by'
            resultMatrix = matrix1 .* matrix2;
        case 'Divide by'
            resultMatrix = matrix1 ./ matrix2;
            %replace NaN and Inf(divide by zero) with 0;
            resultMatrix(isnan(resultMatrix))=0;
            resultMatrix(isinf(resultMatrix))=0;
    end
catch
    errordlg('Caculation could not be performed. Check matrix dimensions.');
    return
end

%assign matrix to structure
ionCalcMHQ.resultMatrix = resultMatrix;

%update sliders
ionCalcMHQ = resetIonCalcSliders(ionCalcMHQ,handles);

%update image with result
ionCalcMHQ = updateIonCalcHeatmap(ionCalcMHQ,handles);

%enable save
set(handles.saveNewIon, 'Enable', 'On');

%update matrix and guidata
setappdata(handles.output,'ionCalcMHQ',ionCalcMHQ);
guidata(hObject,handles);


function ionList1_Callback(hObject, ~, handles) 
%force user to update new map when value is changed
set(handles.saveNewIon, 'Enable', 'Off');


function operation_Callback(hObject, ~, handles)
%force user to update new map when value is changed
set(handles.saveNewIon, 'Enable', 'Off');


function ionList2_Callback(hObject, ~, handles)
%force user to update new map when value is changed
set(handles.saveNewIon, 'Enable', 'Off');

function newIonName_Callback(hObject, eventdata, handles)
%get structure and string from box
ionCalcMHQ = getappdata(handles.output,'ionCalcMHQ');
inputString = get(hObject,'String');

%check input string - it will become a field, so it must be a valid variable name
if ~isvarname(inputString)
    set(hObject, 'String', ionCalcMHQ.newIonName);
    errordlg({  'Ion name must be a valid variable:'
                '1 - Ion name must begin with a letter'
                '2 - Ion name cannot have more than 63 characters'
                '3 - Ion name can only include letters, digits, and underscores.'
                }, 'Invalid Variable Name'); 
    return
end
            
%if valid, update new ion name
ionCalcMHQ.newIonName = inputString;

%update matrix and guidata
setappdata(handles.output,'ionCalcMHQ',ionCalcMHQ);
guidata(hObject,handles);


function saveNewIon_Callback(hObject, eventdata, handles)
%get data structure for this GUI and the main MHQ structure
ionCalcMHQ = getappdata(handles.output,'ionCalcMHQ');
MHQ = getappdata(ionCalcMHQ.MHQhandles.output, 'MHQ');

%local variables for ion list and ion name
ionList = ionCalcMHQ.ionList1;
newIonName = ionCalcMHQ.newIonName;

%check to see if result matrix is empty
if isempty(ionCalcMHQ.resultMatrix)
    errordlg('Must calculate new value before saving.','Calculate new value.')
    return
end

%check if name exists in list
if any(strcmp(ionList,newIonName))
    errordlg('Ion name already exists. Please select a new ion name.','Ion name exists');
    return
end

%append new name to ion lists
l = max(size(ionList));
ionList{l+1} = newIonName;

%update structure and lists
ionCalcMHQ.ionList1 = ionList;
ionCalcMHQ.ionList2 = ionList;
MHQ.ionLabelStr = ionList;

set(handles.ionList1, 'String', ionCalcMHQ.ionList1);
set(handles.ionList2, 'String', ionCalcMHQ.ionList2);
set(ionCalcMHQ.MHQhandles.ionList,'String', MHQ.ionLabelStr);

%update image data in main MHQ structure
MHQ.ionData.(newIonName).img = ionCalcMHQ.resultMatrix;

%disable Save button
set(handles.saveNewIon, 'Enable', 'Off');

%let user know output completed
uiwait(msgbox({'        New ion image has been successfully created.'
            '   Create a new ion image or exit ion calculator if finished.'},'Success','modal'));


%update structures and guidata
setappdata(ionCalcMHQ.MHQhandles.output, 'MHQ', MHQ);
setappdata(handles.output,'ionCalcMHQ',ionCalcMHQ);
guidata(hObject,handles);


function ionCalcMinSlider_Callback(hObject, eventdata, handles)
%retrieve ionCalcMHQ main data structure
ionCalcMHQ = getappdata(handles.output,'ionCalcMHQ');

%get slider values
val = get(hObject,'Value');
ionCalcMHQ.localSliderMax = get(handles.ionCalcMaxSlider,'Value');

%value must be less than max and greater than absolute minimum
if val < ionCalcMHQ.localSliderMax && val >= ionCalcMHQ.absSliderMin
    ionCalcMHQ.localSliderMin = val;
    set(hObject, 'Value', ionCalcMHQ.localSliderMin)
    
    ionCalcMHQ = updateIonCalcHeatmap(ionCalcMHQ, handles);
else
    set(hObject, 'Value', ionCalcMHQ.localSliderMin); %return to previous value
end

%update box with value
set(handles.minScaleBox, 'String',num2str(ionCalcMHQ.localSliderMin, ionCalcMHQ.abunPrecision));

%update structure and guidata
setappdata(handles.output, 'ionCalcMHQ', ionCalcMHQ);
guidata(hObject, handles);


% --- Executes on slider movement.
function ionCalcMaxSlider_Callback(hObject, eventdata, handles)
%retrieve ionCalcMHQ main data structure
ionCalcMHQ = getappdata(handles.output,'ionCalcMHQ');

%get slider values
val = get(hObject,'Value');
ionCalcMHQ.localSliderMin = get(handles.ionCalcMinSlider,'Value');

%value must be greater than min slider and less than absolute maximum
if val > ionCalcMHQ.localSliderMin && val <= ionCalcMHQ.absSliderMax
    ionCalcMHQ.localSliderMax = val;
    set(hObject, 'Value', ionCalcMHQ.localSliderMax)
    
    ionCalcMHQ = updateIonCalcHeatmap(ionCalcMHQ, handles);
else
    set(hObject, 'Value', ionCalcMHQ.localSliderMax);
end

%update box with value
set(handles.maxScaleBox, 'String',num2str(ionCalcMHQ.localSliderMax, ionCalcMHQ.abunPrecision));

%update structure and guidata
setappdata(handles.output, 'ionCalcMHQ', ionCalcMHQ);
guidata(hObject, handles);

function minScaleBox_Callback(hObject, eventdata, handles)
%retrieve ionCalcMHQ main data structure
ionCalcMHQ = getappdata(handles.output,'ionCalcMHQ');

%get value from box
val = str2double(get(hObject,'String'));

%must be a number
if isnan(val)
    set(hObject,'String',num2str(ionCalcMHQ.localSliderMin, ionCalcMHQ.abunPrecision));
end

%get other slider value
ionCalcMHQ.localSliderMax = get(handles.ionCalcMaxSlider, 'Value');

%value must be less than max and greater than absolute minimum
if val < ionCalcMHQ.localSliderMax &&  val >= ionCalcMHQ.absSliderMin;
    ionCalcMHQ.localSliderMin = val;
    set(handles.ionCalcMinSlider, 'Value', ionCalcMHQ.localSliderMin);
    
    ionCalcMHQ = updateIonCalcHeatmap(ionCalcMHQ, handles);
else
    set(hObject,'String',num2str(ionCalcMHQ.localSliderMin, ionCalcMHQ.abunPrecision)); %return to previous value
end

%update structure and guidata
setappdata(handles.output,'ionCalcMHQ',ionCalcMHQ);
guidata(hObject, handles);

function maxScaleBox_Callback(hObject, eventdata, handles)
%retrieve ionCalcMHQ main data structure
ionCalcMHQ = getappdata(handles.output,'ionCalcMHQ');

%get value from box
val = str2double(get(hObject,'String'));

%value must be a number
if isnan(val)
    set(hObject,'String',num2str(ionCalcMHQ.localSliderMax, ionCalcMHQ.abunPrecision));
end

%get slider value
ionCalcMHQ.localSliderMin = get(handles.ionCalcMinSlider, 'Value');

%value must be greater than the min slider and less than the absolute max
if val > ionCalcMHQ.localSliderMin &&  val <= ionCalcMHQ.absSliderMax;
    ionCalcMHQ.localSliderMax = val;
    set(handles.ionCalcMaxSlider, 'Value', ionCalcMHQ.localSliderMax);
    
    ionCalcMHQ = updateIonCalcHeatmap(ionCalcMHQ, handles);
else
    set(hObject,'String',num2str(ionCalcMHQ.localSliderMax, ionCalcMHQ.abunPrecision)); %return to previous value
end

%update structure and guidata
setappdata(handles.output,'ionCalcMHQ',ionCalcMHQ);
guidata(hObject, handles);


%%%--------Object Creation Functions-------%%%

% --- Executes during object creation, after setting all properties.
function ionList1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ionList1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function operation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to operation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ionList2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ionList2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function newIonName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newIonName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ionCalcMinSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ionCalcMinSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function ionCalcMaxSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ionCalcMaxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function minScaleBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minScaleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function maxScaleBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxScaleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
