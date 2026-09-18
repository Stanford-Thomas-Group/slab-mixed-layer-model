classdef SlabTransportTest < matlab.unittest.TestCase

    methods (Test)
        function constantForcingMatchesClosedForm(testCase)
            % For r=0 and constant forcing, dW/dt + ifW = tauTilde*exp(i*theta)
            % has the closed-form solution
            % W(t) = tauTilde*exp(i*theta)*(1-exp(-i*f*t))/(i*f).
            latitude = 30.0;
            f = 7.2921159e-5; % 2*OMEGA*sind(30) == OMEGA
            theta = pi / 4.0;
            tauTilde = 2.0;
            time = linspace(0.0, 6 * 3600.0, 361);

            [U, V] = slabmodel.slabTransport(time, tauTilde, theta, ...
                "latitude", latitude, "units", "Pa", "rho0", 1.0);

            expected = tauTilde * exp(1i * theta) * (1 - exp(-1i * f * time)) / (1i * f);
            testCase.verifyEqual(U, real(expected), "RelTol", 1e-3)
            testCase.verifyEqual(V, imag(expected), "RelTol", 1e-3)
        end

        function rotatingDirectionMatchesClosedForm(testCase)
            % For constant amplitude and direction rotating at constant angular
            % velocity omega, T(t) = tauTilde*exp(i*(theta0+omega*t)) =
            % A*exp(i*omega*t), and dW/dt + (r+if)W = T(t) has closed-form
            % solution (W(0)=0):
            %   W(t) = [A/(r+i*(omega+f))] * (exp(i*omega*t) - exp(-(r+if)*t))
            latitude = 30.0;
            f = 7.2921159e-5;
            factor = 0.1;
            r = factor * abs(f);
            omega = 8.0e-4; % >> f
            theta0 = 0.5;
            tauTilde = 3.0;
            time = linspace(0.0, 20000.0, 2001);
            direction = theta0 + omega * time;

            [U, V] = slabmodel.slabTransport(time, tauTilde, direction, ...
                "latitude", latitude, "factor", factor, "units", "Pa", "rho0", 1.0);

            a = tauTilde * exp(1i * theta0);
            expected = (a / (r + 1i * (omega + f))) ...
                .* (exp(1i * omega * time) - exp(-(r + 1i * f) * time));
            testCase.verifyEqual(U, real(expected), "RelTol", 1e-3)
            testCase.verifyEqual(V, imag(expected), "RelTol", 1e-3)
        end

        function nanInConstantSeriesReproducesSameResult(testCase)
            time = linspace(0.0, 3600.0, 61);
            amplitude = 3.0 * ones(size(time));
            direction = 1.0 * ones(size(time));

            [baselineU, baselineV] = slabmodel.slabTransport(time, amplitude, direction, ...
                "latitude", 45.0, "units", "Pa", "rho0", 1.0);

            amplitudeGap = amplitude;
            directionGap = direction;
            amplitudeGap(31) = NaN;
            directionGap(31) = NaN;
            [gapU, gapV] = slabmodel.slabTransport(time, amplitudeGap, directionGap, ...
                "latitude", 45.0, "units", "Pa", "rho0", 1.0);

            testCase.verifyEqual(gapU, baselineU, "RelTol", 1e-10)
            testCase.verifyEqual(gapV, baselineV, "RelTol", 1e-10)
        end

        function nanGapMatchesRemovingTheSample(testCase)
            % With f=0 and r=0, h(t) == g(t) exactly (no exponential
            % weighting), and if the underlying forcing is exactly linear in
            % time, the trapezoidal rule is exact: interpolating a
            % linearly-consistent value at a gap and integrating normally
            % must reproduce precisely the same result, at every surviving
            % time, as removing that sample and integrating across the
            % doubled timestep.
            time = [0.0, 60.0, 120.0, 180.0, 240.0, 300.0];
            amplitude = 5.0 + 0.01 * time; % exactly linear in time
            direction = 0.3 * ones(size(time));

            amplitudeGap = amplitude;
            directionGap = direction;
            amplitudeGap(3) = NaN;
            directionGap(3) = NaN;
            [gapU, gapV] = slabmodel.slabTransport(time, amplitudeGap, directionGap, ...
                "latitude", 0.0, "units", "Pa", "rho0", 1.0);

            timeRemoved = time;
            timeRemoved(3) = [];
            amplitudeRemoved = amplitude;
            amplitudeRemoved(3) = [];
            directionRemoved = direction;
            directionRemoved(3) = [];
            [removedU, removedV] = slabmodel.slabTransport( ...
                timeRemoved, amplitudeRemoved, directionRemoved, ...
                "latitude", 0.0, "units", "Pa", "rho0", 1.0);

            gapUSurviving = gapU;
            gapUSurviving(3) = [];
            gapVSurviving = gapV;
            gapVSurviving(3) = [];
            testCase.verifyEqual(gapUSurviving, removedU, "RelTol", 1e-9)
            testCase.verifyEqual(gapVSurviving, removedV, "RelTol", 1e-9)
            testCase.verifyTrue(isfinite(gapU(3)))
            testCase.verifyTrue(isfinite(gapV(3)))
        end

        function allNanRaises(testCase)
            time = [0.0, 60.0, 120.0];
            amplitude = NaN(size(time));
            direction = NaN(size(time));
            testCase.verifyError( ...
                @() slabmodel.slabTransport(time, amplitude, direction, "latitude", 45.0), ...
                "slabmodel:slabTransport:allNaN")
        end

        function scalarAmplitudeAndDirectionBroadcast(testCase)
            time = linspace(0.0, 3600.0, 50);
            [U, V] = slabmodel.slabTransport(time, 5.0, 0.2, "latitude", 45.0);
            testCase.verifyEqual(size(U), size(time))
            testCase.verifyEqual(size(V), size(time))
            testCase.verifyTrue(all(isfinite(U)))
            testCase.verifyTrue(all(isfinite(V)))
        end
    end

end
