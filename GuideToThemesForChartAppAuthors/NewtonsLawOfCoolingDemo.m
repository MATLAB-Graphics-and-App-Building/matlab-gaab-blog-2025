% Parameters
tempEnv = 25;        % Ambient temperature (°C)
tempInit = 100;      % Initial temperature (°C)
k = 0.03;            % Cooling efficiency, constant
tempThresh = 40;     % Safe handling temperature (°C)

% Time vector (minutes)
time = linspace(0, 200, 500);

% Newton's Law of Cooling
objTemp = tempEnv + (tempInit-tempEnv) * exp(-k*time);

% Find the time when temperature reaches the threshold
idx = find(objTemp <= tempThresh, 1);
timeThresh = time(idx);

% Plotting
h = struct();  % Used to store graphics handles
fig = figure();
h.coolingCurve = plot(time, objTemp, '-', LineWidth=2, DisplayName="Cooling Curve");
hold on;
h.thresholdLine = yline(tempThresh, '--', LineWidth=2, DisplayName="Threshold Temperature");
h.safeHandlingPoint = plot(timeThresh, tempThresh, 'o', MarkerSize=8, DisplayName="Safe Handling Point");

% Labels and title
xlabel('Time (minutes)');
ylabel('Temperature (°C)');
title('Cooling Curve and Safe Handling Temperature');
legend();

% Annotate the intersection point
text(timeThresh, tempThresh + 2, ...
    sprintf('  %.1f min', timeThresh), ...
    'VerticalAlignment', 'bottom');
grid on;

fig.ThemeChangedFcn = @(fig, data)updateManualColors(fig, data, h);
updateManualColors(fig,[],h)

function updateManualColors(fig,~,h)
if fig.Theme.BaseColorStyle == "dark"
    h.coolingCurve.Color = [0.6 0.7 1];
    h.thresholdLine.Color = [1 0.2 0.2];
    h.safeHandlingPoint.MarkerFaceColor = [0 .6 0];
    h.safeHandlingPoint.MarkerEdgeColor = [0.5 0.8 0.5];
else
    h.coolingCurve.Color = [0 0 1];
    h.thresholdLine.Color = [1 0 0];
    h.safeHandlingPoint.MarkerFaceColor = [0 1 0];
    h.safeHandlingPoint.MarkerEdgeColor = [0 0.4 0];
end
end