function [FitResults,MSE,TE0signal,AIC,Res]=ModelFit(DataMatrix,S,ModelVariables,dof)
% Runs model fitting between the raw data and the dictionary.
% Retrieves the variable values of the optimal solution
%
% Inputs:
%	DataMatrix: data matrix contaning the signal signal for each of the 
%       voxels considered in the analysis concatenated across repetitions
%       [number of echo times in all repetitions x number of voxels]
%	S: dictionary matrix [number of echo times in all repetitions x paramater resolution] 
%	ModelVariables: variable values associated with each column of the dictionary [N variables x paramater resolution] 
%
% Outputs:
%	FitResults: fitting estimates for all voxels considered in the analysis 
%       and estimated parameters [number of estimated parameters x number of voxels]
% 	MSE: mean square error for all voxels considered in the analysis [1 x number of voxels]
%	TE0signal: signal intensities S0 for all voxels considered in the analysis [1 x number of voxels]
%	AIC: Akaike information criterion for all voxels considered in the analysis [1 x number of voxels]
%	Res: residuals at all echo times [number of echo times in all repetitions x number of voxels] 
% _________________________________________________________________________
% Copyright (C) 2023 Laboratory for Neuroimaging Research
% Written by A. Lutti, 2023.
% Laboratory for Neuroimaging Research, Lausanne University Hospital, Switzerland

% initiate variables
FitResults=zeros(size(ModelVariables,1),size(DataMatrix,2));
MSE=zeros(1,size(DataMatrix,2));AIC=zeros(1,size(DataMatrix,2));
TE0signal=zeros(1,size(DataMatrix,2));
Res=zeros(size(DataMatrix));

% loop for the voxels of interest (in DataMatrix) and choses the column
% of the dictionary that best fits the decay data of that voxel. Saves the
% results in a 3D matrix for later saving in image format. Also computes
% AIC and MSE metrics for each voxel
for ctr1=1:size(DataMatrix,2)
    Reg=DataMatrix(:,ctr1);
    b=pinv(Reg'*Reg)*Reg'*S;
    [MSE(ctr1),IndxMin]=min(mean((Reg-S./b).^2,1));
    Res(:,ctr1)=Reg-S(:,IndxMin)./b(IndxMin);
    FitResults(:,ctr1)=ModelVariables(:,IndxMin);
    TE0signal(ctr1)=1/b(1,IndxMin);
    AIC(ctr1)=size(DataMatrix,1)*log(MSE(ctr1))+2*(dof + 1 + 1); % For any least squares model with i.i.d. Gaussian residuals, the variance of the residuals' distributions should be counted as one of the parameters
end


end