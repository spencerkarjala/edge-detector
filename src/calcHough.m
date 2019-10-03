function [H, rhoScale, thetaScale] = calcHough(Im, threshold, rhoRes, thetaRes)
    
    % Determine the max dimension for the rho and theta scale matrices.
    RHO_MAX   = sqrt(size(Im, 1)^2 + size(Im, 2)^2);
    THETA_MAX = pi;
    
    % Using the above, set up the rho and theta scale 1D matrices.
    rhoScale =  -RHO_MAX + rhoRes: 2 * rhoRes : RHO_MAX;
    thetaScale = thetaRes : thetaRes : THETA_MAX;
    
    % Initialize the Hough accumulator to hold all necessary values for the
    % rho and theta scale matrices and set all values to 0.
    H = zeros(size(rhoScale', 1), size(thetaScale', 1));
    
    % Mark each pixel that falls above the threshold with a value of 1.
    imgThresh = Im >= threshold;
    
    % Run the Hough transform on each pixel in the image.
    for j = 1 : size(Im, 1)
        for i = 1 : size(Im, 2)
            
            % If the current pixel surpasses the given threshold, calculate
            % the rho and theta values and maybe add in the accumulator.
            if imgThresh(j,i) == 1
                
                % Calculate the rho for each pre-calculated theta value and
                % scale it onto the domain [0, RHO_MAX]
                rhos = i.*cos(thetaScale) + j.*sin(thetaScale);
                rhos = rhos + RHO_MAX;
                rhos = round(rhos / (2*rhoRes));
                
                % For each (rho, theta) pair, if the scaled rho is > 0, 
                % then count it in the accumulator
                for k = 1 : size(rhos',1)
                    if rhos(k) > 0
                        H(rhos(1,k),k) = H(rhos(1,k),k) + 1;
                    end
                end
            end
        end
    end
end

