clc;clear all;close all;


listing=subdir(['D:\Img2ImgCNN\retina_segment/valid/gt']);

listing={listing(:).name};

for name=listing
    name=name{1};
    data=imread(name);
    data=uint8(data>0)*255;
    
    imwrite(data,name);
    
    
    
    
end







