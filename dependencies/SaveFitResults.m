function SaveFitResults(Params,FitMat,MSEMat,AICMat,TE0signal,DataMatrix,Vsave,VoxelIndices)
% Save results from the data fit
%
% Inputs:
%	Params: structure with analysis parameters
%	FitMat: fitting estimates for all voxels considered in the analysis 
%       and estimated parameters [number of estimated parameters x number of voxels]
%	MSEMat: mean square error for all voxels considered in the analysis [1 x number of voxels]
%	AICMat: Akaike information criterion for all voxels considered in the analysis [1 x number of voxels]
%	TE0signal: signal intensities S0 for all voxels considered in the analysis [1 x number of voxels]
%	DataMatrix: data matrix contaning the signal signal for each of the 
%       voxels considered in the analysis concatenated across repetitions
%       [number of echo times in all repetitions x number of voxels]
%   Vsave: structure with the data from the first echo to be used as template when saving computed maps
%	VoxelIndices: indices for the location of the analyzed voxels in 3D space [number of voxels x 1]
%
% Outputs:
%   none
% _________________________________________________________________________
% Copyright (C) 2023 Laboratory for Neuroimaging Research
% Written by A. Lutti, 2023.
% Laboratory for Neuroimaging Research, Lausanne University Hospital, Switzerland

    
% Initiate image matrix
ParamMap=zeros(size(Params.Model.VarName,2),Vsave.dim(1),Vsave.dim(2),Vsave.dim(3));
MSE=zeros(Vsave.dim(1),Vsave.dim(2),Vsave.dim(3));
TE0map=zeros(Vsave.dim(1),Vsave.dim(2),Vsave.dim(3));
AICmap=zeros(Vsave.dim(1),Vsave.dim(2),Vsave.dim(3));

% Replace the values of the voxels considered in the analysis with the
% corresponding results
ParamMap(:,VoxelIndices)=FitMat;
MSE(VoxelIndices)=MSEMat;TE0map(VoxelIndices)=TE0signal;
AICmap(VoxelIndices)=AICMat;

% Save images
Vsave.dt=[16 0];
for ctr=1:size(Params.Model.VarName,2)
    Vsave.fname=fullfile(Params.OutputPath,[Params.Model.VarName{ctr} '.nii']);spm_write_vol(Vsave,squeeze(ParamMap(ctr,:,:,:)));
end
Vsave.fname=fullfile(Params.OutputPath,'MSE.nii');spm_write_vol(Vsave,MSE);
Vsave.fname=fullfile(Params.OutputPath,'AIC.nii');spm_write_vol(Vsave,AICmap);
Vsave.fname=fullfile(Params.OutputPath,'TE0signal.nii');spm_write_vol(Vsave,TE0map);
save(fullfile(Params.OutputPath,'Params.mat'),'Params', '-v7.3');
save(fullfile(Params.OutputPath,'DataMatrix.mat'),'DataMatrix', '-v7.3');
save(fullfile(Params.OutputPath,'VoxelIndices.mat'),'VoxelIndices', '-v7.3');

 
end