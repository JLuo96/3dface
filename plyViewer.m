function p=polyViewer(ply)
%function p=polyViewer(ply)
%
% Downloaded from matlab file exchange
% Minor modifications from download by JED Sep 2020
%

f = figure('Tag','PolyViewer');
p = patch(ply);
%set(p,'FaceColor','c','FaceLighting','flat','LineStyle','-');
set(p,'FaceColor','c','FaceLighting','flat','LineStyle','none');

ax1 = gca;
ax1.Visible = 'off';
ax1.Tag = 'MyAxes';
axis equal;
axis vis3d;

light('style','infinite','Tag','MyLight');

rot = rotate3d;
rot.ActionPreCallback = @myprecallback;
rot.ActionPostCallback = @mypostcallback;
rot.Enable = 'on';


function myprecallback(obj,evd)
% disp('A rotation is about to occur.');

function mypostcallback(obj,evd)
f = findobj('Tag','PolyViewer');
ax1 = findobj('Tag','MyAxes');
lt = findobj('Tag','MyLight');

% disp(['Axes Camera Target: ' num2str(ax1.CameraTarget)])
% disp(['Axes Camera Position: ' num2str(ax1.CameraPosition)])
cView = (ax1.CameraTarget - ax1.CameraPosition);
cView = cView./norm(cView);

lt.Position = -cView;
