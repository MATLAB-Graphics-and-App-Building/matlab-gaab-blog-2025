% Adam Danz 250714
% Math source: https://www.math.unipd.it/~erb/LSphere.html

% Examples
% SphericalLissajousCurve(m1=13, m2=8)
% SphericalLissajousCurve(m1=7, m2=11, alpha=pi)

classdef SphericalLissajousCurve < matlab.graphics.chartcontainer.ChartContainer
    properties
        m1 (1,1) double {mustBePositive, mustBeInteger} = 6
        m2 (1,1) double {mustBePositive, mustBeInteger} = 7
        alpha (1,1) double {mustBeReal} = 0
    end
    properties(Access = private,Transient,NonCopyable)
        SphereSurf (1,:) matlab.graphics.chart.primitive.Surface
        LissajousCurve (1,:) matlab.graphics.chart.primitive.Line
        IntersectionPoints (1,:) matlab.graphics.chart.primitive.Scatter
    end

    methods(Access = protected)
        function setup(obj)
            % Create the axes
            ax = getAxes(obj);

            % Initialize the sphere, line, and scatter
            [X, Y, Z] = sphere(20);
            obj.SphereSurf = surf(ax, X, Y, Z, FaceAlpha=0.4, EdgeAlpha=0.3);
            hold(ax, "on");
            turnOffHold = onCleanup(@()hold(ax,"off"));
            axis(ax, "equal", "off")
            obj.LissajousCurve = plot3(ax,nan,nan,nan,LineWidth=2);
            obj.IntersectionPoints = scatter3(ax,nan,nan,nan,50,MarkerEdgeColor="none");
            ax.Title.FontSize = 14;
        end

        function update(obj)
            if gcd(obj.m1, obj.m2)~=1
                warning(['m1 and m2 should be relative primes. '...
                    'Using relatively prime frequencies (m1,m2) ensures that the curve ' ...
                    'fully explores the sphere without repeating patterns and guarantees ' ...
                    'that the curve has a minimum period of 2π.'])
            end

            % Compute curve
            t = linspace(0, 2*pi, 2000);
            [x, y, z] = lissajousCoordinates(obj, t);

            % Compute intersection points
            [xNodes, yNodes, zNodes] = lissajousIntersections(obj);

            % Update graphics data properties
            set(obj.LissajousCurve, XData=x, YData=y, ZData=z)
            set(obj.IntersectionPoints, XData=xNodes, YData=yNodes, ZData=zNodes)
            ax = getAxes(obj);
            ax.Title.String = sprintf('Spherical Lissajous curve L_{%g}^{(%d,%d)}', obj.alpha, obj.m1, obj.m2);

            % Update line colors
            updateColor(obj);
        end

        function updateColor(obj)
            thm = getTheme(obj);
            switch thm.BaseColorStyle
                case "light"
                    obj.SphereSurf.FaceColor = [0.4 0.4 0.4];
                    obj.LissajousCurve.Color = [0.53 0.80 0.92];
                    obj.IntersectionPoints.MarkerFaceColor = [0 0 0.5];
                case "dark"
                    obj.SphereSurf.FaceColor = [0.67 0.67 0.67];
                    obj.LissajousCurve.Color = [0 0.3 0.43];
                    obj.IntersectionPoints.MarkerFaceColor = [0.8 0.87 1];
            end
        end

        function [x, y, z] = lissajousCoordinates(obj, t)
            % Curves
            x = sin(obj.m2*t) .* cos(obj.m1*t - obj.alpha*pi);
            y = sin(obj.m2*t) .* sin(obj.m1*t - obj.alpha*pi);
            z = cos(obj.m2*t);
        end

        function [xNodes, yNodes, zNodes] = lissajousIntersections(obj)
            % Compute intersection points
            lVals = 0:(2*obj.m1*obj.m2 - 1);
            if mod(obj.m2,2) == 0
                tl = lVals*pi / (obj.m1*obj.m2);
                [xNodes, yNodes, zNodes] = lissajousCoordinates(obj, tl);
            else
                % Poles
                isPole = mod(lVals,obj.m1)==0;
                tPoles = (lVals(isPole)*pi) / (obj.m1*obj.m2);
                % Double points
                tDouble = ((lVals + 0.5)*pi) / (obj.m1*obj.m2);
                tAll = [tPoles, tDouble];
                [xNodes, yNodes, zNodes] = lissajousCoordinates(obj, tAll);
            end
        end
    end
end
