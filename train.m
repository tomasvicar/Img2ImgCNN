clc;clear all;close all force;

% folder_train='D:\Img2ImgCNN\bunky_denoise/train';
% folder_valid='D:\Img2ImgCNN\bunky_denoise/valid';
% 
% folder_train='D:\Img2ImgCNN\bunky_seg/train';
% folder_valid='D:\Img2ImgCNN\bunky_seg/valid';

% folder_train='D:\Img2ImgCNN\bunky_jadra/train';
% folder_valid='D:\Img2ImgCNN\bunky_jadra/valid';


% folder_train='D:\Img2ImgCNN\retina_denoise/train';
% folder_valid='D:\Img2ImgCNN\retina_denoise/valid';

folder_train='D:\Img2ImgCNN\retina_segment/train';
folder_valid='D:\Img2ImgCNN\retina_segment/valid';


% folder_valid='';

ext={'.tif','.png','.jpg'};
miniBatchSize=32;
patchSize=[128 128];
augment=[1,1,1];
epoch=43;
drop_period=10;
drop_faktor=0.3;
init_lr=0.001;





inDs = imageDatastore([folder_train '/data'],'FileExtensions',ext);
outDs = imageDatastore([folder_train '/gt'],'FileExtensions',ext);


unique_lbls=[];
global max_val_lbl min_val_lbl
for i = 1:length(outDs.Files)
    img = readimage(outDs,i);
%     imshow(img,[])
%     drawnow
    u_tmp=unique(img);
    unique_lbls=unique([u_tmp;unique_lbls]);
%     unique_lbls
    max_val_lbl=max([max_val_lbl,max(img(:))]);
    min_val_lbl=min([min_val_lbl,min(img(:))]);
end

global uniques

uniques=unique_lbls;

global max_val min_val
for i = 1:length(inDs.Files)
    img = readimage(inDs,i);
    max_val=max([max_val,max(img(:))]);
    min_val=min([min_val,min(img(:))]);
end





lbl = readimage(outDs,1);
if length(unique_lbls)>20
    classif=0;
    outputs=1;
else
    classif=1;
    outputs=length(unique_lbls);
end


classNames={};
if classif
    for k=1:length(unique_lbls)
    classNames=[classNames char(['x' num2str(unique_lbls(k))])];
    end
end
pixelLabelIDs=unique_lbls;


in_size=[patchSize,size(img,3)];
net=unet(in_size,4,32,outputs,classif);



inDs = imageDatastore([folder_train '/data'],'FileExtensions',ext,'ReadFcn',@customreaderIn);
if classif
    outDs = pixelLabelDatastore([folder_train '/gt'],classNames,pixelLabelIDs,'FileExtensions',ext,'ReadFcn',@customreaderOutClassif);    
else
    outDs = imageDatastore([folder_train '/gt'],'FileExtensions',ext,'ReadFcn',@customreaderOut);
end

augmenter = imageDataAugmenter('RandRotation',@()randi([0,3*double(augment(1))],1)*90,'RandXReflection',augment(2),'RandYReflection',augment(3));

patchds = randomPatchExtractionDatastore(inDs,outDs,patchSize,'PatchesPerImage',1,'DataAugmentation',augmenter);
patchds.MiniBatchSize = miniBatchSize;



img = readimage(inDs,1);




if length(folder_valid)>0
    inDs_v = imageDatastore([folder_valid '/data'],'FileExtensions',ext,'ReadFcn',@customreaderIn);
    if classif
        outDs_v = pixelLabelDatastore([folder_valid '/gt'],classNames,pixelLabelIDs,'FileExtensions',ext,'ReadFcn',@customreaderOutClassif);    
    else
        outDs_v = imageDatastore([folder_valid '/gt'],'FileExtensions',ext,'ReadFcn',@customreaderOut);
    end
    patchds_val = randomPatchExtractionDatastore(inDs_v,outDs_v,patchSize,'PatchesPerImage',1);
    patchds_val.MiniBatchSize = miniBatchSize;
end

img1 = readimage( inDs_v,1);

img2 = readimage( outDs_v,1);

valid_freq=30;

if length(folder_valid)>0
options = trainingOptions('adam', ...
    'InitialLearnRate', init_lr, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',drop_faktor, ...
    'LearnRateDropPeriod',drop_period, ...
    'GradientDecayFactor',0.9, ...
    'SquaredGradientDecayFactor',0.99, ...
    'L2Regularization', 1e-8, ...
    'Shuffle', 'every-epoch', ...
    'VerboseFrequency', 1, ...
    'MiniBatchSize', miniBatchSize, ...
    'ValidationData',patchds_val,...
    'ValidationFrequency',valid_freq,...
    'MaxEpochs', epoch, ...
    'Plots','training-progress');




else
options = trainingOptions('adam', ...
    'InitialLearnRate', init_lr, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',drop_faktor, ...
    'LearnRateDropPeriod',drop_period, ...
    'GradientDecayFactor',0.9, ...
    'SquaredGradientDecayFactor',0.99, ...
    'L2Regularization', 1e-8, ...
    'Shuffle', 'every-epoch', ...
    'VerboseFrequency', 1, ...
    'MiniBatchSize', miniBatchSize, ...
    'MaxEpochs', epoch, ...
    'Plots','training-progress');    
    
end


   
[net, info] = trainNetwork(patchds,net,options);


folder_net=folder_train;
folder_net=[folder_net '_net'];
mkdir(folder_net)
name_save=[folder_net '/net_' datestr(now,'mmmm-dd-yyyy-HH-MM-SS-FFF') '.mat'];
save(name_save,'net','max_val','min_val','min_val_lbl','max_val_lbl','classif','uniques','pixelLabelIDs','classNames','patchSize','ext')


predict_net([folder_valid '\data'],[folder_valid '\gt'],name_save,1);






