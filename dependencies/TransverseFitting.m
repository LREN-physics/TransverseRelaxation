function TransverseFitting(SubjectName,ModelName)
% Main Function for fitting the data to the different relaxation models
% Depending on the relaxation models used the estimated/fitted parameters
% will be different.
%
% Inputs:
%	SubjectName: string with the name of the subject to be analysed
%   ModelName: string with the model used for fitting
%           'Exp'  - Exponential fit
%           'AW'   - Anderson-Weiss Model
%           'SY'   - Sukstanskii & Yablonskiy Model
%           'Pade' - Padé Signal Representation
%
% Outputs:
%   none
% _________________________________________________________________________
% Copyright (C) 2023 Laboratory for Neuroimaging Research
% Written by A. Lutti and R. Oliveira, 2023.
% Laboratory for Neuroimaging Research, Lausanne University Hospital, Switzerland

tic

% Loads parameters for analysis
disp('Loading parameters ...')
Params = LoadParam(SubjectName,ModelName);
 
% Get data information
[Params,P,Vsave] = FetchDataInfo(Params);
 
% Compute variable ranges
disp('Computing dictionary variable range ...')
[omegasq,R2s,T2mol] = ComputeVarRange(Params);

% Build Dictionary
disp('Building dictionary ...')
[S,ModelVariables,dof] = BuildDictionary(Params,omegasq,R2s,T2mol);

% Load noise floor level in the transverse relaxation images (Rician noise)
nf = load(fullfile(Params.DataPath,'nf.mat')); nf=nf.nf;

% Compute Data Matrix
disp('Building data matrix for fitting ...')
[DataMatrix,VoxelIndices] = ComputeDataMatrix(Params,P,nf);

% Run the fit of the model
disp('Fitting of the transverse relaxation decay ...')
[FitResults,MSE,TE0signal,AIC] = ModelFit(DataMatrix,S,ModelVariables,dof);

% Save fit results 
disp('Saving results ...')
SaveFitResults(Params,FitResults,MSE,AIC,TE0signal,DataMatrix,Vsave,VoxelIndices);

% Compute microstructural parameters
disp('Computing microstructural maps ...')
ComputeMicroParams(Params);

toc
end



