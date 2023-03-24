clc;clear;close all;
state = {'$x-Position$','$x-Velocity$','$y-Position$','$y-Velocity$'};
ylabels = {'$x$','$\dot{x}$','$y$','$\dot{y}$'};
options1 = {'interpreter','latex'};
options2 = {'interpreter','latex','fontsize',20};
maxT = 300;



x = randn(1,300);
z = randn(1,300);
x_est = randn(1,300);
plts = cell(1,3);
% fig_handle = cell(4,1);

% Loop over subplots and initialise plot lines

fig_handle=subplot(1,1,1);
view(3)
xlabel('$t$',options2{:});
ylabel(ylabels{1},options2{:});
title(state{1},options1{:})
xlim([0 maxT])

% Hold on to make 3 plots. Create initial points and set line styles.
% Store the plots in a cell array for later reference.
hold on
plts{1} = plot3(fig_handle,[0,1],[0,1],[0,1],'b','linewidth',2);
plts{2} = plot3(fig_handle,[0,1],[0,1],[0,1],'m');
plts{3} = plot3(fig_handle,[0,1],[0,1],[0,1],':k','linewidth',2);
hold off

% March through time. No replotting required, just update XData and YData
for k = 2:maxT

    set(plts{1}, 'XData', 1:k, 'YData', x(1:k),     'ZData',  z(1:k));
    set(plts{2}, 'XData', 1:k, 'YData', z(1:k),     'ZData',  z(1:k));
    set(plts{3}, 'XData', 1:k, 'YData', x_est(1:k), 'ZData',  x(1:k));

    drawnow;
end    