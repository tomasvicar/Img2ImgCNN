


function data = customreaderOut(name)
    global max_val_lbl min_val_lbl


    data=single(mat2gray(double(imread(name)),double([min_val_lbl max_val_lbl]))-0.5);
    if length(size(data))>2
%         if length(size(data))==3
%             data=rgb2gray(data);
%         end
        error('3D data error')
    end
    
end
