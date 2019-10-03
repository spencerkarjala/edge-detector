%% Initialize workspace for main loop; some code provided by uni
% Clear the command window and the workspace
clc;
clear;
close all;

% Set the data and results directories 
datadir     = '../res';    %the directory containing the images
resultsdir  = '../results'; %the directory for dumping results

% Set the edge-finding parameters for each step of the process
sigma     = 1.5;
threshold = 0.20;
rhoRes    = 800/600;
thetaRes  = pi/600;
nLines    = 23;
fillGap   = 6;
minLength = 10;

% Set to 1 to save results to file
saveToFile = 0;

% Initialize the iterator that runs through the images in datadir
imglist = dir(sprintf('%s/*.jpg', datadir));

for i = 1:numel(imglist)
    
    %% Initialize the image for processing
    % Read the i'th image from datadir
    [path, imgname, dummy] = fileparts(imglist(i).name);
    img = imread(sprintf('%s/%s', datadir, imglist(i).name));
    
    % If the image is in color, convert it to greyscale
    if (ndims(img) == 3)
        img = rgb2gray(img);
    end
    
    % Convert the image from uint8 to floating point values on [-1, 1]
    img = double(img) / 255;
    
    %% Use Hough transform to find lines in image
    %  ----------------------------------------------
    % Filter the image using Sobel filters to find the gradient and reduce
    % the resulting edges down to one pixel width
    [Im] = filterImageGradient(img, sigma);
    
    % Transform the filtered image into parameter (Hough) space
    [H,rhoScale,thetaScale] = calcHough(Im, threshold, rhoRes, thetaRes);
    
    % Use the transformed image to obtain lines with the rho, theta values
    [rhos, thetas] = isolateLines(H, nLines);
    
    % Isolate the found peaks for later visualization
    isolatedPeaks = zeros(size(H));
    for j=1:size(rhos,1)
        isolatedPeaks(rhos(j,1),thetas(j,1)) = 255;
    end
    
    % Scale the theta scaler from radians to degrees, and place the rho
    % and theta values in a matrix
    thetaScale = 180 * thetaScale / pi;
    lineVals = [rhos, thetas];
    
    % Use houghlines to package the line information into structs
    lines = houghlines(Im>threshold, thetaScale, rhoScale, lineVals,'FillGap',fillGap,'MinLength',minLength);
    
    % For each line found by houghlines, draw it on the image
    for j = 1 : size(lines,2)
        img = drawLine(img, lines(j).point1, lines(j).point2);
    end
    
    %% Display results in a 2x2 subplot
    % Display the original image, image with found lines, the Hough
    % transform of the image, and the transform with lines highlighted
    subplot(2,2,1), imshow(Im);
    subplot(2,2,2), imshow(img);
    subplot(2,2,3), imshow(uint8(H));
    subplot(2,2,4), imshow(uint8(H));
    
    % Highlight lines on the Hough transform in 4'th subplot
    hold on;
    for k=1:size(isolatedPeaks,1)
        for j=1:size(isolatedPeaks,2)
            if isolatedPeaks(k,j) > 0
                plot(j,k,'sr');
            end
        end
    end
    hold off;

    %% Save data to file if desired
    if saveToFile == 1
        fname = sprintf('%s/%s_01edge.png', resultsdir, imgname);
        imwrite(Im, fname);
        fname = sprintf('%s/%s_02threshold.png', resultsdir, imgname);
        imwrite(Im > threshold, fname);
        fname = sprintf('%s/%s_03hough.png', resultsdir, imgname);
        imwrite(H, fname);
        fname = sprintf('%s/%s_04lines.png', resultsdir, imgname);

        img2 = img;
        for j=1:numel(lines)
           img2 = drawLine(img2, lines(j).point1, lines(j).point2); 
        end     
        imwrite(img2, fname);
    end
end
    
