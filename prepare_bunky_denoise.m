clc;clear all;close all;

listing=dir(['D:\Img2ImgCNN\bunky_denoise\raw']);

folders={listing(3:end).name};

for k=1:length(folders)
    folders{k}=['D:\Img2ImgCNN\bunky_denoise\raw\' folders{k}];
    
end

citac=0;
kk=0;
for folder=folders
    kk=kk+1;
    
    listing=subdir([folder{1} '/*.png']);
    listing={listing(:).name};
    
    for k=1:50
        citac=citac+1;
        name=listing{k};
        name_gt=strrep(name,'raw','gt');
        tmp=strsplit(name_gt,'\');
        tmp=strjoin(tmp(1:end-1),'\');
        name_gt=[tmp '\avg50.png'];
        
        data=imread(name);
        gt=imread(name_gt);
        
        imwrite(data,['../tmp_bunky/data/' num2str(citac,'%04.f') '.png']);
        imwrite(gt,['../tmp_bunky/gt/' num2str(citac,'%04.f') '.png']);
        
   
    end
    
    
    
end