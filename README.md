# Transverse Relaxation 

## Introduction

This repository includes the original analysis code used to compile the results presented in the scientific publication:  
*Non-exponential transverse relaxation decay in subcortical grey matter*   
*Rita Oliveira, Quentin Raynaud, Valerij Kiselev, Ileana Jelescu, Antoine Lutti*

Classically, the MRI transverse relaxation decay is analyzed by fitting the signal decay over echo time voxel-wise with a monoexponential function (Exp), for which a decay rate $R^\*_{2}$ is estimated. However, the presence of magnetic material within the tissue, such as iron-loaded cells, myelin, or blood vessels, introduces variations in the magnetic field, which can modify the exponential behaviour of the decay (1,2). In such inhomogeneous magnetic fields, the theory predicts a transient regime starting with a Gaussian behaviour at short echo times and approaching a monoexponential relaxation at long echo times (1,3–6).

We highlight three different analytical descriptions of the signal decay that account for the transient regime of the transverse relaxation decay: the Anderson and Weiss, 1953 model (AW), the Sukstanskii and Yablonskiy, 2003 model (SY), and following a Padé approximation (Padé) of the transition from Gaussian to exponential decay.

This repository aims to explore the non-exponential MRI transverse relaxation. The implemented code employs a dictionary-based fitting approach to analyze the transverse relaxation data voxel-wise. The fitting routine with AW, SY, or Padé methods involves estimating the following parameters:

&nbsp; **$\sqrt{<\Omega^2>}$**: mean square frequency deviation due to the field inhomogeneities induced by the magnetic material, pertains to the Gaussian behaviour at short echo times [ms<sup>-2</sup>]  
&nbsp; **$R^\*_{2,micro}$**: effective transverse relaxation rate resulting from processes on the microscale, pertains to the exponential behaviour at long echo times [ms<sup>-1</sup>]  
&nbsp; **$S_0$**: initial signal amplitude  
&nbsp; **$T_{2,mol}$**: inverse of effective transverse relaxation rate resulting from processes on the nanoscale [ms]  

Additionally, this code allows the user to estimate tissue properties associated with the different regimes that describe the transverse relaxation decay. The regimes considered are the SDR (static dephasing regime) and DNR (diffusion narrowing regime). In the SDR (5), water diffusion is minimal and spin dephasing is caused primarily by the static magnetic field inhomogeneities. Conversely, in the DNR (3,4), fast molecular diffusion dominates the spin-dephasing process. We combined the estimated parameters $R^\*_{2,micro}$ and $\sqrt{<\Omega^2>}$ and calculate:

&nbsp; under the assumption of SDR:  
   &nbsp; **$\Delta\chi$**: difference in susceptibility of the magnetic inclusions to the surrounding tissue [addimentional, in ppm and in SI units]  
   &nbsp; **$\zeta$**: volume fraction of the magnetic inclusions [addimentional]

&nbsp; under the assumption of DNR:  
    &nbsp; **$\alpha = \tau \sqrt{<\Omega^2>}$** [addimentional]  
    &nbsp; **$\tau$**: time scale for water molecules to diffuse away from magnetic inclusions [ms]

 ## Getting Started

 ### Requirements
 
-	Running version of Matlab (The MathWorks, Natick, MA). In our work, we used version 2021a.  
-	spm12 toolbox (https://www.fil.ion.ucl.ac.uk/spm/software/download/) 

### Data

The required data is:  
- Multi-echo gradient-echo data: one magnitude nifty (.nii) file per echo time. Multiple repetitions may exist and should be organized in different folders. The description field of the header of the images contains the corresponding TE at which the image was acquired, which will be needed in the fitting routine.  
- nf: value corresponding to the noise floor level. In our work, nf corresponds to the noncentrality parameter of a Rician distribution fitted to the background signal.  

Example data can be found in our online [repository](https://doi.org/10.5281/zenodo.8338046), along with a comprehensive description of the provided data.  

### How to use

1.	Download this repository.  
2.	In Matlab, add to your path the provided repository and spm toolbox.  
3.	Edit LoadParams.m according to your working data directory. If desired, edit the filter parameters and string corresponding to the expected name for the multi-echo gradient-echo images.  
4.	Run the main function TransverseRelaxation_caller.m with the name of the method and subjects to analyze as arguments.  
	example: TransverseRelaxation_caller({‘AW’,’SY’},{‘sub-01’})

## Description of the main analysis functions

**TransverseRelaxation_caller**: main function that starts the analysis. It receives as inputs the list of subject names to be analyzed; and the list of analytical descriptions of the signal to fit the data, being the available options:  
-	Exp (Exponential Model)  
-	AW (Anderson-Weiss Model)  
-	SY (Sukstanskii & Yablonskiy Model)  
-	Padé (Padé Signal Representation)

At the end of this analysis, the user will have maps of $R^\ast_{2}$ if using the exponential model. Maps of $R^\ast_{2,micro}$ and $\sqrt{<\Omega^2>}$ will be created if using the AW, SY or Padé models. 
From the $R^\ast_{2,micro}$ and $\sqrt{<\Omega^2>}$, maps of $\Delta\chi$ and $\zeta$ under the assumption of SDR, and $\alpha$ and $\tau$ under the assumption of DNR are also computed.  

If no argument is given, the analysis is run with the data from ‘sub-01’ to ‘sub-05’ and with the four methods above ‘Exp’, ‘AW’, ‘SY’, and ‘Padé’.  
Other additional files will be created during this routine, such as mean square error maps or the $S_0$ map. Please refer to the data description (available online [here](https://doi.org/10.5281/zenodo.8338046)) or Matlab scripts for more information on those files.

**TransverseRelaxation**: script that runs all the analysis. Includes:  

  - Loading the setting parameters (LoadParams).
  - Computing the range of the variables for building the dictionary (ComputeVarRange ComputeVarRange).
  - Building the decay dictionary (BuildDictionary).
  - Computing the data matrix from the image data (ComputeDataMatrix). Includes the removal of the background noise and filtering.
  - Dictionary fitting of the data (ModelFit).
  - Saving the results of the fit (SaveFitResults).
  - Computing microstructural parameters (ComputeMicroParams: $\Delta\chi$ and $\zeta$ maps under the assumption of SDR and $\alpha$ and $\tau$ maps under the assumption of DNR)  

**LoadParams**: creates a Params structure with the analysis parameters, which includes the paths to the different data folders, the string corresponding to the expected name for the images of each subject (set as default to ‘resc_den’), the low-filter settings (the cutoff is set as default to 0.2 and the order to 5), and the name of the fitted parameters (which depend on the chosen method). The user is asked to edit this file according to preferences before running the analysis.

**ComputeVarRange**: computes the variable range for building the dictionary. In the case of non-exponential methods, those variables are: $R^\ast_{2,micro}$, $\sqrt{<\Omega^2>}$ and $T_{2,mol}$. The latter variable is pre-defined with one default value, and therefore, it is not subjected to estimation in the current implementation. For the exponential model, there is only one variable: $R^\*_{2}$. To modify the range of the dictionary, the user can make the necessary adjustments in this script.


## Contact

Rita Oliveira, Antoine Lutti    
Laboratory for Research in Neuroimaging (LREN)   
Department of Clinical Neuroscience, Lausanne University Hospital and University of Lausanne   
Mont-Paisible 16, CH-1011 Lausanne, Switzerland   
Email: rita.oliveira.uni@gmail.com   
Last updated: July 2023

## License
Distributed under the GPL-3.0 license. See LICENSE.txt for more information.

## References
1. 	Kiselev VG, Novikov DS. Transverse NMR relaxation in biological tissues. Neuroimage. 2018;182(June):149–68. 
2. 	Haacke EM, Cheng NYC, House MJ, Liu Q, Neelavalli J, Ogg RJ, et al. Imaging iron stores in the brain using magnetic resonance imaging. Magn Reson Imaging. 2005;23(1):1–25.   
3. 	Jensen JH, Chandra R. NMR relaxation in tissues with weak magnetic inhomogeneities. Magn Reson Med. 2000;44(1):144–56.   
4. 	Sukstanskii AL, Yablonskiy DA. Gaussian approximation in the theory of MR signal formation in the presence of structure-specific magnetic field inhomogeneities. J Magn Reson. 2003;163(2):236–47.   
5. 	Yablonskiy DA, Haacke EM. Theory of NMR signal behavior in magnetically inhomogeneous tissues: The static dephasing regime. Magn Reson Med. 1994;32(6):749–63.   
6. 	Kiselev VG, Novikov DS. Transverse NMR Relaxation as a Probe of Mesoscopic Structure. Phys Rev Lett. 2002;89(27):2–5.   
7. 	Anderson PW, Weiss PR. Exchange Narrowing in Paramagnetic Resonance. Exch Organ Behav Teach J. 1953;679(1948).   




