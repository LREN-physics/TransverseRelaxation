function [omegasq,R2s,T2mol] = ComputeVarRange(Params)
% Computes variable range depending on model used for data fitting. 
%
% Inputs:
% 	Params: structure with analysis parameters
%
% Outputs:
%	omegasq: values of <Omega^2> which will be used to compute the dictionary [ms^-2]. 
%	R2s: values of R2* which will be used to compute the dictionary [ms^-1]. 
%	T2mol: values of T2mol=1/R2mol which will be used to compute the
%       dictionary. Default is set to only one value [ms].
% _________________________________________________________________________
% Copyright (C) 2023 Laboratory for Neuroimaging Research
% Written by A. Lutti and R. Oliveira, 2023.
% Laboratory for Neuroimaging Research, Lausanne University Hospital, Switzerland

T2mol=0.1*1e3;  % linspace(1/15,1/5,6)*1e3; % R2 between 5 and 15 s-1 at 3T, see Sedlacik et al. 2014
DR2smin=1e-3;   % Additional transverse relaxation rate due to mesoscopic effects, on top of T2 mol

if strcmp(Params.Model.Name,'AW') % Anderson-Weiss Model
    Nomegasq=600; NR2s=200;omegasqMin=1e-4;omegasqMax=4e-2;R2sMin=DR2smin;R2sMax=80e-3;NbDictionaryCols=NR2s*Nomegasq;
    R2s=reshape(repmat(linspace(R2sMin,R2sMax,NR2s),[Nomegasq 1]),[1 NbDictionaryCols]);omegasq=reshape(repmat(linspace(omegasqMin,omegasqMax,Nomegasq)',[1 NR2s]),[1 NbDictionaryCols]);

elseif strcmp(Params.Model.Name,'SY') % Sukstanskii & Yablonskiy Model
    Nomegasq=600;NR2s=200;omegasqMin=1e-4;omegasqMax=8e-2;R2sMin=DR2smin;R2sMax=80e-3;NbDictionaryCols=NR2s*Nomegasq;
    R2s=reshape(repmat(linspace(R2sMin,R2sMax,NR2s),[Nomegasq 1]),[1 NbDictionaryCols]);omegasq=reshape(repmat(linspace(omegasqMin,omegasqMax,Nomegasq)',[1 NR2s]),[1 NbDictionaryCols]);

elseif strcmp(Params.Model.Name,'Pade') % Padé Signal Representation
    Nomegasq=600;NR2s=200;omegasqMin=1e-4;omegasqMax=4e-2;R2sMin=DR2smin;R2sMax=80e-3;NbDictionaryCols=NR2s*Nomegasq;
    R2s=reshape(repmat(linspace(R2sMin,R2sMax,NR2s),[Nomegasq 1]),[1 NbDictionaryCols]);omegasq=reshape(repmat(linspace(omegasqMin,omegasqMax,Nomegasq)',[1 NR2s]),[1 NbDictionaryCols]);

elseif strcmp(Params.Model.Name,'Exp') % Exponential fit
    omegasq=[];NR2s=300;R2sMin=min(1./T2mol)+DR2smin;R2sMax=80e-3; 
    R2s=linspace(R2sMin,R2sMax,NR2s);

else
    omegasq=[];R2s=[];
end

    
end
