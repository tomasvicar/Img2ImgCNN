clc;clear all;close all;
% delete(gcp('nocreate'))
% parpool(4)

listing=subdir('../data/*.avi');

listing={listing.name};

mkdir('../data_tif')
mkdir('../data_tif_valid')

for file_num=60:length(listing)%1:15%length(listing)
    file_num
    v = VideoReader(listing{file_num});
    
    name=listing{file_num};
    if file_num<10
        name=[strrep(name(1:end-4),'data','data_tif_valid') '.tif'];
    else
        name=[strrep(name(1:end-4),'data','data_tif') '.tif'];
        
    end
    
    num_of_frames=round(v.Duration*v.FrameRate);
    img_size=[v.Height,v.Width,];
    
    imgs=zeros([img_size num_of_frames]);
    
    frame=0;
    while hasFrame(v)
        frame=frame+1;
        img = readFrame(v);
        img=rgb2gray(single(img)/255);
        imwrite_single([name(1:end-4) '_' num2str(frame,'%03.f') '.tif'],img);
        
    end
    
    
    kk=5;
    for k=1:num_of_frames
        img=imgs(:,:,k);
        distances=sum(sum((repmat(img,[1 1 num_of_frames])-imgs).^2,1),2);
        distances=squeeze(distances);
        distances(k)=Inf;
        [v,order]=sort(distances);
        k_best=order(1:kk);
        save_par([name(1:end-4) '_' num2str(k,'%03.f') '.mat'],k_best);
    end
    
    
end



function save_par(a,k_best)


save(a,'k_best')


end


