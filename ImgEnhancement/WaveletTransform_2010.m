
epid0_filename = fullfile('../Data', 'EPID/09_ZYH_0205/EPID0.dcm');
epid90_filename = fullfile('../Data', 'EPID/09_ZYH_0205/EPID90.dcm');

epid0_img = dicomread(epid0_filename);
epid90_img = dicomread(epid90_filename);
