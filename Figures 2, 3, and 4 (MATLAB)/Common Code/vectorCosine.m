function [cosine] = vectorCosine(x, y)
% VECTOR COSINE computes the cosine of the angle between the vectors x & y
% outputing a value between 1 and -1.
% The cosine is useful as a measure of similarity:
% 0 means the vector are orthogonal, or completely dissimilar
% +1 means the vectors are identical
% -1 means the vectors are exact opposites

[row, col] = size(x);

if(row == 1 || col == 1)
    a = single(x);
    b = single(y);
    
    lengthX = dot(a,a);
    lengthY = dot(b,b);

    productXY = dot(a,b);
else
    a = single(reshape(x,[1,row*col]));
    b = single(reshape(y,[1,row*col]));
    
    lengthX = dot(a,a);
    lengthY = dot(b,b);

    productXY = dot(a,b);
end

if(lengthX * lengthY == 0)
    x
    y
    lengthX
    lengthY
    productXY
    'oops'
end

cosine = productXY / (sqrt(lengthX) * sqrt(lengthY));