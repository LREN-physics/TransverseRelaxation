function [Datapt]=myfilter(Datapt,Params,Order,Lim,flag)  
% Filters the data
% _________________________________________________________________________
% Copyright (C) 2023 Laboratory for Neuroimaging Research
% Written by A. Lutti, 2023.
% Laboratory for Neuroimaging Research, Lausanne University Hospital, Switzerland

ctemp=0;
for ctr2=1:size(Params.Datasets,2)
    if (strcmp(flag,'high')||strcmp(flag,'low'))
        [b,a] = butter(Order,Lim,flag);
    else
        [b,a] = butter(Order,Lim);
    end
%     h = fvtool(b,a);                 % Visualize filter
    TempMat=Datapt(ctemp+1:ctemp+size(Params.Datasets(ctr2).TEs,1),:);
%     parfor ctr=1:size(Datapt,2)
    for ctr=1:size(Datapt,2)
        TempMat(:,ctr)=filtfilt(b,a,TempMat(:,ctr));
    end
    Datapt(ctemp+1:ctemp+size(Params.Datasets(ctr2).TEs,1),:)=TempMat;
    ctemp=ctemp+size(Params.Datasets(ctr2).TEs,1);
end

end