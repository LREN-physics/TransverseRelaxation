function [Params,P,Vsave] = FetchDataInfo(Params)
% Gets the information from the data
%
% Inputs:
%	Params: structure with analysis parameters
%
% Outputs:
%   Params: Params structure updated with new info
%   P: cell array [number of repetitions x 1] with the complete paths to each echo image
%   Vsave: structure with the data from the first echo to be used as template when saving computed maps
% _________________________________________________________________________
% Copyright (C) 2023 Laboratory for Neuroimaging Research
% Written by A. Lutti, 2023.
% Laboratory for Neuroimaging Research, Lausanne University Hospital, Switzerland

P='';

% Search for data folders
tempDir=dir(Params.DataPath); Indx = [];
for j=1:size(tempDir,1)
    if contains(tempDir(j).name,'rep') &&  tempDir(j).isdir
        Indx=[Indx, j];
    end
end

% If there is data folders
if ~isempty(Indx)
    
    % Loop for data folders / repetition folders
    for ctr=1:size(Indx,2)
        Params.Datasets(ctr).FolderName=tempDir(Indx(ctr)).name;
        
        % Get TE values and paths if there is data in the data folder
        if ~isempty(spm_select('FPList',fullfile(Params.DataPath,Params.Datasets(ctr).FolderName),Params.DataStr{1}))
            P=cat(1,P,{spm_select('FPList',fullfile(Params.DataPath,Params.Datasets(ctr).FolderName),Params.DataStr{1})});
            p=hinfo(spm_select('FPList',fullfile(Params.DataPath,Params.Datasets(ctr).FolderName),Params.DataStr{1}));
            Params.Datasets(ctr).TEs=[p.te]';
        end
        
    end
    
    % Create output example structure
    Vsave=spm_vol(P{1}); Vsave=Vsave(1);
    
    % Update Params with the number of echo times
    for ctr=1:size(Params.Datasets,2)
        [~,Params.Datasets(ctr).TEind]=ismember(Params.Datasets(ctr).TEs,unique(cat(1,Params.Datasets(1:end).TEs)));
        if ctr==1
            Params.Min_Echo_nb=size(Params.Datasets(ctr).TEs,1);
        else
            Params.Min_Echo_nb=min(Params.Min_Echo_nb,size(Params.Datasets(ctr).TEs,1));
        end
    end 
    
% If there aren't suitable data folders, do nothing
else
    Params=[];P=[];Vsave=[];
end


if isempty(Params)
    return  
end

end

%% Auxilar function: hinfo

function p = hinfo(P)
% Function to get info from headers of images. Used in FetchDataInfo

N = nifti(P);
for ii = 1:numel(N),
    tmp = regexp(N(ii).descrip,...
        'TR=(?<tr>.+)ms/TE=(?<te>.+)ms/FA=(?<fa>.+)deg',...
        'names');
    p(ii).tr=str2num(tmp.tr);
    p(ii).te=str2num(tmp.te);
    p(ii).fa=str2num(tmp.fa);
end

end
