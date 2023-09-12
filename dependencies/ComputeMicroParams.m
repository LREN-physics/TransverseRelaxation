function ComputeMicroParams(Params)
% Estimate and compute microparameters maps from the fitted macro parameters
% To use only for models that estimated R2s and Omega parameters (i.e. AW,
% SY and Padé)
%
% Inputs:
%     Params: structure with the analysis parameters
%
% Outputs:
%    none
% _________________________________________________________________________
% Copyright (C) 2023 Laboratory for Neuroimaging Research
% Written by R. Oliveira, 2023.
% Laboratory for Neuroimaging Research, Lausanne University Hospital, Switzerland

if strcmp(Params.Model.Name,'AW') || strcmp(Params.Model.Name,'SY') || strcmp(Params.Model.Name,'Pade') 
    
% Load R2s and Omega          
R2s = spm_read_vols(spm_vol(spm_select('FPList',Params.OutputPath,'^R2s.*.nii$'))).*1e3;
omega = spm_read_vols(spm_vol(spm_select('FPList',Params.OutputPath,'^Omega.*.nii$'))).*1e6;
header  = spm_vol(spm_select('FPList',Params.OutputPath,'^R2s.*.nii$'));     
               
% SDR parameter estimation
dw=(1.2092.*omega)./(0.8.*R2s);
dw(isnan(dw))=0;
zeta=omega./(0.8*dw.^2);
zeta(isnan(zeta))=0;
ki = dw./(2.675e8*1/3*3); 
ki(isnan(ki))=0;
dwHz=dw/(2*pi);
dwHz(isnan(dwHz))=0;

% DNR parameter estimation
tau=1/0.4*R2s./omega./6;
tau(isnan(tau))=0;
dw_2_zeta=omega./0.8;
dw_2_zeta(isnan(dw_2_zeta))=0;
alpha=tau.*sqrt(omega);
alpha(isnan(alpha))=0;
    
% Save images
mkdir(fullfile(Params.OutputPath,'SDR'))
mkdir(fullfile(Params.OutputPath,'DNR'))
header.dt=[16 0];
header.fname=fullfile(Params.OutputPath,'SDR','zeta.nii');spm_write_vol(header,zeta);
header.fname=fullfile(Params.OutputPath,'SDR','ki_ppm.nii');spm_write_vol(header,ki.*1e6);
header.fname=fullfile(Params.OutputPath,'DNR','tau_ms.nii');spm_write_vol(header,tau.*1e3);
header.fname=fullfile(Params.OutputPath,'DNR','alpha.nii');spm_write_vol(header,alpha);

end

end
            
       
