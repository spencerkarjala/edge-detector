# matlab-edgedetector

Given an image, this program performs a five-step process which analyzes the image gradient to detect, assign, and draw edges in the image.

1. **convolveImage.m**: Performs Derivative of Gaussian convolution on the image, given a variable sigma value and using a separated Sobel operator, to find the horizontal and vertical gradient of the image with minimal noise. Non-maximum suppression is then performed along the gradient direction of the resulting edge-magnitude image to reduce potential edges to single-pixel width to assist with part 3.

2. **filterImageGradient.m**: A simple function that returns the convolution of the first input, typically an image, with the second input, typically the kernel.

3. **calcHough.m**: Iterates over each pixel of an image using the line parameterization <a href="https://www.codecogs.com/eqnedit.php?latex=\rho=x\cos\theta&plus;y\sin\theta" target="_blank"><img src="https://latex.codecogs.com/png.latex?\rho=x\cos\theta&plus;y\sin\theta" title="\rho=x\cos\theta+y\sin\theta" /></a> to perform a Hough transform on the image. This maps the edge-magnitude image produced by  part 1 to the set defined by <a href="https://www.codecogs.com/eqnedit.php?latex=\rho" target="_blank"><img src="https://latex.codecogs.com/png.latex?\rho" title="\rho" /></a> and <a href="https://www.codecogs.com/eqnedit.php?latex=\theta" target="_blank"><img src="https://latex.codecogs.com/png.latex?\theta" title="\theta" /></a>.

4. **isolateLines.m**: Performs a second round of non-maximum suppression on the Hough accumulator produced by part 3 to isolate only the most pronounced lines of the image. The input nLines can be set to limit the maximum number of lines produced.

5. **mainScript.m**: Performs each of the previous steps on a set of images to produce the lines detected by part 4. Then, takes the detected lines, draws them on the image, and saves the final image to disk for analysis.
