function data = customreaderIn(name)
    global max_val min_val

    data=single(mat2gray(double(imread(name)),double([min_val max_val]))-0.5);
end
