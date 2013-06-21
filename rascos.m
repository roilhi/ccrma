function w = rascos(N)

M = 2*floor(N/2);

n=(0:M+1)';
w = 1-cos((2*pi/(M+2)).*n);
w = w./2;

w(1) = [];
if mod(N,2) == 0
    w(N/2+1) = [];
end

