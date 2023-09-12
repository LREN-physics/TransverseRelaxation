function [DataMatrix,VoxelIndices] = ComputeDataMatrix(Params,P,nf)
% Reads-in image data into matlab matrix. Includes removal of noise
% floor and filtering.
% 
% Inputs:
%	Params: structure with analysis parameters
%	P: cell array [number of repetitions x 1] with the complete paths to each echo image
%   nf: noise floor value
%
% Outputs:
%	DataMatrix: data matrix contaning the signal signal for each of the 
%       voxels considered in the analysis concatenated across repetitions
%       [number of echo times in all repetitions x number of voxels]
% 	VoxelIndices: indices for the location of the analyzed voxels in 3D space [number of voxels x 1]
% _________________________________________________________________________
% Copyright (C) 2023 Laboratory for Neuroimaging Research
% Written by A. Lutti, 2023.
% Laboratory for Neuroimaging Research, Lausanne University Hospital, Switzerland

% Builds data matrix
DataMatrix=[];
for ctr=1:size(Params.Datasets,2)
    DataMatrix=cat(4,DataMatrix,spm_read_vols(spm_vol(P{ctr})));
end

% Removes Nan voxels
[DataMatrix,VoxelIndices]=RemoveNanVoxels(DataMatrix);

% Removes Rician noise form the data matrix
DataMatrix=DataMatrix-nf;

% Low-pass filtering
if Params.LowPassLim ~=1 
    DataMatrix=myfilter(DataMatrix,Params,Params.LowPassOrder,Params.LowPassLim,'low');
end
end


%% Auxiliar Function: RemoveNanVoxels
function [MatArray,Indx]=RemoveNanVoxels(DataIn)
Indx=find(DataIn(:,:,:,1)~=0);
MatArray=zeros(size(DataIn,4),size(Indx,1));
for ctr=1:size(DataIn,4)
    Test=squeeze(DataIn(:,:,:,ctr));
    MatArray(ctr,:)=Test(Indx);
end
NaNIndx=[];
for ctr=1:size(MatArray,2)
    if ~isempty(find(isnan(MatArray(:,ctr))))
        NaNIndx=[NaNIndx,ctr];
    end
end
Indx(NaNIndx)=[];
MatArray(:,NaNIndx)=[];
end

