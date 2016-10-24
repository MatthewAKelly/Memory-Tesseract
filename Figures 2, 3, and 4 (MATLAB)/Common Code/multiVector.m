function [ multitem ] = multiVector( m, n )
%MULTIVECTOR Generates a matrix of m random vectors of dim. n

multitem = zeros(m,n);

for i = 1:m
    multitem(i,:) = normalVector(n);
end
end