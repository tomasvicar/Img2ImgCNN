clc;clear all;close all;
% delete(gcp('nocreate'))
% parpool(4)

listing=subdir('../../denoise_ocka/data/*.avi');

listing={listing.name};

mkdir('../retina/data')
mkdir('../retina/gt')


for file_num=1:length(listing)
    file_num
    v = VideoReader(listing{file_num});
    
    name=listing{file_num};
    

    
    num_of_frames=round(v.Duration*v.FrameRate);
    img_size=[v.Height,v.Width,];
    
    imgs=zeros([img_size num_of_frames]);
    
    frame=0;
    pocitacni=0;
    while hasFrame(v)
        frame=frame+1;
        img = readFrame(v);
        img=rgb2gray(single(img)/255);
        imgs(:,:,frame)=img;
        if 1%mod(frame,10)==0
            pocitacni=pocitacni+1;
            imwrite_single(['../retina/data/' num2str(file_num,'%03.f') '_' num2str(frame,'%03.f') '.tif'],img(50:end-50,50:end-50)); 
        end
        
    end
    
    
    mean_img=single(mean(imgs,3));
    
    kk=1;
    for frame=1:pocitacni
        imwrite_single(['../retina/gt/' num2str(file_num,'%03.f') '_' num2str(kk,'%03.f') '.tif'],mean_img(50:end-50,50:end-50));

%         movefile(['../retina/gt/' num2str(file_num,'%03.f') '_' num2str(frame,'%03.f') '.tif'],['../retina/gt/' num2str(file_num,'%03.f') '_' num2str(kk,'%03.f') '.tif'])
        kk=kk+1;
    end
    
    
end




