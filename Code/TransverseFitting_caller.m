function TransverseFitting_caller(Models,Subjects)
% Main function that starts the analysis of the transverse relaxation decay
% data.
%
% Inputs:
%	Models: cell array with a list of the Models one wishes to run.
%           'Exp'  - Exponential fit
%           'AW'   - Anderson-Weiss Model
%           'SY'   - Sukstanskii & Yablonskiy Model
%           'Pade' - Padé Signal Representation
%       By default runs on all the models above.
%	Subjects: cell array with a list of the subject names to be analyzed.
%       By default runs it on 'sub-01' to 'sub-05'.
%
% Outputs:
%   none
%
% Files created:
%   The fitting routine will produce maps of R2*_micro and  <Omega^2> for the non-
%       exponential methods and R2* for the exponential model.
%   From the R2*_micro and  <Omega^2>, maps of susceptibility and zeta under the assumption of SDR, 
%       and alpha and tau under the assumption of DNR are also computed.
%   Extra files will be created to support the analysis.
%
% Example command:
%   TransverseFitting_caller({'AW','SY'},{'sub-01'})
% _________________________________________________________________________
% Copyright (C) 2023 Laboratory for Neuroimaging Research
% Written by A. Lutti and R. Oliveira, 2023.
% Laboratory for Neuroimaging Research, Lausanne University Hospital, Switzerland

% set as default
if nargin~=2
    Models={'AW','SY','Pade','Exp'};
    Subjects={'sub-01','sub-02','sub-03','sub-04','sub-05'};
end

% runs the transverse fitting for each subject and model
for subjctr=1:size(Subjects,2)
    for modelctr=1:size(Models,2)
        fprintf('\n ----- Working on subject %s and method %s  ----- \n',Subjects{subjctr},Models{modelctr})
        TransverseFitting(Subjects{subjctr},Models{modelctr});
        fprintf(' \n')
    end
end

fprintf('Finished \n')

end
