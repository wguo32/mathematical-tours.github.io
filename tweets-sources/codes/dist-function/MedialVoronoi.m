%%
% computation of the medial axis via vornoi cells

rep = '../results/medial-voronoi/';
[~,~] = mkdir(rep);
addpath('../toolbox/');

name = 'curve';

curvabs = @(gamma)[0;cumsum( 1e-5 + abs(gamma(1:end-1)-gamma(2:end)) )];
resample1 = @(gamma,d,p)interp1(d/d(end),gamma,(0:p-1)'/p, 'linear');
resample = @(gamma,p)resample1( [gamma;gamma(1)], curvabs( [gamma;gamma(1)] ),p );


if not(exist('Z0'))
clf; hold on;
Z = [];
while true
    axis([0 1 0 1]);
    [a,b,button] = ginput(1);
    plot(a,b, '.', 'MarkerSize', 15);
    if button==3
        break;
    end
    Z(:,end+1) = [a;b];
end
Z0 = Z;
end

%%
% Subdivision.

nsub = 6; 
q = 100; % #points

% perform curve subdivision
subdivide = @(f,h)cconvol( upsampling(f), h);
h = [1 4 6 4 1]; % cubic B-spline
h = 2*h/sum(h(:));
z = Z0(1,:)'+1i*Z0(2,:)';
for k=1:nsub
    z = subdivide(z,h);
end
z = resample(z,q);
Z = [real(z(:))'; imag(z(:))'];


% grid
n = 256*2;
t = linspace(0,1,n);
[Y,X] = meshgrid(t,t);
% distance
D = distmat( Z,[X(:)';Y(:)'] );
D = reshape(min(D,[],1),[n n]);

% compute delaunay
Z1 = Z;
z = Z1(1,:) + 1i*Z1(2,:);
T = delaunay(Z1(1,:),Z1(2,:))';
[VX,VY] = voronoi(Z1(1,:),Z1(2,:));
V = VX + 1i*VY;

% draw
r = 15;
clf; hold on;
imagesc(t,t,D');
% contour(t,t,D',r, 'k--');
colormap(parula(r+1));
%
plot(Z(1,:), Z(2,:), 'r.', 'MarkerSize', 25);
% plot(Z(1,[1:end 1]), Z(2,[1:end 1]), 'r', 'LineWidth', 2);
% medial axis
m = abs(V(1,:)-V(2,:));
% threshold
s = 10/q; 
s = 8/q; % 80
s = 9.5/q; % 80
s = 4/q; % 20
if q==200
    s = 20/q; % 20
end
if q==100
    s = 20/q; % 20
end
I = find(m<s);
J = find(m>=s);
plot(V(:,J), '-', 'LineWidth', 1, 'color', [1 1 1]*.6);
plot(V(:,I), '-', 'LineWidth', 4, 'color', 'b');
%
axis tight; 
axis([0 1 0 1]); axis equal;
axis([0 1 0 1]);
axis off;
drawnow;
saveas(gcf, [rep name '-' num2str(q) '.png'], 'png');



