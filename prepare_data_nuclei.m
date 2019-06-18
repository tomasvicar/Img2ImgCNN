clc;clear all;close all
kolik=20000;
odkud_kam=[10 300];
sizes=[128 128];

slozky={'../tmp/DU145_do'};
names_qpi={};
for k = slozky
    listing=subdir([k{1} '/Compensated phase-pgp*.tiff']);
    names_qpi=[names_qpi {listing(:).name}];
end
names_dapi={};
for name=names_qpi
    names_dapi=[names_dapi strrep(name{1},'Compensated phase-pgpum2','Clipped-DAPI')];
end

names_qpi=names_qpi(1:7);
names_dapi=names_dapi(1:7);

img_size=[600 600];

mkdir('../tmp/qpi')
mkdir('../tmp/dapi')

citac=0;
for snimek_num=1:7
for k=10:3:200
    snimek_num
    k
    
    citac=citac+1
    
 
    
    qpi = double(imread(names_qpi{snimek_num},k));
    
    dapi = double(imread(names_dapi{snimek_num},k));
    
    qpi=single(mat2gray(qpi,[-0.1 2.4]));
    
    dapi=single(mat2gray(dapi,[0 1200]));
    

    
    imwrite_single(['../tmp/qpi/' num2str(citac,'%07.f') '.tif'],qpi)
    imwrite_single(['../tmp/dapi/' num2str(citac,'%07.f') '.tif'],dapi)
    
    
end
end