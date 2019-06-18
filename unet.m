function lgraph=unet(velikost_obrazku,stupne,pocet_filtru,vystupy,classif)

pad =[1 1];


layers = [imageInputLayer(velikost_obrazku,'Name','input','Normalization','none')];


for k=1:stupne
    layers=[layers, convolution2dLayer(3,pocet_filtru*k,'Padding',pad,'Name',['conv1_s' num2str(k)])];
    layers=[layers,  reluLayer('Name',['relu1_s' num2str(k)])];
    layers = [layers, batchNormalizationLayer('Name',['batchnorm1_s' num2str(k)])];
    

    
    layers=[layers, convolution2dLayer(3,pocet_filtru*k,'Padding',pad,'Name',['conv2_s' num2str(k)])];
    layers=[layers,  reluLayer('Name',['relu2_s' num2str(k)])];
    layers = [layers, batchNormalizationLayer('Name',['batchnorm2_s' num2str(k)])];

    
    if k<stupne
        layers=[layers,  maxPooling2dLayer(2,'Stride',2,'Name',['pool_s' num2str(k)])];
    end
end


% 
for k=stupne-1:-1:1
%     'Stride',4
%     'Cropping',[1 1]
    layers = [layers,transposedConv2dLayer(2,pocet_filtru*k,'Stride',2,'Name',['transposed_' num2str(k+1)])];
    
    layers = [layers, depthConcatenationLayer(2,'Name',['concat_' num2str(k)])];
    
    layers=[layers, convolution2dLayer(3,pocet_filtru*k,'Padding',pad,'Name',['de_conv1_s' num2str(k)])];
    layers=[layers,  reluLayer('Name',['de_relu1_s' num2str(k)])];
    layers = [layers, batchNormalizationLayer('Name',['de_batchnorm1_s' num2str(k)])];
    
    
    layers=[layers convolution2dLayer(3,pocet_filtru*k,'Padding',pad,'Name',['de_conv2_s' num2str(k)])];
    layers=[layers,  reluLayer('Name',['de_relu2_s' num2str(k)])];
    layers = [layers, batchNormalizationLayer('Name',['de_batchnorm2_s' num2str(k)])];

end


if classif
    layers=[layers, convolution2dLayer(1,vystupy,'Padding',[0 0],'Name',['final_conv'])];
    layers=[layers ,softmaxLayer('Name','softmax')];
    layers=[layers ,dicePixelClassificationLayer('dicePixelClassificationLayer')];

else
    layers=[layers, convolution2dLayer(1,vystupy,'Padding',[0 0],'Name',['final_conv'])];
    layers=[layers ,pixelRegressionLayer('pixelClassificationLayer')];
end




lgraph = layerGraph(layers);

for k=1:stupne-1
        lgraph = connectLayers(lgraph,['batchnorm2_s' num2str(k)],['concat_' num2str(k) '/in2']);
end