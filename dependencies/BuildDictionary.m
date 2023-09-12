function [S,ModelVariables,dof] = BuildDictionary(Params,omegasq,R2s,T2mol)
% Builds dictionary for the transverse decay
%
% Inputs:
%	Params: structure with analysis parameters
%	omegasq: values of <Omega^2> which will be used to compute the dictionary [1 x paramater resolution] 
%	R2s: values of R2* which will be used to compute the dictionary [1 x paramater resolution] 
%	T2mol: values of T2mol=1/R2mol which will be used to compute the dictionary [1 x paramater resolution] 
%
% Outputs:
%	S: dictionary matrix [number of echo times in all repetitions x paramater resolution] 
%	ModelVariables: variable values associated with each column of the dictionary [N variables x paramater resolution] 
%	dof: degrees of freedom of the model fit
% _________________________________________________________________________
% Copyright (C) 2023 Laboratory for Neuroimaging Research
% Written by A. Lutti and R. Oliveira, 2023.
% Laboratory for Neuroimaging Research, Lausanne University Hospital, Switzerland

% First, build the template 
[Stemplate,ModelVariables,dof]=BuildDicoTemplate(omegasq,R2s,Params,T2mol);

% Second, build the dictionary
S=[];
for ctr=1:size(Params.Datasets,2) % loop for each data/repetition folder
%     For each repetition of raw data used for the fitting, the dictionary
%     is composed of the elements of Stemplate that match the data's echo
%     times
    S=cat(1,S,Stemplate(Params.Datasets(ctr).TEind,:)); % Dictionary S contains samples of Stemplate for the echo times of the data
end

% Third, filter S
if Params.LowPassLim ~=1    % low-pass filtering of dictionary columns. 
    S=myfilter(S,Params,Params.LowPassOrder,Params.LowPassLim,'low');
end
end


%% Auxiliar function: BuildDicoTemplate
function [Stemplate,ModelVariables,dof]=BuildDicoTemplate(omegasq,R2s,Params,T2mol)
% Builds the template for the transverse decay
%
% Inputs:
%       omegasq: list of possible <Omega^2> values
%       R2s:     list of possible R2* values
%       Params:  structure with analysis parameters
%       T2mol:   list of possible T2mol values
%
% Outputs:
%       Stemplate: matrix containing the possible decays curves [unique echo time x paramater resolution] 
%       ModelVariables: variable values associated with each column of the dictionary [N variables x paramater resolution] 

UniqueTEs=unique(cat(1,Params.Datasets(1:end).TEs));

if strcmp(Params.Model.Name,'AW')
    % Anderson & Weiss Model, from Anderson & Weiss, Reviews of Modern Physics (1953)
    % The original formulation written in terms of Tau and Omega^2 (which 
    % can be found in Principles of Nuclear Magnetic Resonance Microscopy, 
    % Paul T. Callagan (1991), Oxford Press) was adapted by changing the 
    % variable Tau to R2s. R2s was defined as the scaling factor of the 
    % exponential expression that appears in the long time limit
    % (i.e. TE>>Tau).

    TEs=repmat(UniqueTEs,[1 size(omegasq,2)]);
    Stemplate=[];
    for ctr=1:size(T2mol,2)
        Stemplate=cat(2,Stemplate,reshape(exp(-repmat(R2s,[size(TEs,1) 1]).^2./repmat(omegasq,[size(TEs,1) 1]).*(exp(-TEs.*repmat(omegasq,[size(TEs,1) 1])./repmat(R2s,[size(TEs,1) 1]))-1+TEs.*repmat(omegasq,[size(TEs,1) 1])./repmat(R2s,[size(TEs,1) 1])))...
            .*exp(-TEs/T2mol(ctr)),[size(TEs,1) size(omegasq,2)]));
    end
    omegasq=repmat(omegasq,[1,size(T2mol,2)]);R2s=repmat(R2s,[1,size(T2mol,2)]);
    if size(T2mol,2)==1
        dof=2;
    else
        dof=3;
    end
    T2mol=reshape(repmat(T2mol',[1 size(TEs,2)])',[1 size(T2mol,2)*size(TEs,2)]);
    ModelVariables=cat(1,omegasq,R2s,T2mol);
    

elseif strcmp(Params.Model.Name,'SY')
    % Sukstanskii & Yablonskiy Model, from Sukstanskii & Yablonskiy, JMR (2003)
    % The original formulation written in terms of Tau and Omega^2 (Eq. 36 
    % of the cited atricle) was adapted by changing the variable Tau to R2s.
    % R2s was defined as the scaling factor of the exponential expression 
    % that appears in the long time limit (i.e. TE>>Tau).
    % This model is identical to the one of Jensen & Chandra,
    % JMR (2000), with Tau_JC = Tau_SY/5,
    
    TEs=repmat(UniqueTEs,[1 size(omegasq,2)]);
    Stemplate=[];
    for ctr=1:size(T2mol,2)
        Stemplate=cat(2,Stemplate,reshape(exp(-0.5.*repmat(R2s,[size(TEs,1) 1]).^2./repmat(omegasq,[size(TEs,1) 1]).*((1+2.*TEs.*repmat(omegasq,[size(TEs,1) 1])./repmat(R2s,[size(TEs,1) 1])).^0.5-1).^2).*exp(-TEs/T2mol(ctr)),[size(TEs,1) size(omegasq,2)]));
    end
    omegasq=repmat(omegasq,[1,size(T2mol,2)]);R2s=repmat(R2s,[1,size(T2mol,2)]);
    if size(T2mol,2)==1
        dof=2;
    else
        dof=3;
    end
    T2mol=reshape(repmat(T2mol',[1 size(TEs,2)])',[1 size(T2mol,2)*size(TEs,2)]);
    ModelVariables=cat(1,omegasq,R2s,T2mol);
    
elseif strcmp(Params.Model.Name,'Pade')
    % Padé Signal Representation
    % Obtained by using Padé approximation of the transition from Gaussian 
    % to exponential decay 
    
    TEs=repmat(UniqueTEs,[1 size(omegasq,2)]);
    Stemplate=[];
    for ctr=1:size(T2mol,2)
        Stemplate=cat(2,Stemplate,reshape(exp(-repmat(omegasq,[size(TEs,1) 1]).*TEs.^2./(2.*(1+repmat(omegasq,[size(TEs,1) 1]).*TEs./(2.*repmat(R2s,[size(TEs,1) 1]))))).*exp(-TEs/T2mol(ctr)),[size(TEs,1) size(omegasq,2)]));
    end
    omegasq=repmat(omegasq,[1,size(T2mol,2)]);R2s=repmat(R2s,[1,size(T2mol,2)]);
    if size(T2mol,2)==1
        dof=2;
    else
        dof=3;
    end
    T2mol=reshape(repmat(T2mol',[1 size(TEs,2)])',[1 size(T2mol,2)*size(TEs,2)]);
    ModelVariables=cat(1,omegasq,R2s,T2mol);
       
    
elseif strcmp(Params.Model.Name,'Exp')
    % Mono-exponential model
    
    TEs=repmat(UniqueTEs,[1 size(R2s,2)]);
    Stemplate=reshape(exp(-repmat(R2s,[size(TEs,1) 1]).*TEs),[size(TEs,1) size(R2s,2)]);
    dof=1;
    ModelVariables=R2s;
    
end

end