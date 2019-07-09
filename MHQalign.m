function varargout = MHQalign(varargin)
% MHQALIGN MATLAB code for MHQalign.fig
%      MHQALIGN, by itself, creates a new MHQALIGN or raises the existing
%      singleton*.
%
%      H = MHQALIGN returns the handle to a new MHQALIGN or the handle to
%      the existing singleton*.
%
%      MHQALIGN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MHQALIGN.M with the given input arguments.
%
%      MHQALIGN('Property','Value',...) creates a new MHQALIGN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MHQalign_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MHQalign_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MHQalign

% Last Modified by GUIDE v2.5 30-May-2019 17:05:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MHQalign_OpeningFcn, ...
                   'gui_OutputFcn',  @MHQalign_OutputFcn, ...
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


% --- Executes just before MHQalign is made visible.
function MHQalign_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MHQalign (see VARARGIN)

% Choose default command line output for MHQalign
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Validate MHQalign GUI options
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
   errordlg('No input arguments.','MHQalign','modal');
   delete(hObject);
   return;
end

instructionsText = {    '1. Selection tools change'
                        '   active strand and ion.'
                        ''
                        '2. Alignment tools shift'
                        '   active strand or autoalign'
                        ''
                        '3. Select multiple strands in the'
                        '   Averaging tools panel to'
                        '   average them.'
                        ''
                        '4. Export the raw and/or'
                        '   aligned data to excel files.'
                        };
                    
set(handles.alignInstructions, 'String', instructionsText);

% Get the MHQ application data structure
MHQ = getappdata(MHQhandles.output,'MHQ');

IonNum = max(size(MHQ.ionLabelStr));
ROInum = max(size(MHQ.ROIListStrings));
strandList = cell(ROInum, 1);

for i = 1:ROInum
    strandList{i} = strcat('Strand_', num2str(i));
end

alignMHQ = struct(                                  ...
    'strandList',           {strandList},           ...
    'moveAmount',           0,                      ...
    'ionList',              {MHQ.ionLabelStr},      ...
    'avgStrandList',        {strandList},           ...
    'numStrands',           ROInum,                 ...
    'numIons',              IonNum,                 ...
    'smoothingFactor',      3,                      ...
    'isSmoothed',           0,                      ...
    'profileData',          [],                     ...
    'alignedProfileData',   [],                     ...
    'straightImg',          [],                     ...
    'avgData',              [],                     ...
    'avgSelectedStrands',   [],                     ...
    'lineWidth',            4,                      ...
    'imgScale',             1,                      ...
    'maskImages',           [],                     ...
    'fitLineX',             [],                     ...
    'fitLineY',             [],                     ...
    'interpX',              [],                     ...
    'interpY',              [],                     ...
    'normalX',              [],                     ...
    'normalY',              [],                     ...
    'xMax',                 0,                      ...
    'xMin',                 0,                      ...
    'moveIncrement',        1,                      ...
    'userCancel',           0                       ...
    );

% Save the MHQhandles in the application data structure
alignMHQ.MHQhandles = MHQhandles;

%set values of GUI
ionIdx = get(MHQhandles.ionList,'Value');
set(handles.alignROIList, 'String', alignMHQ.strandList);
set(handles.averageStrandList, 'String', alignMHQ.avgStrandList,'Max',alignMHQ.numStrands);
set(handles.alignIonList, 'String', alignMHQ.ionList, 'Value', ionIdx);

%generate straightened images and profiles
alignMHQ = createStraightImages(alignMHQ, handles);
if ~alignMHQ.userCancel
    delete(hObject); %exit if canceled by user
end
alignMHQ = generateProfiles(alignMHQ, handles);

%create axes for profile graphs
alignMHQ.panelBorder = 0.06;
alignMHQ.axisH = (1 - (alignMHQ.numStrands+1)*alignMHQ.panelBorder)/alignMHQ.numStrands;
alignMHQ.axisW = 1 - 2*alignMHQ.panelBorder;

pos = [alignMHQ.panelBorder alignMHQ.panelBorder alignMHQ.axisW alignMHQ.axisH];

%create axes
for i = 1:alignMHQ.numStrands
    axesLabel = strcat('profileAxes_',num2str(alignMHQ.numStrands - i + 1)); %create axes title, index in reverse order
    alignMHQ.(axesLabel) = axes(handles.profilesPanel,'Position',pos, 'Visible', 'on'); %create axes

    pos(2) = pos(2) + alignMHQ.panelBorder + alignMHQ.axisH; 
end

%update graphs
alignMHQ = updateProfilesAndImage(alignMHQ, handles);

%save data
setappdata(handles.output,'alignMHQ',alignMHQ)
guidata(hObject, handles);

% UIWAIT makes MHQalign wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MHQalign_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function alignROIList_Callback(hObject, eventdata, handles)
%get main data structure
alignMHQ = getappdata(handles.output,'alignMHQ');

%update graphs when value changes
alignMHQ = updateProfilesAndImage(alignMHQ, handles);

%save data
setappdata(handles.output,'alignMHQ',alignMHQ)
guidata(hObject, handles);




% --- Executes on selection change in alignIonList.
function alignIonList_Callback(hObject, eventdata, handles)
%get main data structure
alignMHQ = getappdata(handles.output,'alignMHQ');

%update graphs when value changes
alignMHQ = updateProfilesAndImage(alignMHQ, handles);

%save data
setappdata(handles.output,'alignMHQ',alignMHQ)
guidata(hObject, handles);



function alignMoveAmount_Callback(hObject, eventdata, handles)
%get main data structure
alignMHQ = getappdata(handles.output,'alignMHQ');

%get value and round to whole number
val = round(str2double(get(hObject,'String')));

if isnan(val) || val <= 0
   set(hObject, 'String', num2str(alignMHQ.moveIncrement));
else
   alignMHQ.moveIncrement = val;
   set(hObject,'String', num2str(alignMHQ.moveIncrement));
end

%save data
setappdata(handles.output,'alignMHQ',alignMHQ)
guidata(hObject, handles)


function alignMoveRight_Callback(hObject, eventdata, handles)
%get main data structure
alignMHQ = getappdata(handles.output,'alignMHQ');

strandIdx = get(handles.alignROIList, 'Value');
strandName = alignMHQ.strandList{strandIdx};

%update delay
alignMHQ.alignedProfileData.(strandName).delay = alignMHQ.alignedProfileData.(strandName).delay + alignMHQ.moveIncrement;

%update graphs when value changes
alignMHQ = updateProfilesAndImage(alignMHQ, handles);

%save data
setappdata(handles.output,'alignMHQ',alignMHQ)
guidata(hObject, handles);


function alignMoveLeft_Callback(hObject, eventdata, handles)
%get main data structure
alignMHQ = getappdata(handles.output,'alignMHQ');

strandIdx = get(handles.alignROIList, 'Value');
strandName = alignMHQ.strandList{strandIdx};

%update delay
alignMHQ.alignedProfileData.(strandName).delay = alignMHQ.alignedProfileData.(strandName).delay - alignMHQ.moveIncrement;

%update graphs when value changes
alignMHQ = updateProfilesAndImage(alignMHQ, handles);

%save data
setappdata(handles.output,'alignMHQ',alignMHQ)
guidata(hObject, handles);

% --- Executes on button press in showAligned.
function showAligned_Callback(hObject, eventdata, handles)
%get main data structure
alignMHQ = getappdata(handles.output,'alignMHQ');

%enable or disable align tools
val = get(hObject, 'Value');
if val  == 1
    set([handles.alignMoveLeft,         ...
        handles.alignMoveRight,         ...
        handles.alignMoveAmount,        ...
        handles.autoAlign,              ...
        handles.averageStrandList,      ...
        handles.smoothingFactor,        ...
        handles.smoothAverageProfile,   ...
        handles.reportPreview,          ...
        handles.saveProfiles],          ...        
        'Enable','on');
    
    set(handles.profilesPanel, 'Title', 'Aligned Profiles');
else
    set([handles.alignMoveLeft,             ...
        handles.alignMoveRight,         ...
        handles.alignMoveAmount,        ...
        handles.autoAlign,              ...
        handles.averageStrandList,      ...
        handles.smoothingFactor,        ...
        handles.smoothAverageProfile,   ...
        handles.reportPreview,          ...
        handles.saveProfiles],          ... 
        'Enable','off');
    
    set(handles.profilesPanel, 'Title', 'Raw Profiles');
end

%update graphs when value changes
alignMHQ = updateProfilesAndImage(alignMHQ, handles);

%save data
setappdata(handles.output,'alignMHQ',alignMHQ)
guidata(hObject, handles)

function autoAlign_Callback(hObject, eventdata, handles)
%get main data structure
alignMHQ = getappdata(handles.output,'alignMHQ');

%get current ion
ionIdx = get(handles.alignIonList, 'Value');
ionName = alignMHQ.ionList{ionIdx};
isWarning = 0;
warning('off'); %suppress warnings

for i = 1:alignMHQ.numStrands
    strandName = alignMHQ.strandList{i};
    refStrand = alignMHQ.strandList{get(handles.alignROIList,'Value')}; %use selected strand as reference
    X = alignMHQ.alignedProfileData.(refStrand).(ionName).mean;
    Y = alignMHQ.alignedProfileData.(strandName).(ionName).mean;
    X = fillmissing(X,'constant',0); %fill in NaN values with 0 to help with alignment
    Y = fillmissing(Y,'constant',0);
    
    lastwarn('');
    [~, ~, D] = alignsignals(Y,X); %perform auto align
    [warnMsg, ~] = lastwarn; %catch warning, alignment failed
    if ~isempty(warnMsg)
        isWarning = 1; %warning occurred, alignment failed
    else
        alignMHQ.alignedProfileData.(strandName).delay = D; %assign delay to structure
    end
end

%update graphs when value changes
alignMHQ = updateProfilesAndImage(alignMHQ, handles);

if isWarning, warndlg('Warning: Automatic alignment for one or more strands failed.'); end %display warning message
warning('on'); %turn warnings back on

%save data
setappdata(handles.output,'alignMHQ',alignMHQ)
guidata(hObject, handles)


% --- Executes on selection change in averageStrandList.
function averageStrandList_Callback(hObject, eventdata, handles)
%get main data structure
alignMHQ = getappdata(handles.output,'alignMHQ');

%update graphs when value changes
alignMHQ = updateProfilesAndImage(alignMHQ, handles);

%save data
setappdata(handles.output,'alignMHQ',alignMHQ)
guidata(hObject, handles);

function smoothingFactor_Callback(hObject, eventdata, handles)
%get main data structure
alignMHQ = getappdata(handles.output,'alignMHQ');

%get value and round to whole number
val = round(str2double(get(hObject,'String')));

if isnan(val)
   set(hObject, 'String', num2str(alignMHQ.smoothingFactor));
else
   alignMHQ.smoothingFactor = val;
   set(hObject,'String', num2str(alignMHQ.smoothingFactor)); 
   %update graphs when value changes
   alignMHQ = updateProfilesAndImage(alignMHQ, handles);
end

%save data
setappdata(handles.output,'alignMHQ',alignMHQ)
guidata(hObject, handles);

% --- Executes on button press in smoothAverageProfile.
function smoothAverageProfile_Callback(hObject, eventdata, handles)
%get main data structure
alignMHQ = getappdata(handles.output,'alignMHQ');

%update graphs when value changes
alignMHQ = updateProfilesAndImage(alignMHQ, handles);

%save data
setappdata(handles.output,'alignMHQ',alignMHQ)
guidata(hObject, handles);

% --- Executes on button press in reportPreview.
function reportPreview_Callback(hObject, eventdata, handles)
% hObject    handle to reportPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveProfiles.
function saveProfiles_Callback(hObject, eventdata, handles)
% hObject    handle to saveProfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%get main data structure
alignMHQ = getappdata(handles.output,'alignMHQ');

alignMHQ = saveProfiles(alignMHQ, handles);

%save data
setappdata(handles.output,'alignMHQ',alignMHQ)
guidata(hObject, handles)




%%%---Object Creation Functions---%%%
%%%-------------------------------%%%
function alignROIList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function alignIonList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function alignMoveAmount_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function averageStrandList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function smoothingFactor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rawProfileExport.
function rawProfileExport_Callback(hObject, eventdata, handles)
% hObject    handle to rawProfileExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rawProfileExport


% --- Executes on button press in alignAvgExport.
function alignAvgExport_Callback(hObject, eventdata, handles)
% hObject    handle to alignAvgExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of alignAvgExport
