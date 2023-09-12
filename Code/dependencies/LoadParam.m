function Params = LoadParam(Subject,Model)
% Load parameters for the analysis one whishes to make.
% 
% Inputs:  
%	Subject: string with the name of the subject to be analysed
%   Model: string with the model used for fitting
%           'Exp'  - Exponential fit
%           'AW'   - Anderson-Weiss Model
%           'SY'   - Sukstanskii & Yablonskiy Model
%           'Pade' - Padé Signal Representation
% Outputs:
%     Params: structure with analysis parameters
% _________________________________________________________________________
% Copyright (C) 2023 Laboratory for Neuroimaging Research
% Written by A. Lutti and R. Oliveira, 2023.
% Laboratory for Neuroimaging Research, Lausanne University Hospital, Switzerland


% ----------------------------------------------------------------------
% EDIT ACCORDING TO YOUR PREFERENCES:

Params.DataStr = {'^resc_den.*.(img|nii)$'}; % expected name for the multi-echo time images of each subject

Params.HomePath     = fullfile('yourpath/Data');  % name of the home directory
Params.MainPath     = fullfile(Params.HomePath,Subject);                      % subject's folder
Params.DataPath     = fullfile(Params.MainPath,'multiecho');                  % folder containing the transverse relaxation data 
Params.OutputPath   = fullfile(Params.MainPath,'modelfits',Model);            % output folder

Params.LowPassLim   = 0.2;  % limit for the low-pass filter. 1=no filter. 
Params.LowPassOrder = 5;    % order for the low-pass filter if its being used (i.e. Params.LowPassLim~=1) 

% ----------------------------------------------------------------------

Params.Subject    = Subject;    % subject to be analysed
Params.Model.Name = Model;      % Model name


% Variable names depending on the model:
if strcmp(Params.Model.Name,'AW') || strcmp(Params.Model.Name,'SY') || strcmp(Params.Model.Name,'Pade') % non exponetial fits
    Params.Model.VarName = {'OmegaSq','R2s','T2mol'};
elseif strcmp(Params.Model.Name,'Exp') % exponential fit
    Params.Model.VarName = {'R2s'};
end

% Create output folder for fitting results
if exist(Params.OutputPath,'dir')
    rmdir(Params.OutputPath,'s')
end
mkdir(Params.OutputPath)

end
