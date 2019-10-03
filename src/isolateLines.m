function [rhos, thetas] = isolateLines(H, nLines)
    
    % Set the amount to pad the H-array on both the row and col sides
    ROW_PAD = max([round(size(H,1) / 200), 2]);
    COL_PAD = max([round(size(H,2) / 200), 2]);
    
    % Pad H for non-maximum suppression to prevent boundary issues
    hPad = padarray(H, [ROW_PAD COL_PAD]);
    
    % Perform non-maximum suppression (NMS) on the padded H-matrix
    for j = 1 : size(H,1)
        for i = 1 : size(H,2)
            
            % Create a sub-matrix with dimensions appropriate for the
            % designated size of non-maximum suppression
            A = hPad(j: j+2*ROW_PAD, i : i+2*COL_PAD);
            
            % Find the maximum value of A and count its occurrences
            currMax = max(max(A));
            count = sum(sum(A == currMax));
            
            % Save current index of H into to avoid re-referencing it
            currentValue = H(j, i);
            
            % Set boolean variables for NMS reduction of H
            isMax       = count == 1;
            isCenter    = currentValue == currMax;
            
            % If the any of the above boolean conditions are not met, then
            % set the current index of H to 0
            if ~isMax || ~isCenter
                H(j, i) = 0; 
            end
                
            % If current index is the max value & duplicate of some other 
            % value in current submatrix, zero it in original hPad
            if ~isMax && isCenter
                hPad(j+COL_PAD, i+ROW_PAD) = 0;
                H(j, i) = 0;
            end
        end
    end
    
    % Find all non-zero values at the rho and theta vealues, sort by max
    % intensity in H, and store them in this order for return
    [rhos, thetas, hValues] = find(H);
    result = sortrows([double(hValues), double(rhos), double(thetas)], 'descend');
    rhos   = result(:,2);
    thetas = result(:,3);
    
    % If there are more rhos & thetas than the desired number of lines,
    % only take the first 'nLines' values which are "most important"
    if size(rhos,1) > nLines
        rhos   = rhos(1:nLines, 1);
        thetas = thetas(1:nLines, 1);
    end
    
    % Place rhos and thetas into a matrix and remove any zero-rows
    A = [rhos, thetas];
    A = A(any(A,2),:);
    
    % Restore the rho, theta values from the modified array for return
    rhos   = A(:,1);
    thetas = A(:,2);
end
        