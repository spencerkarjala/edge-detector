function res = filterImageGradient(img, sigma)

    % Calculate the size of the Gaussian filter to use
    hsize = 2 * ceil(sigma) + 1;
    
    % Obtain the Gaussian filter to be used from hsize and sigma
    filt = fspecial('gaussian', hsize, sigma);
    
    % Compute horizontal derivative of Gaussian filter using a separated 
    % horizontal Sobel filter in two passes
    xGauss = convolveImage(filt, [1 2 1]');
    xGauss = convolveImage(xGauss, [1 0 -1]);
    
    % Compute a vertical Derivative of Gaussian filter using a separated
    % vertical Sobel filter in two passes
    yGauss = convolveImage(filt, [1 0 -1]');
    yGauss = convolveImage(yGauss, [1 2 1]);
    
    % Use the two DoG kernels to compute the horizontal and vertical
    % gradient of the given image with a Gaussian blur
    xImgGrad = convolveImage(img, xGauss);
    yImgGrad = convolveImage(img, yGauss);
    
    % Calculate the magnitude of the gradient throughout the image
    imgGradMag = sqrt(double(xImgGrad).^2 + double(yImgGrad).^2);
    
    % Calculate the direction of the gradient throughout the image
    imgGradDir = atan2(double(yImgGrad), double(xImgGrad));
    
    % Scale and round the gradient direction to multiples of pi/4; then
    % wrap negative values to positive, reduces 8 directions to 4
    imgGradDir = mod(round(imgGradDir / (pi / 4)), 4);
    
    % Pad the array with zeroes for non maximum suppression (NMS)
    imgBuf = padarray(imgGradMag, [1 1]);
    
    % Initialize the result matrix with zeroes
    res = zeros(size(imgGradMag));

    % Perform NMS on the filtered image
    for j = 1:size(imgGradMag, 1)
        for i = 1:size(imgGradMag, 2)
            
            % Initialize x,y values to iterate through padded matrix
            x = i+1; y = j+1;
            
            % Initialize the neighbor values and booleans to be checked
            aVal = 0; bVal = 0;
            aChk = 0; bChk = 0;
            
            % Find the value of the current index
            curr = imgBuf(y,x);
            
            % Check the neighbors in each of the four quantized directions;
            % in each case, suppress (i,j) if it is not the largest value
            switch imgGradDir(j,i)
                case 0      % East-West direction
                    aVal = imgBuf(y,x-1);
                    bVal = imgBuf(y,x+1);
                    aChk = aVal <= curr;
                    bChk = bVal <= curr;
                case 1      % Northeast-Southwest direction
                    aVal = imgBuf(y-1,x-1);
                    bVal = imgBuf(y+1,x+1);
                    aChk = aVal <= curr;
                    bChk = bVal <= curr;
                case 2      % North-South direction
                    aVal = imgBuf(y-1,x);
                    bVal = imgBuf(y+1,x);
                    aChk = aVal <= curr;
                    bChk = bVal <= curr;
                case 3      % Northwest-Southeast direction
                    aVal = imgBuf(y+1,x-1);
                    bVal = imgBuf(y-1,x+1);
                    aChk = aVal <= curr;
                    bChk = bVal <= curr;
            end
            
            % Set the value in the result matrix to be the current iterated
            % value only if it is the largest one of the three
            res(j,i) = curr * (aChk * bChk);
            
            % If value (i,j) is equal to 
            imgBuf(y,x) = curr + ((aVal == curr) || (bVal == curr));
        end
    end
end
