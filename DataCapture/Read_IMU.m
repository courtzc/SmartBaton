% MATLAB data for reading Arduino serial prinout data
% reset
fclose(instrfindall);
delete(instrfindall);

% start
s = serial('COM3'); % change this to desired Arduino board port
set(s,'BaudRate',115200); % baud rate for communication
fopen(s); % open the comm between Arduino and MATLAB
plot_len = 500; % length of plot that updates

x_vals = linspace(0,plot_len,plot_len); % x-values
plot_var = zeros(plot_len,1); % zeros before data comes in

% figure and axes parameters
f1 = figure();
title('MATLAB Serial Readout From Arduino')
xlabel('Sample')
ylabel('Amplitude')
screen = get(0,'screensize');
fig_span = 0.9; % figure size 90% of screen
set(gcf,'Position',[((1.0-fig_span)/2.0)*screen(3),((1.0-fig_span)/2.0)*screen(4),...
    (fig_span*screen(3))-((1.0-fig_span)/2.0)*screen(3),(fig_span*screen(4))-((1.0-fig_span)/2.0)*screen(3)],...
    'color',[252.0,252.0,252.0]/256.0)
f1.Color = [252.0,252.0,252.0]/256.0;
f1.InvertHardcopy = 'off';
set(gca,'FontSize',20,'Color',[205.0,205.0,205.0]/256.0,'GridColor',[252.0,252.0,252.0]/256.0,...
    'LineWidth',1.5,'GridAlpha',0.5)
grid('on')
hold on
loop_break = true; % dummy variable to exit loop when BREAK is pressed
dialogBox = uicontrol('Style', 'PushButton', 'String', 'Break Loop','Callback', 'loop_break = false;');
% plot zeros so we can just update it later
p1 = plot(x_vals,plot_var,'linewidth',2); 

while loop_break 
    out = fscanf(s);
    fprintf("out: %s", out)
    plot_var(1:end-1) = plot_var(2:end);
    plot_var(end) = str2double(out);
    set(p1,'Ydata',plot_var)
    pause(0.05)
end
fclose(s)
delete(s)