%%
% display of curve approximation using Fourier modes.

name = 'triskel';

addpath('../toolbox/');
rep = MkResRep(name);


q = 512; 
I = load_image(name, q);
I = rescale(sum(I,3));

t = linspace(0,1,q);
C = contour(t,t,I,[.5,.5]);
m = C(2,1);  c = C(:,2:m+1); c = c(1,:)'+1i*c(2,:)';

% resample
p = 1024;
curvabs = @(gamma)[0;cumsum( 1e-5 + abs(gamma(1:end-1)-gamma(2:end)) )];
resample1 = @(gamma,d)interp1(d/d(end),gamma,(0:p-1)'/p, 'linear');
resample = @(gamma)resample1( [gamma;gamma(1)], curvabs( [gamma;gamma(1)] ) );
c = resample(c);

% Fourier coefs
P = 50; % # frame
rmax = P;
cf = fft(c); 
f = [0:p/2, -p/2+1:-1]';
rlist = linspace(1,rmax,P);
for i=1:P
    t = (i-1)/(P-1); 
    r = rlist(i);
    c1 = ifft( cf .* (abs(f)<=r) );
    clf;
    plot(c1([1:end 1]), 'Color',  [t 0 1-t], 'LineWidth', 2);
    axis equal; axis([0 1 0 1]); axis off; axis ij;
    drawnow;
    saveas(gcf, [rep name '-' znum2str(i,3) '.png']);
end

s = (0:p-1)/p;
fr = 3;
plot( exp(2i*pi*s*fr) );


% AutoCrop(rep, [name '-'])