function B = fillmissingrgb(A, method, gapValue)
%FILLMISSINGRGB - fill missing entries in an RGB image.
%
%   B = fillmissingrgb(A, method, gapValue) fills gaps that are equal
%   to gapValue in an RGB image, using given method. See the input
%   arguments' description below.
%
%   A - an input RGB image. must be m x n x 3 array of type 
%   double, single or uint8.
%   
%   method - one of the interpolation methods defined for Matlab's builtin 
%   funtction fillmissing():
%      'previous'  - Previous non-missing entry.
%      'next'      - Next non-missing entry.
%      'nearest'   - Nearest non-missing entry.
%      'linear'    - Linear interpolation of non-missing entries.
%      'spline'    - Piecewise cubic spline interpolation.
%      'pchip'     - Shape-preserving piecewise cubic spline interpolation.
%   
%   gapValue - value that is treated as 'missing' and that is going to be
%   filled with interpolated values. Usually a NaN or 0, but any other 
%   value is allowed. gapValue may be a scalar value or a 1 x 3 vector. 
%   If this argument is missing, 0 is assumed.
%
%   Copyright 2017 KjMag
parseInputs(A, method, gapValue);

if isa(A, 'uint8')
    A = double(A);
end
B = A;

[~,k] = size(gapValue);
% If all the gapValue values are the same, reduce it to 1 for better
% efficiency:
if k == 3 && gapValue(1) == gapValue(2) && gapValue(2) == gapValue(3)
    gapValue(3) = [];
    gapValue(2) = [];
    [~,k] = size(gapValue);
end
% Replacing gap values with NaNs so that A may be used with Matlab's
% fillmissing() function:
if ~isnan(gapValue)
    if k == 1
        %A(A == gapValue) = NaN;
        temp = (A == gapValue);
        temp = temp(:,:,1) .* temp(:,:,2) .* temp(:,:,3);
    else % i.e. if k == 3
        temp1 = A(:,:,1) == gapValue(1);
        temp2 = A(:,:,2) == gapValue(2);
        temp3 = A(:,:,3) == gapValue(3);
        temp = temp1 .* temp2 .* temp3;
    end
    [row, col] =  find(temp);
    linearidx = [sub2ind(size(A), row, col, ones([length(row),1])) ;
            sub2ind(size(A), row, col, ones([length(row),1])*2) ; 
            sub2ind(size(A), row, col, ones([length(row),1])*3)];
    A(linearidx) = NaN;  
end
temp1 = fillmissing(A, method, 1);
temp2 = fillmissing(A, method, 2);
A = (temp1 + temp2)/2;

[m,n,~] = size(A);
if k == 1
    for a = 1:m
        for b = 1:n
            if B(a,b,:) == [gapValue gapValue gapValue]
                B(a,b,:) = A(a,b,:);
            end
        end
    end
else % i.e. if k == 3
     for a = 1:m
        for b = 1:n
            if B(a,b,:) == gapValue
                B(a,b,:) = A(a,b,:);
            end
        end
    end
end

B = uint8(B);

%--------------------------------------------------------------------------
function parseInputs(A, method, gapValue)
    if nargin < 2
        error('Too few input arguments.');
    end
    if nargin == 2
        gapValue = 0;
    end

    if ndims(A) ~= 3
        error('Invalid number of dimensions for an RGB image (valid value: 3).');
    end
    sz = size(A);
    if sz(3) ~= 3
        error('Invalid number of RGB channels (valid value: 3).');
    end
    if ~isfloat(A) && ~isa(A, 'uint8')
        error('Incorrect input matrix type (acceptable types: single, double, uint8).');
    end

    if ~ismatrix(gapValue)
        error('Incorrect number of gapValue dimensions (valid value: 2).');
    end
    sz2 = size(gapValue);
    if sz2(1) ~= 1 && (sz2(2) ~= 1 || sz2(2) ~= 3)
        error('Incorrect gapValue size (acceptable size: 1x1, 1x3)');
    end
    if sum(~isnan(gapValue)) > 0 && ~isnumeric(gapValue)
        error('Invalid type of gapValue variable - should be numeric or NaN.');
    end
end %parseInputs

end %fillmissingrgb