function res = convolveImage(img, h)
    
    % Determine [numRows, numCols] in the original image
    dimImgOriginal = size(img);
    
    % Determine [numRows, numCols] in the convolution filter
    dimKernel = size(h);
    
    % Determine [numRows, numCols] that need to be padded onto the
    % original image to prevent boundary effects
    padSizes = (dimKernel - [1, 1])./2;
    
    % Pad the image with zeroes
    img = padarray(img, padSizes, 'replicate');
    
    % Initialize a result image matrix with type uint8 at the same
    % size as the original image
    res = zeros(dimImgOriginal);
    
    % Flip the kernel from bottom-to-top and right-to-left so that
    % performing correlation is turned into convolution
    h = flip(h,1);
    h = flip(h,2);
    
    % Convolve the image with the kernel
    for j = 1 : dimImgOriginal(1)
        for i = 1 : dimImgOriginal(2)
            
            % Find the submatrix centered at (i,j)
            A = img(j:j+dimKernel(1)-1, i:i+dimKernel(2)-1);
            
            % Calculate the sum of all element multiples in both matrices
            B = double(A).*double(h);
            val = sum(B(:));
            res(j,i) = val;
        end
    end
end
