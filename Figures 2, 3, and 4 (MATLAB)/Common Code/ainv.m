function [ vrotce ] = ainv( vector )
%AINV returns the approximate inverse of a vector
%   for the circular convolution operation
%   vrotce is vector with all elements reversed save the first

vrotce = vector([1,length(vector):-1:2]);

end